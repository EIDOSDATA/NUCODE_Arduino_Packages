# GitHub Release Assets

이 디렉터리는 과거 수동 게시 때 사용한 로컬 임시 자산 위치다. `.gitignore`
대상이며 신규 Release의 공식 입력이 아니다.

현재 공식 자산은 제품 소스 저장소의 GitHub Actions가 다음과 같이 관리한다.

```text
Source Commit
→ Full Boardless Gate
→ Multi-host Archive 생성
→ Clean-host Compile Gate
→ GitHub Pre-release Asset 게시
→ 실제 보드 HIL Evidence와 사람 승인
→ 동일 Asset의 정식/latest 승격
```

운영자는 이 디렉터리의 파일을 GitHub Release에 직접 올리거나, 이미 게시된 Tag의
Asset을 교체하면 안 된다. 후보 결함은 FAIL Evidence로 남기고 더 큰 새 Version을
사용한다. 세부 절차는 제품 소스 저장소의
[Release 운영자 독립 실행 가이드](https://github.com/EIDOSDATA/NU_nRF_Arduino_Platform/blob/main/00_Docs/03_%EA%B0%9C%EB%B0%9C%EC%9E%90_%EA%B0%80%EC%9D%B4%EB%93%9C/10_Release_%EC%9A%B4%EC%98%81%EC%9E%90_%EB%8F%85%EB%A6%BD_%EC%8B%A4%ED%96%89_%EA%B0%80%EC%9D%B4%EB%93%9C.md)를 따른다.
