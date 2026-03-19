# Build stage
FROM gradle:8.3-jdk17 AS builder
WORKDIR /app
COPY . .
RUN gradle bootJar --no-daemon

# Runtime stage
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=builder /app/build/libs/prm_smart_task-*.jar app.jar

EXPOSE 10000
ENV PORT=10000

ENTRYPOINT ["java", "-jar", "app.jar"]
