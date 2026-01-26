# Use an official OpenJDK runtime as a parent image
FROM eclipse-temurin:21-jdk-alpine

# Set the working directory directly to /app
WORKDIR /app

# Copy the build artifact from the build stage
# Note: In a real CI/CD pipeline, you might use a multi-stage build. 
# For simplicity here, we assume you run './gradlew build' locally first 
# OR we can use a multi-stage build to compile inside Docker (recommended).

# --- Multi-stage build setup ---
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /src
COPY . .
# Grant execution rights on the gradlew wrapper
RUN chmod +x gradlew
# Build the application (skipping tests to speed up)
RUN ./gradlew build -x test

# --- Final Stage ---
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /src/build/libs/*.jar app.jar

# Expose the port the app runs on
EXPOSE 8080

# Run the jar file
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
