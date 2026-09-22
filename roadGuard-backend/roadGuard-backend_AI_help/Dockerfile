# Step 1: Build the jar using Maven and JDK 21
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Step 2: Run the jar using lightweight JDK 21 runtime engine
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/roadGuard-backend-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]