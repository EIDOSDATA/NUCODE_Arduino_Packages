# Platform 0.3.1 RC1 게시 및 실기 시험

## 1. 게시 순서

1. GitHub Desktop에서 다음 Text 파일을 Commit하고 `main`에 Push한다.

   - `package_nucode_index_0.3.1-rc1.json`
   - `RELEASE_NOTES_v0.3.1-rc1.md`
   - `TEST_GUIDE_v0.3.1-rc1.md`
   - `Test-NuUnixCleanHost.sh`
   - `README.md`
   - `release-assets/README.md`

2. GitHub 저장소의 `Releases > Draft a new release`를 연다.
3. Tag를 정확히 `v0.3.1-rc1`로 만들고 Target을 `main`으로 지정한다.
4. 제목을 `NUCODE Zephyr Boards 0.3.1 RC1`로 입력한다.
5. `RELEASE_NOTES_v0.3.1-rc1.md`의 내용을 설명으로 사용한다.
6. `Set as a pre-release`를 선택한다.
7. 로컬 `release-assets/v0.3.1-rc1`의 다음 일곱 파일을 첨부한다.

```text
nucode-zephyr-0.3.1.zip
nu-zephyr-tools-14.3.0-nu9-windows_amd64.zip
nu-zephyr-tools-14.3.0-nu9-linux_amd64.tar.gz
nu-zephyr-tools-14.3.0-nu9-linux_arm64.tar.gz
nu-zephyr-tools-14.3.0-nu9-macos_arm64.tar.gz
release-manifest.json
SHA256SUMS.txt
```

대용량 자산은 `.gitignore` 대상이므로 GitHub Desktop 변경 목록에 나타나지
않는다. 반드시 GitHub Release 화면에서 직접 첨부한다.

## 2. 게시 직후 확인

다음 RC Index가 HTTP 200과 올바른 JSON을 반환해야 한다.

```text
https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/package_nucode_index_0.3.1-rc1.json
```

Release 화면에 일곱 자산이 모두 있고 파일 크기가
`release-manifest.json`과 같아야 한다. `SHA256SUMS.txt` 기준으로 다운로드
파일을 다시 검증한다.

macOS:

```bash
shasum -a 256 -c SHA256SUMS.txt
```

Linux:

```bash
sha256sum -c SHA256SUMS.txt
```

`SHA256SUMS.txt`의 RC Index 행은 저장소 Root에서 받은
`package_nucode_index_0.3.1-rc1.json`과 함께 검사한다.

## 3. macOS arm64 Clean-host

`uname -m` 결과가 `arm64`인지 먼저 확인한다. Intel Mac은 시험 대상이 아니다.

1. Arduino IDE를 설치한다.
2. `Settings > Additional Boards Manager URLs`에 RC Index URL을 추가한다.
3. Boards Manager에서 `NUCODE Zephyr Boards 0.3.1`을 설치한다.
4. `NU40-DK-Basic V2`와 실제 `/dev/cu.usbmodem*` Port를 선택한다.
5. Blink, Servo, Wire, SPI, ArduinoBLE, NUBleUart를 Compile한다.
6. Blink를 Upload하고 LED, Activation과 Serial Monitor 출력을 확인한다.
7. Button 1을 누른 Reset으로 Safe Mode 진입 후 정상 Reset 복귀를 확인한다.
8. 두 NU40이 있으면 선택하지 않은 보드의 Build ID와 Sketch가 바뀌지 않는지
   양방향으로 확인한다.

내부 RC에서 macOS가 미서명 실행 파일을 차단하면 설치된 다음 Tool 디렉터리의
Quarantine 상태를 증거와 함께 기록한다.

```bash
xattr -lr "$HOME/Library/Arduino15/packages/nucode/tools/nu-zephyr-tools/14.3.0-nu9"
```

Gatekeeper 우회는 원인 확인용 내부 RC에만 사용한다. 우회가 필요했다면
0.3.1 정식 승격 전에 배포 정책과 사용자 오류 안내를 확정한다.

## 4. Linux amd64/arm64 Clean-host

`uname -m`이 amd64에서는 `x86_64`, arm64에서는 `aarch64`인지 확인한다.

1. Arduino IDE를 설치한다.
2. 사용자가 Serial Port에 접근할 수 있도록 배포판의 USB/Serial 권한을
   설정하고 다시 로그인한다.
3. RC Index로 `NUCODE Zephyr Boards 0.3.1`을 설치한다.
4. Blink, Servo, Wire, SPI, ArduinoBLE, NUBleUart를 Compile한다.
5. 실제 `/dev/ttyACM*` Port를 선택해 Upload·Activation·Serial을 확인한다.
6. Safe Mode와 두 보드 오선택 0건을 macOS와 같은 기준으로 확인한다.

Arduino CLI가 설치되어 있으면 다음 자동 시험을 사용할 수 있다.

```bash
bash Test-NuUnixCleanHost.sh \
  --index-url https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/package_nucode_index_0.3.1-rc1.json \
  --port /dev/ttyACM0
```

macOS에서는 Port만 실제 `/dev/cu.usbmodem*`로 바꾼다. 실행 결과의
`unix-clean-host-evidence.json`을 보존한다.

## 5. 정식 0.3.1 승격 조건

- Linux amd64 실제 보드 PASS
- Linux arm64 실제 보드 PASS
- macOS arm64 실제 보드 PASS
- Windows x86-64 최종 비퇴행 PASS
- 각 OS의 Compile·UF2 Upload·Activation·Serial·Safe Mode PASS
- 복수 보드 오선택 0건
- macOS Gatekeeper와 Linux USB 권한 오류 처리 확정

모두 통과한 뒤에만 `v0.3.1` 일반 Release를 만들고 정식
`package_nucode_index.json`을 0.3.1로 교체한다.
