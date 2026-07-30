# Platform 0.4.0-rc.1 GitHub 게시 절차

## 1. Text 변경 Push

GitHub Desktop에서 다음 추적 파일을 Commit하고 `main`에 Push한다.

```text
.gitattributes
README.md
Test-NuCleanPc.ps1
Test-NuUnixCleanHost.sh
release-assets/README.md
rc/v0.4.0-rc.1/README.md
rc/v0.4.0-rc.1/package_nucode_index.json
PUBLISH_v0.4.0-rc.1.md
RELEASE_NOTES_v0.4.0-rc.1.md
```

권장 Commit 메시지는 다음과 같다.

```text
Prepare Platform 0.4.0-rc.1 multi-host validation
```

`release-assets/v0.4.0-rc.1`은 `.gitignore` 대상이므로 GitHub Desktop에
나타나지 않는 것이 정상이다.

## 2. GitHub Pre-release 생성

1. `Releases > Draft a new release`를 연다.
2. Tag를 정확히 `v0.4.0-rc.1`로 만들고 최신 `main`을 선택한다.
3. 제목을 `NUCODE Zephyr Boards 0.4.0-rc.1`로 입력한다.
4. `RELEASE_NOTES_v0.4.0-rc.1.md` 내용을 설명으로 사용한다.
5. `Set as a pre-release`를 반드시 선택한다.
6. `release-assets/v0.4.0-rc.1`의 일곱 파일을 첨부한다.

```text
nucode-zephyr-0.4.0-rc.1.zip
nu-zephyr-tools-14.3.0-nu10-windows_amd64.zip
nu-zephyr-tools-14.3.0-nu10-linux_amd64.tar.gz
nu-zephyr-tools-14.3.0-nu10-linux_arm64.tar.gz
nu-zephyr-tools-14.3.0-nu10-macos_arm64.tar.gz
release-manifest.json
SHA256SUMS.txt
```

## 3. 게시 후 확인

다음 RC Index가 Platform `0.4.0-rc.1`, Tool `14.3.0-nu10`과 네 Host
Archive를 반환하는지 확인한다.

```text
https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/rc/v0.4.0-rc.1/package_nucode_index.json
```

공개 안정판 Index는 변경하지 않는다.

```text
https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/package_nucode_index.json
```

## 4. Clean-host Gate

Windows x86-64, Linux x86-64, Linux arm64와 macOS arm64에서 각각
Install→Compile→실제 NU40 Upload→Activation을 수행한다. Serial 출력과
Safe Mode/정상 복귀도 확인한다. 네 Host가 모두 통과하기 전에는 최종
Platform 0.4.0을 만들거나 RC를 일반 Release로 승격하지 않는다.
