# 🎲 GoWhere - 랜덤 장소 추첨 앱

어디로 갈지 고민될 때, 랜덤으로 장소를 추첨해주는 iOS 앱입니다.

## ✨ 주요 기능

- **🎯 랜덤 장소 추첨**: 전국 또는 선택한 도시에서 랜덤으로 장소 추첨
- **🗺️ 지도 표시**: 추첨된 장소를 지도에서 확인
- **📍 현재 위치**: 내 위치와 목적지까지의 예상 도착 시간 표시
- **📚 추첨 기록**: 이전에 추첨한 장소들을 기록으로 저장
- **🍽️ 맛집 검색**: 네이버 지도 연동으로 주변 맛집 검색

## 📱 스크린샷

| 추첨 화면 | 결과 화면 | 기록 화면 |
|:---:|:---:|:---:|
| 도시 선택 후 추첨 | 추첨 결과 및 도착 시간 | 추첨 기록 조회 |

## 🛠️ 기술 스택

- **언어**: Swift 5.0
- **UI**: SwiftUI
- **최소 버전**: iOS 17.0+
- **아키텍처**: Clean Architecture + MVVM-C

## 📁 프로젝트 구조

```
GoWhere/
├── Common/
│   ├── Extensions/          # 확장 기능
│   └── Utils/               # 유틸리티 (위치 관리, 햅틱 등)
├── Data/
│   └── Repositories/        # 데이터 저장소 구현
├── Domain/
│   ├── Entities/            # 도메인 모델 (City, RandomLocation)
│   ├── RepositoryInterfaces/
│   └── UseCases/            # 비즈니스 로직
└── Presentation/
    ├── Coordinators/        # 화면 흐름 관리
    └── Scenes/              # UI 화면들
        ├── CitySelection/   # 도시 선택 및 추첨
        ├── History/         # 추첨 기록
        ├── MainTab/         # 메인 탭
        ├── Onboarding/      # 온보딩
        └── RandomLocationMap/ # 추첨 결과 맵
```

## 🔑 필요 권한

- **위치 권한**: 현재 위치 표시 및 도착 시간 계산

## 📦 설치 방법

1. 저장소 클론
```bash
git clone https://github.com/yourusername/GoWhere.git
```

2. Xcode에서 프로젝트 열기
```bash
cd GoWhere
open GoWhere.xcodeproj
```

3. 시뮬레이터 또는 실제 기기에서 실행

## 📄 라이선스

MIT License

## 👨‍💻 개발자

- **jaesuneo**
