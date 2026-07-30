#!/usr/bin/env bash
#
# SPDX-License-Identifier: Apache-2.0
#
# /**
#  * @file Test-NuUnixCleanHost.sh
#  * @brief Linux/macOS의 빈 Arduino Data/User에서 지정 Platform을 검증한다.
#  */

set -euo pipefail

PLATFORM_VERSION="0.3.1"
EXPECTED_CORE_VERSION=""
EXPECTED_TOOL_VERSION=""
FQBN="nucode:zephyr:nu40dk_v2"
INDEX_URL=""
PORT=""
ARDUINO_CLI="${ARDUINO_CLI:-arduino-cli}"
TEST_ROOT=""
ENFORCE_CLEAN_HOST=0

## @brief 명령 사용법을 출력한다.
usage()
{
    cat <<'EOF'
Usage:
  Test-NuUnixCleanHost.sh --index-url URL [options]

Options:
  --arduino-cli PATH   Arduino CLI 실행 파일. 기본값: arduino-cli
  --platform-version V 설치하고 검사할 Platform Version. 기본값: 0.3.1
  --core-version V     SBOM에서 확인할 ArduinoCore-Zephyr Version
  --tool-version V     설치 경로에서 확인할 nu-zephyr-tools Version
  --port PORT          실제 NU40 CDC Port. 지정하면 Blink UF2를 업로드한다.
  --root PATH          격리 Data/User/Build와 Evidence 경로
  --enforce-clean-host NCS/Go/West/ARM GCC/제품 저장소가 있으면 실패
  --help               도움말

Examples:
  bash Test-NuUnixCleanHost.sh \
    --index-url https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/package_nucode_index.json \
    --platform-version 0.3.1 \
    --port /dev/ttyACM0

  bash Test-NuUnixCleanHost.sh \
    --index-url https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/package_nucode_index.json \
    --platform-version 0.3.1 \
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
        --platform-version)
            PLATFORM_VERSION="$2"
            shift 2
            ;;
        --core-version)
            EXPECTED_CORE_VERSION="$2"
            shift 2
            ;;
        --tool-version)
            EXPECTED_TOOL_VERSION="$2"
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
        --enforce-clean-host)
            ENFORCE_CLEAN_HOST=1
            shift
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

if ((ENFORCE_CLEAN_HOST == 1))
then
    for external_command in west go arm-zephyr-eabi-gcc
    do
        if command -v "$external_command" >/dev/null 2>&1
        then
            printf 'Clean-host 조건 위반: %s가 PATH에 있습니다.\n' \
                "$external_command" >&2
            exit 2
        fi
    done

    for forbidden_path in \
        "$HOME/GitHub/NU_nRF_Arduino_Platform" \
        "$HOME/NU_nRF_Arduino_Platform" \
        "$HOME/ncs" \
        "/opt/nordic/ncs"
    do
        if [[ -e "$forbidden_path" ]]
        then
            printf 'Clean-host 조건 위반: 개발 경로가 있습니다: %s\n' \
                "$forbidden_path" >&2
            exit 2
        fi
    done
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
    TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/nucode-clean.XXXXXX")"
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
    Serial.println("NUCODE UNIX CLEAN HOST");
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
    BLE.setLocalName("NU40-CLEAN");
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
    bleUart.begin("NU40-CLEAN-NUS");
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

INSTALLED_PLATFORM_ROOT="$DATA_ROOT/packages/nucode/hardware/zephyr/$PLATFORM_VERSION"

if [[ ! -d "$INSTALLED_PLATFORM_ROOT" ]]
then
    printf '요청 Platform 설치 경로가 없습니다: %s\n' \
        "$INSTALLED_PLATFORM_ROOT" >&2
    exit 2
fi

if [[ -n "$EXPECTED_CORE_VERSION" ]]
then
    SBOM_PATH="$INSTALLED_PLATFORM_ROOT/sbom.cdx.json"

    if [[ ! -f "$SBOM_PATH" ]] ||
        ! grep -A 2 '"name": "ArduinoCore-Zephyr"' "$SBOM_PATH" |
            grep -Fq "\"version\": \"$EXPECTED_CORE_VERSION\""
    then
        printf 'ArduinoCore-Zephyr Version 검증 실패: expected=%s\n' \
            "$EXPECTED_CORE_VERSION" >&2
        exit 2
    fi
fi

if [[ -n "$EXPECTED_TOOL_VERSION" ]] &&
    [[ ! -d "$DATA_ROOT/packages/nucode/tools/nu-zephyr-tools/$EXPECTED_TOOL_VERSION" ]]
then
    printf 'Host Tool Version 검증 실패: expected=%s\n' \
        "$EXPECTED_TOOL_VERSION" >&2
    exit 2
fi

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

if ((ENFORCE_CLEAN_HOST == 1))
then
    CLEAN_HOST_ENFORCED=true
else
    CLEAN_HOST_ENFORCED=false
fi

cat >"$EVIDENCE_PATH" <<EOF
{
  "schema_version": 1,
  "timestamp_utc": "$TIMESTAMP",
  "platform_version": "$PLATFORM_VERSION",
  "expected_core_version": "$EXPECTED_CORE_VERSION",
  "expected_tool_version": "$EXPECTED_TOOL_VERSION",
  "clean_host_enforced": $CLEAN_HOST_ENFORCED,
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

printf '\nNUCODE Platform %s Unix Clean-host 자동 시험 통과\n' \
    "$PLATFORM_VERSION"
printf 'Host     : %s/%s\n' "$HOST_OS" "$HOST_ARCH"
printf 'Compile  : Blink, Servo, Wire, SPI, ArduinoBLE, NUBleUart PASS\n'
printf 'Upload   : %s\n' "$UPLOAD_RESULT"
printf 'Evidence : %s\n' "$EVIDENCE_PATH"
printf '\n남은 수동 확인:\n'
printf '1. Arduino IDE Serial Monitor에서 1초 Heartbeat 확인\n'
printf '2. Button 1 Hold Reset으로 Safe Mode 진입과 정상 Reset 복귀\n'
printf '3. 두 NU40 사용 시 비선택 Board의 Build ID와 Sketch 불변 확인\n'
