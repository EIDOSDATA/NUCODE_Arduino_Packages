# NUCODE Zephyr Boards 0.4.0-rc.1

Platform 0.4.0의 Multi-host Clean-host 검증을 위한 Pre-release다. 일반
사용자용 안정판은 계속 0.3.1이다.

## 주요 변경

- ArduinoCore-Zephyr 0.90.0 Commit
  `ad8741672fde649a98164fca969f1e05939fb31d` 직접 통합
- Loader ABI 0.4, Export 450개
- ABI 0.3 대비 `gmtime`, `k_mem_slab_init`, `k_mem_slab_free` 추가
- ABI Fingerprint
  `FC8E6F2598637D8DB69F717C02D67221105E8A2FACABCE809315969168EC44E7`
- GPIO Interrupt Callback의 Supervisor LLEXT MPU 실행 문맥 수정
- Windows x86-64, Linux x86-64/arm64, macOS arm64 Host Tool 제공
- 기존 Native USB CDC+MSC/UF2, Servo, ArduinoBLE/NUBleUart, Safe Mode,
  Journal/전원 차단 복구와 IDE 진행률·증분 Build 유지

## 완료된 검증

- Full Boardless Gate
- Digital/Analog/Interrupt/Serial/Wire/SPI/Servo 실보드 회귀
- BLE NUS 연결과 양방향 Echo
- UF2 중단·Timeout·Reset 없는 재시도
- 네 Commit 중단 지점 복구와 Journal 교대
- Native USB 전원 재인가와 Safe Mode
- 두 NU40 양방향 COM↔MSC 선택, 비선택 보드 불변과 오선택 0건
- 두 보드 Loader 304 KiB Readback Hash 동일
- 네 Host Archive Hash/Root/권한/SBOM 정적 Gate
- Windows 개발 PC 격리 Install·Blink/Servo Compile·Upload·Serial

## 아직 완료되지 않은 검증

- 저장소와 NCS가 없는 외부 Windows x86-64 Clean-host
- 외부 Linux x86-64 Clean-host
- 외부 Linux arm64 Clean-host
- 외부 macOS Apple Silicon arm64 Clean-host

위 시험이 모두 통과하기 전에는 최종 0.4.0 Release로 지원하지 않는다.

## 현재 미지원

- PDM: Platform 0.4.1 예정
- RTC: Platform 0.4.2 예정
- BLE Pairing/SMP/LTK/암호화: Platform 0.5.0 예정
- macOS Intel x86-64
- 회사 출하용 USB VID/PID
