# Platform 0.4.0 GitHub 게시 절차

> 역사 기록: 이 문서는 0.4.0 당시 수동 정식 게시 절차다. 신규 Version에서는
> Pre-release Asset을 교체하지 않고 HIL 승인 후 자동 승격한다.

## 1. Release 준비 Text 변경 Push

GitHub Desktop에서 다음 추적 파일을 Commit하고 `main`에 Push한다.

```text
README.md
release-assets/README.md
staging/v0.4.0/README.md
staging/v0.4.0/package_nucode_index.json
PUBLISH_v0.4.0.md
RELEASE_NOTES_v0.4.0.md
```

권장 Commit 메시지는 다음과 같다.

```text
Prepare Platform 0.4.0 release
```

`release-assets/v0.4.0`은 `.gitignore` 대상이므로 GitHub Desktop에
나타나지 않는 것이 정상이다.

## 2. v0.4.0 일반 Release 생성

1. GitHub의 `Releases > Draft a new release`를 연다.
2. Tag를 정확히 `v0.4.0`으로 만들고 최신 `main`을 선택한다.
3. 제목을 `NUCODE Zephyr Boards 0.4.0`으로 입력한다.
4. `RELEASE_NOTES_v0.4.0.md` 내용을 설명으로 사용한다.
5. `Set as a pre-release`를 선택하지 않는다.
6. `Set as the latest release`를 선택한다.
7. `release-assets/v0.4.0`의 다음 일곱 파일을 첨부한다.

```text
nucode-zephyr-0.4.0.zip
nu-zephyr-tools-14.3.0-nu11-windows_amd64.zip
nu-zephyr-tools-14.3.0-nu11-linux_amd64.tar.gz
nu-zephyr-tools-14.3.0-nu11-linux_arm64.tar.gz
nu-zephyr-tools-14.3.0-nu11-macos_arm64.tar.gz
release-manifest.json
SHA256SUMS.txt
```

## 3. 공개 안정판 Index 승격

Release Asset 게시가 완료된 직후 다음 작업을 수행한다.

1. `staging/v0.4.0/package_nucode_index.json`을 Root의
   `package_nucode_index.json`으로 복사한다.
2. `README.md`의 현재 공개 Release를 Platform 0.4.0/Tool nu11로 바꾼다.
3. 변경을 Commit하고 `main`에 Push한다.
4. 공개 Root Index로 새 격리 설치가 되는지 마지막으로 확인한다.

Release Asset URL이 활성화되기 전에는 Root 안정판 Index 0.3.1을 변경하지
않는다.

## 게시 후 Asset/Index 무결성 Gate

Root Index를 Push하기 전에 GitHub Release API가 반환하는 각 Asset의
`size`와 `digest`를 Root Index의 `size`와 `checksum`에 대조한다. 로컬에서
재생성한 Archive가 아니라 실제 게시된 Asset을 기준으로 판정한다.

특히 `.tar.gz`는 Source가 같아도 재생성 Metadata에 따라 Byte Hash와 Size가
달라질 수 있으므로 다음 세 Host를 반드시 개별 확인한다.

1. `x86_64-pc-linux-gnu`
2. `aarch64-linux-gnu`
3. `arm64-apple-darwin`

불일치가 있으면 Asset과 Index 세대를 섞지 않는다. 이미 게시된 Asset이
정상이고 Manifest/SHA256SUMS와 일치하면 Asset을 교체하지 않고 Root Index를
게시 Asset 기준으로 교정한다.
