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




# Cache Friendly Maven Build(includes maven in maven:3.9-eclipse-temirun-17), where the local m2 Repo is used, to reuse already downloaded libraries like mvn
# ---------- Build stage (has mvn)
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Leverage layer cache for deps
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 mvn -B -DskipTests dependency:go-offline

# Build
COPY . .
RUN --mount=type=cache,target=/root/.m2 mvn -B -DskipTests package

# ---------- Runtime stage (small JRE)
FROM eclipse-temurin:17-jre
WORKDIR /app
EXPOSE 8080
COPY --from=build /app/target/*-SNAPSHOT.jar app.jar
ENTRYPOINT ["java","-jar","/app/app.jar"]




# # Cache Friendly Maven Build(install maven, keep JDK-slim), where the local m2 Repo is used, to reuse already downloaded libraries like mvn
# # ---------- Build stage (has mvn)
# FROM openjdk:17.0.1-jdk-slim AS build
# WORKDIR /app
#
# # Install mvn
# RUN apt-get update && apt-get install -y --no-install-recommends maven \
#  && rm -rf /var/lib/apt/lists/*
#
# COPY pom.xml .
# RUN --mount=type=cache,target=/root/.m2 mvn -B -DskipTests dependency:go-offline
#
# COPY . .
# RUN --mount=type=cache,target=/root/.m2 mvn -B -DskipTests package
#
# FROM eclipse-temurin:17-jre
# WORKDIR /app
# COPY --from=build /app/target/*-SNAPSHOT.jar app.jar
# ENTRYPOINT ["java","-jar","/app/app.jar"]
