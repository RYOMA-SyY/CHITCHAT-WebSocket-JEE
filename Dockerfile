# Stage 1: Build with Maven
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
# Build the application (skip tests for speed)
RUN mvn clean package -DskipTests

# Stage 2: Run with Tomcat
# Use the slim Tomcat image (Ubuntu base) for stability and size balance
FROM tomcat:10.1-jdk17-temurin-jammy

# Remove default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the built WAR from the 'build' stage to Tomcat
COPY --from=build /app/target/chitchat.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
