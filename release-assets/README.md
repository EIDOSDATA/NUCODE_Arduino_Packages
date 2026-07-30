# GitHub Release Upload Assets

버전별 디렉터리의 파일은 Git Commit 대상이 아니다. GitHub의
`EIDOSDATA/NUCODE_Arduino_Packages` 저장소에서 해당 Release를 만들고
디렉터리 안의 파일을 Release Asset으로 직접 업로드한다.

```text
release-assets/
├─ v0.3.1/
│  └─ 공개 안정판 자산
└─ v0.4.0-rc.1/
   ├─ nucode-zephyr-0.4.0-rc.1.zip
   ├─ nu-zephyr-tools-14.3.0-nu10-windows_amd64.zip
   ├─ nu-zephyr-tools-14.3.0-nu10-linux_amd64.tar.gz
   ├─ nu-zephyr-tools-14.3.0-nu10-linux_arm64.tar.gz
   ├─ nu-zephyr-tools-14.3.0-nu10-macos_arm64.tar.gz
   ├─ release-manifest.json
   └─ SHA256SUMS.txt
```

0.4.0 RC Release 제목은 `NUCODE Zephyr Boards 0.4.0-rc.1`, Tag는 정확히
`v0.4.0-rc.1`을 사용하고 GitHub의 **Pre-release**로 게시한다. 외부
Multi-host Clean-host Gate 전에는 일반 Release 또는 최종 0.4.0으로
승격하지 않는다.

과거 안정판 자산 구성은 다음과 같다.

```text
release-assets/v0.3.1/
   ├─ nucode-zephyr-0.3.1.zip
   ├─ nu-zephyr-tools-14.3.0-nu9-windows_amd64.zip
   ├─ nu-zephyr-tools-14.3.0-nu9-linux_amd64.tar.gz
   ├─ nu-zephyr-tools-14.3.0-nu9-linux_arm64.tar.gz
   ├─ nu-zephyr-tools-14.3.0-nu9-macos_arm64.tar.gz
   ├─ release-manifest.json
   └─ SHA256SUMS.txt
```

Release 제목은 `NUCODE Zephyr Boards 0.3.1`, Tag는 정확히 `v0.3.1`을
사용한다. `RELEASE_NOTES_v0.3.1.md` 내용을 설명으로 사용하고
Draft/Prerelease가 아닌 일반 Release로 게시한다.
