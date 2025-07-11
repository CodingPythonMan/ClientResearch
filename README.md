# ClientResearch

![Godot](https://img.shields.io/badge/Godot-Client-lightblue.svg) ![TCP](https://img.shields.io/badge/Network-TCP-orange.svg)

**[GameServer 프로젝트](https://github.com/CodingPythonMan/GameServer)와 연동되는 Godot 클라이언트**를 개발하기 위해 만든 저장소입니다.  
서버 개발 시 눈으로도 확인하고 테스트하기 위해 최소 기능의 클라이언트를 만드는 것이 목적입니다.

## 🧭 프로젝트 개요

GodotClient는 **Godot 엔진으로 제작된 TCP 기반 테스트 클라이언트**입니다.  
IOCP 서버와의 통신을 통해 실시간 멀티플레이 테스트를 진행할 수 있으며,  
그래픽보다 **네트워크 및 동기화 테스트에 중점**을 두고 있습니다.

- **Godot 4.4 사용**
- **TCP 소켓을 통한 서버와의 직접 통신**
- **서버에서의 위치 및 상태 동기화 확인 가능**
- **클라이언트 간 충돌 동기화 확인**
- **GUI 및 시각적 요소는 최소화**

## 🛠 기술 스택

- **엔진**: Godot 4.4
- **통신**: TCPClient
- **스크립트 언어**: GDScript
- **직렬화**: Protobuf 연동

## 📦 주요 기능

- 서버 연결/해제 및 간단한 로그인 시뮬레이션
- WASD 이동 및 서버로 위치 전송
- 서버에서 받은 위치로 캐릭터 이동 동기화
- 장애물 충돌 시 서버에서 통보
- 맵 상 공유 자원 획득 → 서버 동기화 테스트

## 📷 스크린샷

![image](https://github.com/user-attachments/assets/0b8c8efa-723b-4520-86b9-0ac26960ff10)

## 🧪 실험 및 학습 목적

- **서버 개발을 눈으로 검증**하기 위한 클라이언트
- **공유 자원 처리 및 충돌 이벤트 동기화 테스트**
- **실시간 멀티 환경에서의 위치 보정 및 애니메이션 연습**
- 클라이언트가 **서버 권위 기반 게임에서 어떤 역할을 하는지 학습**

## 🔮 향후 계획

- ✅ 기본 TCP 연결 및 통신 구조 구현
- ✅ 캐릭터 이동 및 서버 동기화 기능 완성
- ✅ 공유 자원 획득 테스트
- ✅ Protobuf 적용 (서버와 동일 포맷 사용)
- 🔜 간단한 UI 및 상태 표시

## 📚 Reference

---

© 2025 CodingPythonMan. All Rights Reserved.
