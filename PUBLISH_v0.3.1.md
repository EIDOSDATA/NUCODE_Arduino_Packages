# Platform 0.3.1 GitHub 게시 절차

## 1. Git Commit과 Push

GitHub Desktop에서 표시되는 0.3.1 Text 변경을 Commit하고 `main`에 Push한다.
Commit 메시지는 다음을 권장한다.

```text
Platform 0.3.1 Multi-Host Release
```

`release-assets/v0.3.1`은 `.gitignore` 대상이므로 GitHub Desktop에 나타나지
않는 것이 정상이다.

## 2. GitHub Release 생성

1. `Releases > Draft a new release`를 연다.
2. Tag를 정확히 `v0.3.1`로 만들고 Target을 최신 `main`으로 지정한다.
3. 제목을 `NUCODE Zephyr Boards 0.3.1`로 입력한다.
4. `RELEASE_NOTES_v0.3.1.md`의 내용을 설명으로 사용한다.
5. `Set as a pre-release`는 선택하지 않는다.
6. 로컬 `release-assets/v0.3.1`의 다음 일곱 파일을 직접 첨부한다.

```text
nucode-zephyr-0.3.1.zip
nu-zephyr-tools-14.3.0-nu9-windows_amd64.zip
nu-zephyr-tools-14.3.0-nu9-linux_amd64.tar.gz
nu-zephyr-tools-14.3.0-nu9-linux_arm64.tar.gz
nu-zephyr-tools-14.3.0-nu9-macos_arm64.tar.gz
release-manifest.json
SHA256SUMS.txt
```

일곱 파일의 업로드가 끝난 뒤 일반 Release로 게시한다.

## 3. 게시 직후 확인

다음 URL이 Platform 0.3.1과 Tool 14.3.0-nu9을 반환하는지 확인한다.

```text
https://raw.githubusercontent.com/EIDOSDATA/NUCODE_Arduino_Packages/main/package_nucode_index.json
```

Arduino IDE에서 기존 Additional Boards Manager URL을 그대로 사용해
`NUCODE Zephyr Boards 0.3.1`이 표시되는지 확인한다.
