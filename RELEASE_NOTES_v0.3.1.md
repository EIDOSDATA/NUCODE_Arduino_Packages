# NUCODE Zephyr Boards 0.3.1

Platform 0.3.1은 NU40-DK-Basic V2의 Arduino Board Package를 Windows뿐 아니라
Linux와 macOS까지 확장한 정식 Multi-Host Release다.

## 지원 Host

- Windows x86-64
- Linux x86-64
- Linux arm64
- macOS Apple Silicon arm64

macOS Intel x86-64는 지원 대상이 아니다.

## 주요 변경 사항

- 공통 Go 기반 LLEXT/ZSK/NUSK/UF2 Artifact 생성과 검증
- Linux `sysfs`, macOS I/O Registry 기반 CDC↔MSC Device Identity 탐색
- Linux/macOS Native USB MSC/UF2 Upload
- Host별 Zephyr SDK 1.0.1/GCC 14.3.0 최소 Tool Archive
- Unix 실행 파일 권한 `0755` 보존
- Host별 Archive Manifest, CycloneDX SBOM과 License Notice
- Windows 0.3.0의 Loader ABI 0.3, Servo와 Arduino IDE 기능 유지

## Multi-Host 검증

Windows x86-64, Linux x86-64/arm64와 macOS arm64에서 다음 경로를 통과했다.

```text
Board Manager 설치
→ Clean Compile
→ 실제 NU40 USB Upload
→ Sketch Activation
→ Arduino Serial Monitor
→ Button 1 Safe Mode 진입·정상 복귀
```

## 유지되는 주요 기능

- Loader ABI 0.3, Export 447개
- `user_sketch`와 `sketch_staging` 각 356 KiB
- Servo 1.3.0
- ArduinoBLE/NUBleUart 비암호화 Peripheral/NUS
- Build 진행률 5~100%, Upload 진행률 2~100%
- MMD Object/Artifact Cache 기반 증분 Build
- Native USB CDC+MSC와 UF2 Sketch Upload
- MSC `INDEX.HTM`의 [NUWORKS](https://nuworks.io/en) 연결
- WDT/Reset Reason 기반 자동 Fault-loop Recovery와 Safe Mode

## 현재 제한

- PDM Microphone은 Platform 0.3.2에서 지원할 예정이다.
- BLE Pairing/SMP/LTK와 암호화 연결은 Platform 0.4.0에서 지원할 예정이다.
- 회사 출하용 USB VID/PID는 별도 확정 전이며 현재 ID는 개발/HIL용이다.
- MCUboot는 사용하지 않는다. Loader 최초 설치와 복구는 외부 SWD를 사용한다.

## 지원 종료

Platform 0.2.1/Tool 14.3.0-nu7은 지원 종료(EOL)됐으며 GitHub 배포와
Board Manager Index에서 제거했습니다. 0.2.1은 현재 Loader ABI 0.3
제품과 호환되지 않으며 신규 설치, 결함 수정 및 사용자 지원을 제공하지
않습니다.

## Board Manager URL

```text
https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/package_nucode_index.json
```
