#!/bin/bash

GH_LABEL=$GH_LABEL 
GH_OWNER=$GH_OWNER
GH_REPOSITORY=$GH_REPOSITORY
GH_TOKEN=$GH_TOKEN
 
RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
RUNNER_NAME="dockerNodeDevOps-${RUNNER_SUFFIX}" --labels ${GH_LABEL}
 
REG_TOKEN=$(curl -sX POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${GH_TOKEN}" https://api.github.com/repos/${GH_OWNER}/${GH_REPOSITORY}/actions/runners/registration-token | jq .token --raw-output)
#REG_TOKEN=$REG_TOKEN
 
cd /home/docker/actions-runner
 
./config.sh --unattended --url https://github.com/${GH_OWNER}/${GH_REPOSITORY} --token ${REG_TOKEN} --name ${RUNNER_NAME} --labels ${GH_LABEL}
 
cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}
 
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM
 
./run.sh & wait $

# # Install OpenJDK 16
# RUN apt-get install -y openjdk-16-jdk
 
# # Verify Java installation
# RUN java -version
 
# # Install Maven 3.9
# RUN wget https://dlcdn.apache.org/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz && \
#     tar xzvf apache-maven-3.9.5-bin.tar.gz && \
#     mv apache-maven-3.9.5 /opt/maven && \
#     ln -s /opt/maven/bin/mvn /usr/bin/mvn
 
# # Set Maven environment variables
# ENV MAVEN_HOME /opt/maven
# ENV PATH $MAVEN_HOME/bin:$PATH
 
# # Verify Maven installation
# RUN mvn -version
 
# # Install JMeter
# RUN wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.1.1.tgz && \
#     tar xzvf apache-jmeter-5.1.1.tgz && \
#     mv apache-jmeter-5.1.1 /opt/jmeter && \
#     ln -s /opt/jmeter/bin/jmeter /usr/bin/jmeter
# ENV PATH /opt/jmeter/bin:$PATH
 
# # Verify JMeter installation
# RUN jmeter --version
 
