# NUCODE Arduino Packages

NUCODE 보드를 Arduino IDE Boards Manager로 설치하기 위한 공개 배포 저장소다.
제품 개발 소스는 포함하지 않으며 Platform/Host Tool Archive와 Package Index만
배포한다.

정식 배포 자산은 이 저장소에서 직접 빌드하거나 수동 교체하지 않는다. 제품 소스
저장소의 GitHub Actions가 불변 Pre-release를 게시하고, 실보드 HIL Evidence와
`production-release` 승인 후 같은 자산을 정식 Release로 승격한다.

## Arduino IDE 설치 URL

Arduino IDE의 `Preferences > Additional Boards Manager URLs`에 다음 주소를
추가한다.

```text
https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/package_nucode_index.json
```

Boards Manager에서 `NUCODE Zephyr Boards`를 검색해 설치한 뒤
`NU40-DK-Basic V2`를 선택한다.

## 지원 Host

- Windows x86-64
- Linux x86-64
- Linux arm64
- macOS Apple Silicon arm64

macOS Intel x86-64는 지원하지 않는다. macOS/Linux의 빈 Arduino Data/User
경로에서 설치·Compile·Upload를 자동 검사하려면 다음 스크립트를 사용한다.

```bash
bash Test-NuUnixCleanHost.sh \
  --index-url https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/package_nucode_index.json \
  --port /dev/cu.usbmodemNU40
```

Linux에서는 `--port /dev/ttyACM0`처럼 실제 CDC 장치 경로를 지정한다.
`--port`를 생략하면 실제 보드 없이 여섯 Sketch의 격리 설치·Compile까지만
검사한다.

## 현재 공개 Release

| 항목 | 값 |
|---|---|
| Release Tag | `v0.4.0` |
| Platform | `nucode:zephyr` 0.4.0 |
| Host Tool | `nu-zephyr-tools` 14.3.0-nu11 |
| 지원 Host | Windows x86-64, Linux x86-64/arm64, macOS arm64 |
| 지원 Board | NU40-DK-Basic V2 |

Board Manager Index는 현재 지원 Version인 0.4.0과 nu11만 제공한다. 이전 개발
Version은 Index에 누적하지 않는다.

## Platform 0.4.0 정식 배포

ArduinoCore-Zephyr 0.90.0/Loader ABI 0.4의 `0.4.0-rc.1`은 Windows x86-64,
Linux x86-64/arm64와 macOS Apple Silicon arm64의 Clean-host
Install→Compile→실기 Upload→Serial 시험을 모두 통과했다.

RC1에서 정식 Platform `0.4.0`/Tool `14.3.0-nu11`로 승격하는 동안 Core,
Loader, Sketch, Package와 Host Tool Source의 기능 변경은 없다. 최종
Archive는 정적 무결성 Gate와 Windows 격리 설치·Blink/Servo Compile·COM
매칭·UF2 Upload·Activation·CDC Serial 시험을 통과해 일반 Release로
승인됐다. GitHub `v0.4.0` 일반/latest Release와 Root Board Manager Index를
공개했으며, 공개 Index를 통한 설치·Compile·Upload·Serial 확인도 통과했다.

### 0.4.0 Unix Index Metadata 교정

최초 0.4.0 Root Index에는 게시 직전 다시 생성한 Unix Archive의 Hash/Size가
기록됐지만 GitHub Release에는 기능 Source가 같은 이전 Archive 세대가
게시됐다. Linux/macOS Arduino IDE의 Checksum 검사를 통과하도록 Root Index를
실제 GitHub Asset과 `SHA256SUMS.txt` 기준으로 교정했다.

교정 전에 설치를 시도한 Linux 사용자는 Arduino IDE를 종료하고
`~/.arduino15/staging/packages`의 nu11 Archive와
`~/.arduino15/package_nucode_index.json`을 제거한 뒤 다시 설치한다.

## 지원 정책

Platform 0.2.1/Tool 14.3.0-nu7은 지원 종료(EOL)됐으며 GitHub 배포와
Board Manager Index에서 제거했다. 신규 설치, 재배포, 결함 수정과 사용자
지원을 제공하지 않는다. Loader ABI 0.2인 0.2.1은 현재 ABI 0.4
Loader/Platform과 호환되지 않는다.

