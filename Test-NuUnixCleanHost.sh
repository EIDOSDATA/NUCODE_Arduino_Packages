#!/usr/bin/env bash
#
# SPDX-License-Identifier: Apache-2.0
#
# /**
#  * @file Test-NuUnixCleanHost.sh
#  * @brief Linux/macOS의 빈 Arduino Data/User에서 Platform 0.3.1을 검증한다.
#  */

set -euo pipefail

PLATFORM_VERSION="0.3.1"
FQBN="nucode:zephyr:nu40dk_v2"
INDEX_URL=""
PORT=""
ARDUINO_CLI="${ARDUINO_CLI:-arduino-cli}"
TEST_ROOT=""

## @brief 명령 사용법을 출력한다.
usage()
{
    cat <<'EOF'
Usage:
  Test-NuUnixCleanHost.sh --index-url URL [options]

Options:
  --arduino-cli PATH   Arduino CLI 실행 파일. 기본값: arduino-cli
  --port PORT          실제 NU40 CDC Port. 지정하면 Blink UF2를 업로드한다.
  --root PATH          격리 Data/User/Build와 Evidence 경로
  --help               도움말

Examples:
  bash Test-NuUnixCleanHost.sh \
    --index-url https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/package_nucode_index_0.3.1-rc1.json \
    --port /dev/ttyACM0

  bash Test-NuUnixCleanHost.sh \
    --index-url https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/package_nucode_index_0.3.1-rc1.json \
    --port /dev/cu.usbmodemNU40
EOF
}

while (($# > 0))
do
    case "$1" in
        --index-url)
            INDEX_URL="$2"
            shift 2
            ;;
        --arduino-cli)
            ARDUINO_CLI="$2"
            shift 2
            ;;
        --port)
            PORT="$2"
            shift 2
            ;;
        --root)
            TEST_ROOT="$2"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            printf '알 수 없는 인수입니다: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

if [[ -z "$INDEX_URL" ]]
then
    printf '%s\n' '--index-url은 필수입니다.' >&2
    exit 2
fi

