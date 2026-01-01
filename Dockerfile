# --- Stage 1: Build Stage ---
# Changed from openjdk-11 to openjdk-17
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /app

# Copy pom.xml and download dependencies (cached layer)
COPY pom.xml .

RUN mvn dependency:go-offline

# Copy source and build the war
COPY src ./src
RUN mvn clean package -DskipTests

# --- Stage 2: Runtime Stage ---
# Changed to a Tomcat image that supports JDK 17
FROM tomcat:9.0-jdk17-openjdk-slim

# Remove default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the generated war file from the build stage
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]