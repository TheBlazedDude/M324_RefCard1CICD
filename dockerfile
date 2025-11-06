FROM openjdk:17.0.1-jdk-slim AS builder
RUN apt-get update && apt-get install -y maven git
WORKDIR /app
RUN git clone https://gitlab.com/bbwrl/m347-ref-card-01.git
WORKDIR /app/m347-ref-card-01
RUN mvn package
FROM openjdk:17.0.1-jdk-slim
COPY --from=builder /app/m347-ref-card-01/target/*.jar /app/app.jar
EXPOSE 8080
CMD ["java", "-jar", "/app/app.jar"]
