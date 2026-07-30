# GitHub Release Upload Assets

버전별 디렉터리의 파일은 Git Commit 대상이 아니다. GitHub의
`EIDOSDATA/NUCODE_Arduino_Packages` 저장소에서 해당 Release를 만들고
디렉터리 안의 파일을 Release Asset으로 직접 업로드한다.

```text
release-assets/
├─ v0.3.0/
│  ├─ nucode-zephyr-0.3.0.zip
│  ├─ nu-zephyr-tools-14.3.0-nu8-windows_amd64.zip
│  ├─ release-manifest.json
│  └─ SHA256SUMS.txt
└─ v0.3.1-rc1/
   ├─ nucode-zephyr-0.3.1.zip
   ├─ nu-zephyr-tools-14.3.0-nu9-windows_amd64.zip
   ├─ nu-zephyr-tools-14.3.0-nu9-linux_amd64.tar.gz
   ├─ nu-zephyr-tools-14.3.0-nu9-linux_arm64.tar.gz
   ├─ nu-zephyr-tools-14.3.0-nu9-macos_arm64.tar.gz
   ├─ release-manifest.json
   └─ SHA256SUMS.txt
```

Release 제목은 `NUCODE Zephyr Boards 0.3.0`, Tag는 정확히 `v0.3.0`을 사용한다.
Draft/Prerelease가 아닌 일반 Release로 게시해야 Board Manager URL과 일치한다.

0.3.1 실기 검증용 Release 제목은 `NUCODE Zephyr Boards 0.3.1 RC1`, Tag는
정확히 `v0.3.1-rc1`을 사용하고 `Set as a pre-release`를 선택한다.
`RELEASE_NOTES_v0.3.1-rc1.md` 내용을 Release 설명으로 사용한다. 실제
Linux/macOS Gate가 끝나기 전에는 `package_nucode_index.json`을 수정하지 않는다.
