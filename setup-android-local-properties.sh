#!/bin/bash

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'
STRESS=${YELLOW}
INDENT="  "

echo_red() {
  echo -e "\n${RED}$1${NC}"
}

echo_green() {
  echo -e "\n${GREEN}$1${NC}"
}

echo_yellow() {
  echo -e "\n${YELLOW}$1${NC}"
}

echo_cyan() {
  echo -e "\n${CYAN}$1${NC}"
}

echo_blue() {
  echo -e "\n${BLUE}$1${NC}"
}

# 에러 처리
set -e

# Java 17 확인
echo ""
JAVA_17_PATH=$(/usr/libexec/java_home -v 17 2>/dev/null || true)
if [ -z "$JAVA_17_PATH" ]; then
    echo_red "Java 17 not found"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo_yellow "Installing Java 17 via Homebrew..."
        brew install openjdk@17
        JAVA_17_PATH=$(/usr/libexec/java_home -v 17)
    else
        echo_red "Please install Java 17 manually"
        exit 1
    fi
else
    echo -e "Java 17 found at \n${INDENT}${STRESS}$JAVA_17_PATH${NC}"
fi

# local.properties 파일 경로
PROPERTIES_FILE="android/local.properties"

# 기존 파일이 있다면 Java 설정 제거
if [ -f "$PROPERTIES_FILE" ]; then
    sed -i '' '/^org\.gradle\.java\.home=/d' "$PROPERTIES_FILE"
    
    # 파일 끝에 빈 줄이 없다면 추가
    if [[ -s "$PROPERTIES_FILE" && $(tail -c1 "$PROPERTIES_FILE" | wc -l) -eq 0 ]]; then
        echo "" >> "$PROPERTIES_FILE"
    fi
fi

# Java 설정 추가
echo ""
echo "org.gradle.java.home=${JAVA_17_PATH}" >> "$PROPERTIES_FILE"
echo -e "$PROPERTIES_FILE updated \n${INDENT}${STRESS}org.grade.java.home=${JAVA_17_PATH}${NC}"

# 프로젝트 클린
echo ""
echo -e "Project clean up\n"
flutter clean
cd android && ./gradlew clean
cd ..
flutter pub get

echo_green "✅ Setup complete!"
