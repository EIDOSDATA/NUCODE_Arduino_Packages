# Platform 0.4.0 GitHub 게시 절차

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
