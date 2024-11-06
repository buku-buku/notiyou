# notiyou

- [Setup history](#setup-history)
- [Dependencies](#dependencies)

## Setup history

```sh
# 빈 프로젝트 생성
flutter create -e notiyou
```

```sh
The configured version of Java detected may conflict with the Gradle version in your new Flutter app.

[RECOMMENDED] If so, to keep the default Gradle version 8.3, make
sure to download a compatible Java version
(Java 17 <= compatible Java version < Java 21).
You may configure this compatible Java version by running:
`flutter config --jdk-dir=<JDK_DIRECTORY>`
Note that this is a global configuration for Flutter.


Alternatively, to continue using your configured Java version, update the Gradle
version specified in the following file to a compatible Gradle version (compatible Gradle version
range: 8.4 - 8.7):
/Users/cheo/Works/buku-buku/notiyou/android/gradle/wrapper/gradle-wrapper.properties

You may also update the Gradle version used by running
`./gradlew wrapper --gradle-version=<COMPATIBLE_GRADLE_VERSION>`.
```

```sh
# java 17 버전으로 변경
java-17
```

```sh
# gradle 버전 업데이트
./gradlew wrapper --gradle-version=8.4
```

## Dependencies

```sh
flutter pub add go_router
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
