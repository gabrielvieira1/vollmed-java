FROM maven:3.9.9-eclipse-temurin-17 AS build

WORKDIR /workspace

COPY pom.xml .
COPY src ./src
RUN mvn -B clean package -DskipTests

FROM eclipse-temurin:17-jre-jammy AS runtime

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system vollmed \
    && useradd --system --gid vollmed --home-dir /app --shell /usr/sbin/nologin vollmed

WORKDIR /app

COPY --from=build --chown=vollmed:vollmed /workspace/target/*.jar app.jar

USER vollmed

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
