FROM adoptopenjdk/openjdk11:jre-11.0.9_11.1-alpine@sha256:58254737530df7f7e7acfe3e7538a027f898ac05accd2e15adcef34d5a33ae72

WORKDIR /app

ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar

EXPOSE 8083

ENTRYPOINT ["java", "-jar", "app.jar"]
