# Platform 0.4.0-rc.1 시험 Index

이 디렉터리는 ArduinoCore-Zephyr 0.90.0/Loader ABI 0.4 통합 후보의
Multi-host Clean-host 시험 전용 Index를 제공한다.

```text
https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/rc/v0.4.0-rc.1/package_nucode_index.json
```

| 항목 | 값 |
|---|---|
| Platform | `0.4.0-rc.1` |
| Tool | `14.3.0-nu10` |
| ArduinoCore-Zephyr | `0.90.0` / `ad8741672fde649a98164fca969f1e05939fb31d` |
| Loader ABI | `0.4` / Export 450 |
| ABI Fingerprint | `FC8E6F2598637D8DB69F717C02D67221105E8A2FACABCE809315969168EC44E7` |
| 상태 | Pre-release, 외부 Multi-host Clean-host 대기 |

공개 안정판 Index `../../package_nucode_index.json`은 계속 Platform 0.3.1을
가리킨다. RC 시험 완료 전에는 이 파일로 안정판 Index를 대체하지 않는다.

## Windows x86-64

Arduino IDE를 설치한 Clean PC의 PowerShell에서 실행한다.

```powershell
Invoke-WebRequest `
    -UseBasicParsing `
    -Uri 'https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/Test-NuCleanPc.ps1' `
    -OutFile '.\Test-NuCleanPc.ps1'

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

.\Test-NuCleanPc.ps1 `
    -IndexUrl 'https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/rc/v0.4.0-rc.1/package_nucode_index.json' `
    -PlatformVersion '0.4.0-rc.1' `
    -ExpectedCoreVersion '0.90.0' `
    -ExpectedToolVersion '14.3.0-nu10' `
    -Port '<NU40 COM Port>' `
    -EnforceCleanHost
```

## Linux x86-64/arm64

Arduino CLI가 설치된 일반 사용자 Shell에서 실행한다. NU40의 CDC와
`NU40DK-UF2` MSC가 자동 Mount돼 있고 사용자에게 쓰기 권한이 있어야 한다.

```bash
curl -fL \
  -o Test-NuUnixCleanHost.sh \
  https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/Test-NuUnixCleanHost.sh

chmod +x Test-NuUnixCleanHost.sh

bash Test-NuUnixCleanHost.sh \
  --index-url https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/rc/v0.4.0-rc.1/package_nucode_index.json \
  --platform-version 0.4.0-rc.1 \
  --core-version 0.90.0 \
  --tool-version 14.3.0-nu10 \
  --port /dev/ttyACM0 \
  --enforce-clean-host
```

동일 명령을 Linux x86-64와 arm64에서 각각 실행한다.

## macOS Apple Silicon arm64

```bash
curl -fL \
  -o Test-NuUnixCleanHost.sh \
  https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/Test-NuUnixCleanHost.sh

chmod +x Test-NuUnixCleanHost.sh

bash Test-NuUnixCleanHost.sh \
  --index-url https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/rc/v0.4.0-rc.1/package_nucode_index.json \
  --platform-version 0.4.0-rc.1 \
  --core-version 0.90.0 \
  --tool-version 14.3.0-nu10 \
  --port /dev/cu.usbmodemNU40 \
  --enforce-clean-host
```

실제 Port 이름은 `ls /dev/cu.usbmodem*`으로 확인한다.

## 각 Host의 수동 확인

자동 시험 뒤 다음 항목을 확인한다.

1. Arduino IDE Serial Monitor에서 Clean-host 식별 문자열이 반복 출력된다.
2. Button 1을 누른 채 Reset해 `NU_STATUS.TXT`의 `Safe-Mode: Yes`를 확인한다.
3. Button을 놓고 Reset해 `Safe-Mode: No`와 기존 Sketch 정상 실행을 확인한다.
4. 두 NU40을 연결한 경우 선택하지 않은 보드의 Build ID와 Sketch가 바뀌지
   않았는지 확인한다.

Windows Evidence는 `%TEMP%\NUCODE-Clean\evidence`, Unix Evidence는 실행
출력의 `Evidence` 경로에 생성된다.
