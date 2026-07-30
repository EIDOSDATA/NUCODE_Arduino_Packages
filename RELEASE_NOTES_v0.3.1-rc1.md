# NUCODE Zephyr Boards 0.3.1 RC1

Platform 0.3.1은 Linux와 macOS 지원을 검증하기 위한 사전 배포판이다. 정식
지원 승격 전까지 GitHub Release를 `Pre-release`로 게시한다.

## 지원 후보 Host

- Windows x86-64
- Linux x86-64
- Linux arm64
- macOS Apple Silicon arm64

macOS Intel x86-64는 지원 대상이 아니다.

## 주요 변경 사항

- 공통 Go 기반 ZSK/NUSK/UF2 Artifact 생성과 검증
- Linux `sysfs`, macOS I/O Registry 기반 CDC↔MSC Device Identity 탐색
- Host별 Zephyr SDK 1.0.1/GCC 14.3.0 최소 Tool Archive
- Linux/macOS Native USB MSC/UF2 Upload 경로
- Linux/macOS 실행 파일 권한 `0755` 보존
- Host별 Archive Manifest, CycloneDX SBOM과 License Notice
- Windows 0.3.0 기능 및 Loader ABI 0.3 계약 유지

## 현재 검증 결과

- Windows 격리 Board Manager 설치와 Blink/Servo Compile 통과
- Linux x86-64 Ubuntu 22.04 격리 설치와
  Blink/Servo/Wire/SPI/ArduinoBLE/NUBleUart Compile 통과
- Archive SHA-256, 크기, 단일 Root, Unix 실행 권한과 SBOM 검사 통과

## RC에서 남은 검증

- Linux x86-64 실제 NU40 UF2 Upload·Activation·Serial·Safe Mode
- Linux arm64 Clean-host 설치·Compile·실제 NU40 시험
- macOS arm64 Clean-host 설치·Compile·실제 NU40 시험
- 각 OS의 복수 NU40 CDC↔MSC 오선택 0건

RC 시험에는 다음 전용 Package Index를 사용한다.

```text
https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/package_nucode_index_0.3.1-rc1.json
```

정식 공개 Index인 `package_nucode_index.json`은 RC 시험이 끝날 때까지
Platform 0.3.0을 유지한다.
