# 1단계: 빌드 단계
FROM gradle:8.10-jdk17 AS build
WORKDIR /app

# Gradle 관련 파일 복사 (캐시 최적화)
COPY build.gradle settings.gradle gradlew ./
COPY gradle ./gradle

# [수정] gradlew 파일에 실행 권한 부여
RUN chmod +x ./gradlew

# [추가] Windows 라인 엔딩(CRLF)을 Unix 라인 엔딩(LF)으로 변환
# 이것이 "not found" 오류의 주된 원인일 수 있습니다.
RUN sed -i 's/\r$//' ./gradlew

# 의존성 캐시 미리 다운로드
# [수정] "|| return 0"을 제거하여 실제 오류가 발생하는지 확인합니다.
RUN ./gradlew dependencies

# 실제 소스 복사 및 빌드
COPY src ./src
RUN ./gradlew bootJar -x test

# 2단계: 실행 단계
FROM eclipse-temurin:17-jdk
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar

# 스프링부트 기본 포트가 8080이라면, application.yml에서 8088로 설정하거나 여기서 매개변수로 변경 가능
EXPOSE 8088

ENTRYPOINT ["java", "-jar", "app.jar"]