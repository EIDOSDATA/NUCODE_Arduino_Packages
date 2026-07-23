# NUCODE Arduino Packages

NUCODE 보드를 Arduino IDE Boards Manager로 설치하기 위한 공개 배포 저장소다.
제품 개발 소스는 포함하지 않으며 Platform/Host Tool Archive와 Package Index만
배포한다.

## Arduino IDE 설치 URL

Arduino IDE의 `Preferences > Additional Boards Manager URLs`에 다음 주소를
추가한다.

```text
https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/package_nucode_index.json
```

Boards Manager에서 `NUCODE Zephyr Boards`를 검색해 설치한 뒤
`NU40-DK-Basic V2`를 선택한다.

## 현재 공개 Release

| 항목 | 값 |
|---|---|
| Release Tag | `v0.2.1` |
| Platform | `nucode:zephyr` 0.2.1 |
| Windows Tool | `nu-zephyr-tools` 14.3.0-nu7 |
| 지원 Host | Windows x86-64 |
| 지원 Board | NU40-DK-Basic V2 |

Board Manager Index는 현재 지원 Version인 0.2.1과 nu7만 제공한다. 이전 개발
Version은 Index에 누적하지 않는다.

## v0.2.1 내용

0.2.1은 0.2.0 기능을 유지하면서 월요일 데모 안정화 설정을 추가한다.

- Arduino IDE Native USB Serial Monitor DTR 기본값 `on`
- Loader ABI 0.2/Export 406개
- Loader ABI Fingerprint `A5724F...18002`
- `user_sketch`와 `sketch_staging` 각 192 KiB
- 128 KiB LLEXT Heap
- Arduino Sketch Stack 16 KiB
- General Heap 16 KiB
- BT RX Stack 4 KiB
- Supervisor Preemptive Priority 14
- WDT/Reset Reason/Retention Counter 기반 자동 Fault-loop Recovery
- ArduinoBLE/NUBleUart 비암호화 Peripheral/NUS

MCUboot는 사용하지 않는다. Loader 최초 설치와 손상 복구는 SWD로 수행하고,
일반 Arduino Sketch Upload는 Native USB MSC/UF2로 처리한다.

Pairing/SMP/LTK와 암호화 BLE 연결은 0.2.1에서 지원하지 않는다. Arduino IDE가
FQBN/COM별 `dtr=off`를 저장한 경우 IDE를 종료하고 설치된
`tools/Repair-NuArduinoSerialMonitor.ps1`을 한 번 실행해야 한다.

Platform Archive에는 Arduino Core/API, NU40 Variant, Loader EDK와
`boards.txt`/`platform.txt`/`programmers.txt`가 포함된다. Windows Tool
Archive에는 ARM Zephyr GCC와 SWD Provisioning용 `nu-tool`이 포함된다.
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

GitHub `v0.2.1` Release에는 다음 네 파일을 제공한다.

```text
nucode-zephyr-0.2.1.zip
nu-zephyr-tools-14.3.0-nu7-windows_amd64.zip
release-manifest.json
SHA256SUMS.txt
```

대용량 ZIP은 Git 이력에 Commit하지 않는다. `release-assets/v0.2.1`은
`.gitignore` 대상이며 GitHub Release에만 업로드한다.

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
- NCS/제품 저장소 경로 비참조
- 선택 Port의 Native USB MSC/UF2 Upload

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
