FROM openjdk:22-jdk-slim
WORKDIR /app
COPY target/inventory-service-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]tasklist | findstr 1234