# NUCODE Zephyr Boards 0.4.0

ArduinoCore-Zephyr 0.90.0을 통합하고 Loader ABI를 0.4로 확장한
NU40-DK-Basic V2용 정식 Multi-host Release다.

## 주요 변경

- ArduinoCore-Zephyr 0.90.0 Commit
  `ad8741672fde649a98164fca969f1e05939fb31d` 직접 통합
- Loader ABI 0.4, Export 450개
- ABI 0.3 대비 `gmtime`, `k_mem_slab_init`, `k_mem_slab_free` 추가
- ABI Fingerprint
  `FC8E6F2598637D8DB69F717C02D67221105E8A2FACABCE809315969168EC44E7`
- GPIO Interrupt Callback의 Supervisor LLEXT MPU 실행 문맥 수정
- Windows x86-64, Linux x86-64/arm64, macOS Apple Silicon arm64 지원
- Native USB CDC+MSC/UF2와 COM↔MSC Device-ID 매칭
- Arduino IDE Build/Upload 진행률과 증분 Build Cache
- Servo 1.3.0과 ArduinoBLE/NUBleUart 유지
- Safe Mode, Watchdog Fault-loop Recovery, Journal/전원 차단 복구 유지

## 검증

- Full Boardless Gate
- Digital/Analog/Interrupt/Serial/Wire/SPI/Servo 실보드 회귀
- BLE NUS 연결과 양방향 Echo
- UF2 중단·Timeout·Reset 없는 재시도
- 네 Commit 중단 지점 전원 차단 복구와 Journal Slot 교대
- Native USB CDC+MSC 공존, 전원 재인가와 Safe Mode
- 두 NU40 양방향 COM↔MSC 선택과 비선택 보드 불변
- 두 보드 Loader 304 KiB Readback Hash 일치
- Windows x86-64, Linux x86-64/arm64, macOS arm64 RC Clean-host 실기
- 최종 0.4.0/nu11 Archive 정적 무결성 Gate
- 최종 Windows 격리 Install·Blink/Servo Compile·Upload·Activation·Serial

RC1에서 정식 0.4.0으로 승격하는 동안 Core, Loader, Sketch, Package와
Host Tool Source의 기능 변경은 없다. Platform Archive 내부 3,972개 파일과
Windows Tool 내부 3,625개 파일을 정규화 비교했고 차이는 Release 승인
Metadata와 Go VCS Build 정보뿐이다. Linux/macOS Toolchain 원본 SHA-256도
RC1과 동일하다.

## 호환성 안내

Platform 0.4.0은 Loader ABI 0.4를 사용한다. Platform 0.3.0/0.3.1의 Loader
ABI 0.3과 Fingerprint가 다르므로 기존 보드는 Platform 0.4.0 Sketch를
업로드하기 전에 외부 SWD로 Loader ABI 0.4를 한 번 설치해야 한다.

Loader 설치 이후 일반 Arduino Sketch Upload는 Native USB MSC/UF2를
사용하며 Loader 영역을 변경하지 않는다.

## 현재 미지원

- PDM: Platform 0.4.1에서 Core 0.90.0 API 기준으로 구현 예정
- RTC: Platform 0.4.2에서 구현 예정
- BLE Pairing/SMP/LTK/암호화: Platform 0.5.0에서 구현 예정
- macOS Intel x86-64
- 회사 출하용 USB VID/PID

MCUboot는 사용하지 않는다. Loader 최초 설치와 손상 복구는 외부 SWD로
수행하며 일반 Arduino Sketch Upload는 Native USB MSC/UF2로 처리한다.

## Arduino Boards Manager URL

```text
https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/package_nucode_index.json
```

## Release Assets

- `nucode-zephyr-0.4.0.zip`
- `nu-zephyr-tools-14.3.0-nu11-windows_amd64.zip`
- `nu-zephyr-tools-14.3.0-nu11-linux_amd64.tar.gz`
- `nu-zephyr-tools-14.3.0-nu11-linux_arm64.tar.gz`
- `nu-zephyr-tools-14.3.0-nu11-macos_arm64.tar.gz`
- `release-manifest.json`
- `SHA256SUMS.txt`

## SHA-256

- Platform:
  `B245567DD33A5CC4633FDF04967C247A99F027D568D658D3BCCEB6AB956D3104`
- Windows x86-64 Tool:
  `0667E078BAB2983708599DF311D62826D544BD1A36D3F1145C7F9B5675A029B7`
- Linux x86-64 Tool:
  `8B85062788835C0E0739BD25029DA3267227B7A44A1FD59BD0A19C3FC86912B1`
- Linux arm64 Tool:
  `1143CCF73D1313D64B823F926342BDD6D4000117C757E4A820EAB4BDB8EE0D51`
- macOS arm64 Tool:
  `E610134E78C4C7FEA080B6FD0560A9BE82F3E863ECAD1F0C9B19B36028B27A93`
- Package Index:
  `137411A46BECD48621A5C9552FF663ACA3048167EE8F9E53913433A92A77E9C8`
- Release Manifest:
  `FF5CD2B138F3C9D60B3DBFD703DF98834E83181635B8689BF13DE2A9AC925394`
