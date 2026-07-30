# Platform 0.4.0 Root Index 승격 원본

이 디렉터리는 GitHub `v0.4.0` 일반 Release Asset 게시 직후 저장소 Root의
`package_nucode_index.json`으로 승격할 최종 Index를 보관한다.

| 항목 | 값 |
|---|---|
| Platform | `0.4.0` |
| Tool | `14.3.0-nu11` |
| ArduinoCore-Zephyr | `0.90.0` / `ad8741672fde649a98164fca969f1e05939fb31d` |
| Loader ABI | `0.4` / Export 450 |
| ABI Fingerprint | `FC8E6F2598637D8DB69F717C02D67221105E8A2FACABCE809315969168EC44E7` |
| 지원 Host | Windows x86-64, Linux x86-64/arm64, macOS arm64 |
| Release 판정 | RC1 네 Host PASS, 정식 Release 승인 |

`0.4.0-rc.1`은 네 Host의 Clean-host Install→Compile→실기 Upload→Activation→
Serial을 통과했다. RC1에서 정식 0.4.0으로 승격하는 동안 Core, Loader,
Sketch, Package와 Host Tool Source의 기능 변경은 없다. 정식 Archive는 정적
무결성 Gate와 Windows 격리 HIL을 추가로 통과했다.

## 승격 순서

1. GitHub Tag `v0.4.0`의 일반 Release를 만든다.
2. `release-assets/v0.4.0`의 일곱 Asset을 모두 게시한다.
3. Asset URL이 실제 Download되는지 확인한다.
4. 이 디렉터리의 `package_nucode_index.json`을 저장소 Root로 복사한다.
5. Root Index와 `README.md`를 Commit하고 `main`에 Push한다.
6. 공개 Root Index로 격리 Install·Compile을 한 번 확인한다.

Asset이 공개되기 전 Root Index를 먼저 승격하면 Arduino Boards Manager
Download가 실패하므로 순서를 바꾸지 않는다.
