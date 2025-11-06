# FROM openjdk:17.0.1-jdk-slim AS builder
# RUN apt-get update && apt-get install -y maven git
# WORKDIR /app
# RUN git clone https://gitlab.com/bbwrl/m347-ref-card-01.git
# WORKDIR /app/m347-ref-card-01
# RUN mvn package
# FROM openjdk:17.0.1-jdk-slim
# COPY --from=builder /app/m347-ref-card-01/target/*.jar /app/app.jar
# EXPOSE 8080
# CMD ["java", "-jar", "/app/app.jar"]

# Cache Friendly Maven Build, where the local m2 Repo is used, to reuse already downloaded libraries like mvn
# ---- Build stage
FROM openjdk:17.0.1-jdk-slim AS build
WORKDIR /app

# Copy pom first to leverage layer/cache
COPY pom.xml .
# Warm the dependency cache
RUN --mount=type=cache,target=/root/.m2 mvn -B -DskipTests dependency:go-offline

# Now copy sources and build
COPY . .
RUN --mount=type=cache,target=/root/.m2 mvn -B -DskipTests package

# ---- Runtime stage (small)
FROM openjdk:17.0.1-jdk-slim
WORKDIR /app
COPY --from=build /app/target/*-SNAPSHOT.jar app.jar
ENTRYPOINT ["java","-jar","/app/app.jar"]