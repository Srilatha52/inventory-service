# Use a base image that supports Java and Maven
FROM maven:3.8.6-openjdk-22-slim

# Set the working directory
WORKDIR /app

# Copy your project files into the container
COPY . .

# Install dependencies
RUN apt-get update && apt-get install -y curl unzip

# Install SonarQube Scanner from official source
RUN curl -sSLo sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472-linux.zip \
    && unzip sonar-scanner.zip -d /opt/ \
    && rm sonar-scanner.zip \
    && ln -s /opt/sonar-scanner-4.6.2.2472-linux/bin/sonar-scanner /usr/local/bin/sonar-scanner

# Set environment variables
ENV SONAR_SCANNER_HOME=/opt/sonar-scanner-4.6.2.2472-linux
ENV PATH="${SONAR_SCANNER_HOME}/bin:${PATH}"

# Run Maven build by default
CMD ["mvn", "clean", "install"]
