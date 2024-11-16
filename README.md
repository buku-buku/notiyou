# notiyou

- [개발 환경 세팅](#개발-환경-세팅)
  - [필수 요구사항](#필수-요구사항)
  - [Java 설정](#java-설정)
  - [수동 설정 방법 (스크립트 실패 시)](#수동-설정-방법-스크립트-실패-시)
- [Terminology](#terminology)

## 개발 환경 세팅

### 필수 요구사항

- Flutter SDK
- Java 17 (will be automatically installed if not present on macOS)
- Android Studio or VS Code

### Java 설정

이 프로젝트는 Android 빌드를 위해 Java 17이 필요합니다. 자동 설정을 위한 스크립트를 제공합니다:

```sh
# 스크립트 실행 권한 부여 (최초 1회)
chmod +x setup-android-local-properties.sh

# 설정 스크립트 실행
./setup-android-local-properties.sh
```

스크립트는 다음 작업을 수행합니다:

1. Java 17 설치 여부 확인
2. 설치되어 있지 않은 경우 Homebrew를 통해 설치 (macOS만 해당)
3. `android/local.properties`에 올바른 Java 경로 설정

### 수동 설정 방법 (스크립트 실패 시)

스크립트가 동작하지 않을 경우 수동으로 설정할 수 있습니다:

1. Java 17 설치:

   ```bash
   # macOS
   brew install openjdk@17

   # Linux
   sudo apt install openjdk-17-jdk
   ```

2. `android/local.properties`에 Java 경로 추가:

   ```properties
   # macOS의 경우
   org.gradle.java.home=/path/to/your/java-17

   # macOS에서 Java 17 경로 확인 방법:
   /usr/libexec/java_home -v 17
   ```

## Terminology

서비스 내에서 사용되는 용어들을 정리합니다. 가급적 코드레벨에서도 해당 용어를 준수합니다.

1. 미션 시간 (Mission Time)

   - 사용자가 미션을 수행해야 하는 시간

2. 미션 (Mission)

   - 사용자가 매일 수행해야 하는 작업.
   - 미션 시간에 체크를 해야하며, 체크를 하지 않으면 본인과 조력자에게 알림이 간다.
   - 매일 자정이 지나면 설정해둔 미션 시간으로 새로운 미션들이 생성된다.

3. 미션 알림 메시지 (Mission Notification Message)

   - 미션 수행과 관련된 알림 메시지. 조력자에게 해당 메시지가 전달된다.
   - 미션 수행 성공 또는 실패 여부에 따라 다른 메시지가 전달된다.

4. 조력자 (Supporter)

   - 사용자의 미션 수행을 돕는 역할
   - 미션 알림을 확인하고 사용자의 미션 완료 여부를 검증하는 사람
