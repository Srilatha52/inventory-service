# Use a base image that supports Java and Maven
FROM maven:3.8.1-openjdk-17-slim

# Set the working directory
WORKDIR /app

# Copy your project files into the container
COPY . .

# Install Docker (optional, needed for Docker in Docker)
RUN apt-get update && apt-get install -y docker.io

# Install SonarQube Scanner
RUN curl -sS https://dl.bintray.com/sonarsource/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472-linux.zip -o sonar-scanner.zip \
    && unzip sonar-scanner.zip -d /opt/ \
    && rm sonar-scanner.zip \
    && ln -s /opt/sonar-scanner-4.6.2.2472-linux/bin/sonar-scanner /usr/local/bin/sonar-scanner

# Set environment variables for SonarQube
ENV SONAR_SCANNER_HOME=/opt/sonar-scanner-4.6.2.2472-linux
ENV PATH="${SONAR_SCANNER_HOME}/bin:${PATH}"

# Run the Maven build by default
CMD ["mvn", "clean", "install"]