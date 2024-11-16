# History

- [Setup history](#setup-history)

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
