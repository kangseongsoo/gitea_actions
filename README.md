# Gitea Actions 기반 온프레미스 CI/CD 구축 설계
단일 서버 · FastAPI · Python 3.11 · systemctl 서비스 배포 자동화
## 1. 개요
Gitea Actions를 이용하여 단일 서버 환경에서 FastAPI 기반 Python 서비스를 자동 배포하는 CI/CD 구조를 설계한 문서

## 2. 사용한 오픈소스
| 오픈소스                     | 역할                                   |
| ------------------------ | ------------------------------------ |
| **Gitea**                | 자체 호스팅 Git 서버                        |
| **Gitea Actions**        | CI/CD 자동화 엔진(GitHub Actions와 동일한 문법) |
| **Gitea Actions Runner** | workflow 실행기. 운영 서버에 설치              |
| **FastAPI**              | Python 서비스 프레임워크                     |
| **Uvicorn**              | FastAPI 실행 서버                        |
| **systemd**              | 서비스 실행/관리                            |
| **Python 3.11**          | 애플리케이션 런타임                           |

## 3. 아키텍처
'''
┌────────────────────────┐
│        Gitea           │
│ (main merge, tag push) │
└─────────────┬──────────┘
              │ Webhook(X)
              │ Actions Trigger(O)
┌─────────────▼──────────┐
│  Gitea Actions Engine   │
│ (.gitea/workflows/*.yml)│
└─────────────┬──────────┘
              │
              ▼
┌───────────────────────────────┐
│  운영 서버(= Actions Runner)   │
│  /home/milvus_server          │
│  git fetch + checkout tag     │
│  venv activate + pip install  │
│  systemctl restart            │
└───────────────────────────────┘
'''

## 4. 동작 흐름
1) 개발자가 main 브랜치에 merge
 - merge = push 이벤트
 - Gitea는 main push를 기록함 (하지만 배포는 태그 기반이므로 여기서는 배포 없음)
2) 개발자가 버전 태그 생성
'''
git tag v1.0.1
git push origin v1.0.1
'''
3) Gitea Actions가 자동 실행
 - refs/tags/v1.0.1 push 이벤트 감지
 - workflow 동작 시작
4) Runner가 운영 서버에서 자동으로 배포 실행
 - git fetch
 - git checkout tags/v1.0.1
 - systemctl restart

## 5. 배포 대상 서비스 정보
| 항목             | 값                                 |
| -------------- | --------------------------------- |
| 서비스 프레임워크      | FastAPI + Uvicorn                 |
| Python 버전      | 3.11                              |
| 배포 디렉토리        | `/home/milvus_server`             |
| 가상환경 경로        | `/home/py_env/milvus_server_env/` |
| systemd 서비스명   | `milvus_server.service`           |
| 소스 코드 git repo | Gitea self-hosted                 |

## 6. 디렉터리 구조
'''
/home/milvus_server
 ├── .gitea/workflows/deploy.yml    (레포지터리에 업로드 되어있어야함)
 ├── app/
 ├── requirements.txt
 ├── main.py
 └── ...

/home/py_env/milvus_server_env
 └── bin/activate

/usr/local/bin/deploy_milvus.sh
'''
## 7. systemctl 구성
milvus_server.service

## 8. 배포 스크립트
/usr/local/bin/deploy_milvus.sh

## 9. Gitea Actions Workflow
.gitea/workflows/deploy.yml
설명:
 - runs-on: self-hosted → Runner가 실행됨
 - “push된 태그”만 배포 트리거
 - Gitea Actions는 GitHub Actions와 동일 문법
 - Deploy 단계에서 스크립트 호출

## 10. Runner 설치 흐름
운영 서버에서 설치:
https://gitea.com/gitea/act_runner/releases 바이너리 다운가능
'''
/usr/local/bin/act_runner generate-config > config.yaml
/usr/local/bin/act_runner register 
'''
systemctl 등록 및 실행
Runner가 활성화되면:
 - Gitea Actions workflow 실행
 - 배포 스크립트 실행
 - systemctl restart 자동화

## 11. 전체 설계 요약
| 구분     | 내용                                    |
| ------ | ------------------------------------- |
| 배포 방식  | 태그 push 기반                            |
| CI/CD  | Gitea Actions                         |
| Runner | 운영 서버(=self-hosted runner)            |
| 배포 로직  | git checkout tags → systemctl restart |
| 가상환경   | systemctl 내부 activate                 |
| 서비스    | FastAPI / Python 3.11                 |




## 이슈
1. /etc/act_runner/config.yaml label 설정이 덮어씌워짐, 설정 변경 
'''
# 수정함함
  labels:
  - runner
  - linux
  - x86_64
'''
2. deploy.yml uses: actions/checkout@v3 도커기반실행모드에서만 쓸수있어서 제거


