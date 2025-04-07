# Use Java 21 base image
FROM eclipse-temurin:21-jdk

# Set working directory
WORKDIR /app

# Install curl, unzip, and Maven
RUN apt-get update && \
    apt-get install -y curl unzip tar && \
    curl -sSLo apache-maven.tar.gz https://downloads.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz && \
    tar xzf apache-maven.tar.gz -C /opt && \
    ln -s /opt/apache-maven-3.9.6 /opt/maven && \
    ln -s /opt/maven/bin/mvn /usr/bin/mvn && \
    rm apache-maven.tar.gz

# Copy your project files
COPY . .

# Install Sonar Scanner (optional)
RUN curl -sSLo sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472-linux.zip \
    && unzip sonar-scanner.zip -d /opt/ \
    && rm sonar-scanner.zip \
    && ln -s /opt/sonar-scanner-4.6.2.2472-linux/bin/sonar-scanner /usr/local/bin/sonar-scanner

# Set environment variables
ENV MAVEN_HOME=/opt/maven
ENV PATH=$MAVEN_HOME/bin:$PATH
ENV SONAR_SCANNER_HOME=/opt/sonar-scanner-4.6.2.2472-linux
ENV PATH="${SONAR_SCANNER_HOME}/bin:${PATH}"

# Default command
CMD ["mvn", "clean", "install"]