if [[ "$ARDUINO_CLI" == */* ]]
then
    if [[ ! -x "$ARDUINO_CLI" ]]
    then
        printf 'Arduino CLI를 실행할 수 없습니다: %s\n' "$ARDUINO_CLI" >&2
        exit 2
    fi
elif ! command -v "$ARDUINO_CLI" >/dev/null 2>&1
then
    printf 'Arduino CLI가 PATH에 없습니다: %s\n' "$ARDUINO_CLI" >&2
    exit 2
fi

if [[ -z "$TEST_ROOT" ]]
then
    TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/nucode-031.XXXXXX")"
else
    if [[ -d "$TEST_ROOT" ]] && [[ -n "$(ls -A "$TEST_ROOT")" ]]
    then
        printf '격리 시험 Root가 비어 있지 않습니다: %s\n' "$TEST_ROOT" >&2
        exit 2
    fi
    mkdir -p "$TEST_ROOT"
    TEST_ROOT="$(cd "$TEST_ROOT" && pwd)"
fi

DATA_ROOT="$TEST_ROOT/data"
DOWNLOAD_ROOT="$TEST_ROOT/downloads"
USER_ROOT="$TEST_ROOT/user"
BUILD_ROOT="$TEST_ROOT/build"
CONFIG_PATH="$TEST_ROOT/arduino-cli.yaml"
EVIDENCE_PATH="$TEST_ROOT/unix-clean-host-evidence.json"

mkdir -p "$DATA_ROOT" "$DOWNLOAD_ROOT" "$USER_ROOT" "$BUILD_ROOT"

cat >"$CONFIG_PATH" <<EOF
board_manager:
  additional_urls:
    - "$INDEX_URL"
directories:
  data: "$DATA_ROOT"
  downloads: "$DOWNLOAD_ROOT"
  user: "$USER_ROOT"
EOF

## @brief 지정 Sketch Source를 생성한다.
write_sketch()
{
    local name="$1"
    local source="$2"
    local sketch_dir="$USER_ROOT/$name"
    mkdir -p "$sketch_dir"
    printf '%s\n' "$source" >"$sketch_dir/$name.ino"
}

write_sketch "Blink" '
void setup()
{
    pinMode(LED_BUILTIN, OUTPUT);
    Serial.begin(115200);
}

void loop()
{
    digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN));
    Serial.println("NUCODE 0.3.1 UNIX CLEAN HOST");
    delay(1000);
}'

write_sketch "ServoSmoke" '
#include <Servo.h>

Servo servo;

void setup()
{
    servo.attach(2);
}

void loop()
{
    servo.write(90);
    delay(1000);
}'

write_sketch "WireSmoke" '
#include <Wire.h>

void setup()
{
    Wire.begin();
}

void loop()
{
    Wire.beginTransmission(0x40);
    Wire.write(0x55);
    Wire.endTransmission();
    delay(1000);
}'

write_sketch "SpiSmoke" '
#include <SPI.h>

void setup()
{
    SPI.begin();
}

void loop()
{
    SPI.beginTransaction(SPISettings(1000000, MSBFIRST, SPI_MODE0));
    SPI.transfer(0x55);
    SPI.endTransaction();
    delay(1000);
}'

write_sketch "ArduinoBleSmoke" '
#include <ArduinoBLE.h>

void setup()
{
    BLE.begin();
    BLE.setLocalName("NU40-031");
    BLE.advertise();
}

void loop()
{
    BLE.poll();
}'

write_sketch "NuBleUartSmoke" '
#include <NUBleUart.h>

NUBleUart bleUart;

void setup()
{
    bleUart.begin("NU40-031-NUS");
}

void loop()
{
    bleUart.poll();
}'

printf '>> Platform Index 갱신: %s\n' "$INDEX_URL"
"$ARDUINO_CLI" --config-file "$CONFIG_PATH" core update-index

printf '>> Platform 설치: nucode:zephyr@%s\n' "$PLATFORM_VERSION"
"$ARDUINO_CLI" --config-file "$CONFIG_PATH" \
    core install "nucode:zephyr@$PLATFORM_VERSION"

for sketch in Blink ServoSmoke WireSmoke SpiSmoke ArduinoBleSmoke NuBleUartSmoke
do
    printf '>> Compile: %s\n' "$sketch"
    "$ARDUINO_CLI" --config-file "$CONFIG_PATH" compile \
        --fqbn "$FQBN" \
        --build-path "$BUILD_ROOT/$sketch" \
        "$USER_ROOT/$sketch"
done

UPLOAD_RESULT="not_run"

if [[ -n "$PORT" ]]
then
    printf '>> Upload: Blink -> %s\n' "$PORT"
    "$ARDUINO_CLI" --config-file "$CONFIG_PATH" upload \
        --fqbn "$FQBN" \
        --port "$PORT" \
        --build-path "$BUILD_ROOT/Blink"
    UPLOAD_RESULT="passed"
fi

HOST_OS="$(uname -s)"
HOST_ARCH="$(uname -m)"
TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

cat >"$EVIDENCE_PATH" <<EOF
{
  "schema_version": 1,
  "timestamp_utc": "$TIMESTAMP",
  "platform_version": "$PLATFORM_VERSION",
  "fqbn": "$FQBN",
  "host_os": "$HOST_OS",
  "host_arch": "$HOST_ARCH",
  "compile": "passed",
  "upload": "$UPLOAD_RESULT",
  "port": "$PORT",
  "index_url": "$INDEX_URL",
  "test_root": "$TEST_ROOT"
}
EOF

printf '\nNUCODE Platform 0.3.1 Unix Clean-host 자동 시험 통과\n'
printf 'Host     : %s/%s\n' "$HOST_OS" "$HOST_ARCH"
printf 'Compile  : Blink, Servo, Wire, SPI, ArduinoBLE, NUBleUart PASS\n'
printf 'Upload   : %s\n' "$UPLOAD_RESULT"
printf 'Evidence : %s\n' "$EVIDENCE_PATH"
printf '\n남은 수동 확인:\n'
printf '1. Arduino IDE Serial Monitor에서 1초 Heartbeat 확인\n'
printf '2. Button 1 Hold Reset으로 Safe Mode 진입과 정상 Reset 복귀\n'
printf '3. 두 NU40 사용 시 비선택 Board의 Build ID와 Sketch 불변 확인\n'
