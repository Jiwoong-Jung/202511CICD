# 안정적인 OpenJDK 17 JDK 버전
FROM eclipse-temurin:17-jdk

# Spring Boot JAR 복사
COPY build/libs/*.jar app.jar

# 앱 실행
ENTRYPOINT ["java", "-jar", "/app.jar"]