## v0.4.0 내용

0.4.0은 ArduinoCore-Zephyr 0.90.0과 Loader ABI 0.4를 사용하고 356 KiB
Sketch 계약, Servo 1.3.0, Arduino IDE 진행률·증분 Build와 네 Host 지원을
유지한다.

- Arduino IDE Native USB Serial Monitor DTR 기본값 `on`
- Build Terminal 진행률 5~100%, Upload 진행률 2~100%
- MMD Object/Artifact Cache 기반 증분 Build
- Loader ABI 0.4/Export 450개
- Loader ABI Fingerprint `FC8E6F...EC44E7`
- `user_sketch`와 `sketch_staging` 각 356 KiB
- 128 KiB LLEXT Heap
- Arduino Sketch Stack 16 KiB
- General Heap 16 KiB
- BT RX Stack 4 KiB
- Supervisor Preemptive Priority 14
- WDT/Reset Reason/Retention Counter 기반 자동 Fault-loop Recovery
- ArduinoBLE/NUBleUart 비암호화 Peripheral/NUS
- Servo 1.3.0
- MSC `INDEX.HTM`의 [NUWORKS](https://nuworks.io/en) 홈페이지 연결

MCUboot는 사용하지 않는다. Loader 최초 설치와 손상 복구는 SWD로 수행하고,
일반 Arduino Sketch Upload는 Native USB MSC/UF2로 처리한다.

PDM, RTC, Pairing/SMP/LTK와 암호화 BLE 연결은 0.4.0에서 지원하지 않는다.
Arduino IDE가
FQBN/COM별 `dtr=off`를 저장한 경우 IDE를 종료하고 설치된
`tools/Repair-NuArduinoSerialMonitor.ps1`을 한 번 실행해야 한다.

Platform Archive에는 Arduino Core/API, NU40 Variant, Loader EDK와
`boards.txt`/`platform.txt`/`programmers.txt`가 포함된다. Windows Tool
Host별 Tool Archive에는 ARM Zephyr GCC와 공통 `nu-tool`이 포함된다.
일반 `.ino` Compile과 Native USB MSC/UF2 Upload에는 NCS, Zephyr SDK, Go 또는
별도 ARM GCC를 설치하지 않는다.

Nordic `nrfutil`은 재배포 조건 때문에 이 저장소와 Tool Archive에 포함하지 않는다.
외부 SWD로 Loader를 최초 설치하거나 복구할 때만
[Nordic 공식 nRF Util](https://www.nordicsemi.com/Products/Development-tools/nRF-Util)을
별도로 설치하고 다음 명령으로 Device Command를 추가한다.

```powershell
nrfutil install device
```

Arduino IDE의 `Burn Bootloader`는 `%USERPROFILE%\.nrfutil`,
`NRFUTIL_HOME`, `PATH` 순서로 공식 설치본을 찾는다. NU40의 일반 Arduino
Upload는 SWD가 아니라 Native USB MSC/UF2 경로를 사용한다.

## 배포 자산

GitHub `v0.4.0` Release에는 다음 일곱 파일을 제공한다.

```text
nucode-zephyr-0.4.0.zip
nu-zephyr-tools-14.3.0-nu11-windows_amd64.zip
nu-zephyr-tools-14.3.0-nu11-linux_amd64.tar.gz
nu-zephyr-tools-14.3.0-nu11-linux_arm64.tar.gz
nu-zephyr-tools-14.3.0-nu11-macos_arm64.tar.gz
release-manifest.json
SHA256SUMS.txt
```

대용량 Archive는 Git 이력에 Commit하지 않는다. 현재 정식 절차에서는 제품 소스
저장소의 `Build and publish pre-release` Workflow가 GitHub Release Asset으로
게시한다. `release-assets/`는 과거 수동 배포 기록용이며 신규 배포 입력으로
사용하지 않는다.

## Release 운영

신규 Version 게시와 승격은 다음 순서를 따른다.

1. 제품 소스 저장소에서 후보 계약과 Release Note를 Commit한다.
2. GitHub Actions가 네 Host Archive를 빌드·시험하고 Pre-release와
   `staging/v<version>/package_nucode_index.json`을 게시한다.
3. 운영자가 게시된 후보를 실제 NU40에서 시험하고 HIL Evidence를 만든다.
4. 별도 승인자가 Evidence를 승인한다.
5. `production-release` Environment 승인 뒤 Actions가 동일 Asset을 정식/latest로
   승격하고 Root Index를 갱신한다.
6. 게시 완료 후 제품 소스 저장소의 배포 마감 도구로 Gate를 다시 잠근다.

GitHub Release Asset을 같은 Tag에서 덮어쓰지 않는다. 실패 후보는 FAIL Evidence로
보존하고 더 큰 새 Version을 만든다. Root Index 복구가 필요하면 제품 소스
저장소의 `Roll back stable package index` Workflow를 사용한다.

상세 명령과 사람 승인 절차는 제품 소스 저장소의
[Release 운영자 독립 실행 가이드](https://github.com/EIDOSDATA/NU_nRF_Arduino_Platform/blob/main/00_Docs/03_%EA%B0%9C%EB%B0%9C%EC%9E%90_%EA%B0%80%EC%9D%B4%EB%93%9C/10_Release_%EC%9A%B4%EC%98%81%EC%9E%90_%EB%8F%85%EB%A6%BD_%EC%8B%A4%ED%96%89_%EA%B0%80%EC%9D%B4%EB%93%9C.md)를 따른다.

## 별도 Windows Clean PC 시험

일반 Compile/USB Upload 시험 PC에는 Arduino IDE만 설치한다. NCS, Zephyr SDK,
Go, ARM GCC와 제품 소스 저장소가 없어야 한다. 외부 SWD `Burn Bootloader`는
별도 Provisioning 시험이며 공식 `nrfutil`과 J-Link 연결이 추가로 필요하다.

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

.\Test-NuCleanPc.ps1 `
    -Port 'COM10' `
    -EnforceCleanHost
```

0.4.0 공개 회귀는 Version과 Core/Tool 기대값을 함께 고정한다.

```powershell
.\Test-NuCleanPc.ps1 `
    -IndexUrl 'https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/package_nucode_index.json' `
    -PlatformVersion '0.4.0' `
    -ExpectedCoreVersion '0.90.0' `
    -ExpectedToolVersion '14.3.0-nu11' `
    -Port 'COM10' `
    -EnforceCleanHost
```

스크립트는 Windows 기본 Windows PowerShell 5.1과 PowerShell 7에서 실행할 수
있다. GCC가 `stderr`로 출력하는 진단은 모두 수집한 뒤 실제 종료 코드로
성공 여부를 판정한다. 기본 작업 경로는 Windows 장경로가 비활성화된 PC도
지원하도록 `%TEMP%\NUCODE-Clean`을 사용한다. `-BuildId`를 생략하면 현재 UTC
Unix Time을 사용해 기존 Sketch와 다른 실제 Activation을 유도한다.

스크립트는 빈 Arduino Data/User 경로에 공개 Package를 설치하고 다음을 검사한다.

- Board Manager Platform/Tool Download와 SHA-256
- `nucode:zephyr:nu40dk_v2` FQBN
- Serial Discovery
- Blink Compile과 UF2 Export
- Servo Compile·Link와 UF2 Export
- NCS/제품 저장소 경로 비참조
- 선택 Port의 Native USB MSC/UF2 Upload
- Upload 후 DTR Native USB Serial 출력

증거는 `%TEMP%\NUCODE-Clean\evidence\clean-pc-evidence.json`에
기록된다.

Smart App Control이 강제된 PC에서 일반 Compile/UF2 Upload는 지원한다. 외부
SWD `Burn Bootloader`는 현재 미서명 `nu-tool`과 사용자 설치 `nrfutil`을
실행하므로 같은 정책에서 차단될 수 있다. 이 경로는 Loader 최초 설치용
Provisioning PC에서 별도로 검증한다.

## 무결성

Release Asset의 크기와 SHA-256은 `package_nucode_index.json`,
`release-manifest.json`과 `SHA256SUMS.txt`가 동일해야 한다. Checksum이 다르면
Release를 게시하거나 설치 URL을 배포하지 않는다.
