# SB3 Security Application

Spring Boot 3 기반의 보안 애플리케이션입니다. AWS 인프라를 테라폼으로 구성하고 GitHub Actions를 통해 자동 배포됩니다.

## 사전 요구사항

- AWS 계정
- GitHub 계정
- SSH 키 페어 (EC2 인스턴스 접근용)

## AWS 설정

1. IAM 역할 생성
   - GitHub Actions에서 사용할 IAM 역할을 생성합니다.
   - 필요한 권한:
     - EC2 전체 접근
     - VPC 전체 접근
     - CloudWatch 로그 전체 접근

2. GitHub Secrets 설정
   - `AWS_ACCOUNT_ID`: AWS 계정 ID
   - `EC2_SSH_KEY`: EC2 인스턴스 접근용 SSH 프라이빗 키

## 프로젝트 구조

```
.
├── .github/
│   └── workflows/
│       └── deploy.yml      # GitHub Actions 워크플로우
├── main.tf                 # 테라폼 인프라 구성
└── README.md              # 프로젝트 문서
```

## 인프라 구성

테라폼을 통해 다음과 같은 AWS 리소스가 생성됩니다:

- VPC (10.0.0.0/16)
- 퍼블릭 서브넷 (10.0.1.0/24)
- 인터넷 게이트웨이
- 라우트 테이블
- 보안 그룹 (SSH, HTTP, HTTPS 허용)
- EC2 인스턴스 (Amazon Linux 2023, t2.micro)

## 배포 프로세스

1. GitHub 저장소에 코드 푸시
2. GitHub Actions 워크플로우 실행
3. 테라폼을 통한 인프라 생성/업데이트
4. EC2 인스턴스에 애플리케이션 배포
5. systemd 서비스로 애플리케이션 실행

## 애플리케이션 접근

배포가 완료된 후, EC2 인스턴스의 퍼블릭 IP를 통해 애플리케이션에 접근할 수 있습니다:

```bash
# SSH 접속
ssh ec2-user@<EC2_PUBLIC_IP>

# 애플리케이션 상태 확인
sudo systemctl status sb3-security

# 로그 확인
sudo journalctl -u sb3-security -f
```

## 문제 해결

1. 배포 실패 시
   - GitHub Actions 로그 확인
   - EC2 인스턴스 상태 확인
   - systemd 서비스 로그 확인

2. SSH 접속 문제
   - 보안 그룹의 SSH 포트(22) 허용 확인
   - SSH 키 페어 설정 확인

3. 애플리케이션 실행 문제
   - Java 설치 확인
   - systemd 서비스 설정 확인
   - 애플리케이션 로그 확인

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 