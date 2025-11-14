FROM openjdk:17-jdk-slim

# Spring Boot JAR 복사
COPY build/libs/*.jar app.jar

# 앱 실행
ENTRYPOINT ["java", "-jar", "/app.jar"]
