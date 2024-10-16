FROM ubuntu:20.04

#input GitHub runner version argument

ARG RUNNER_VERSION

ENV DEBIAN_FRONTEND=noninteractive

LABEL BaseImage="ubuntu:20.04"

LABEL RunnerVersion=${RUNNER_VERSION}
 
# update the base packages + add a non-sudo user

RUN apt-get update -y && apt-get upgrade -y && useradd -m docker
 
# install the packages and dependencies along with jq so we can parse JSON (add additional packages as necessary)

RUN apt-get install -y --no-install-recommends \
    curl nodejs wget unzip vim git azure-cli jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

# Update and install necessary dependencies
RUN apt-get update && \
   apt-get install -y software-properties-common curl
# Install Java 8
RUN apt-get install -y openjdk-8-jdk
# Install Maven
RUN apt-get install -y maven
# Set JAVA_HOME environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"
# Verify installation
RUN java -version && mvn -version
 
# cd into the user directory, download and unzip the github actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
&& curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
&& tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN rm -rf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
# install some additional dependencie

RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

COPY startup.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/startup.sh 

# add over the start.sh script

# ADD start.sh start.sh
 
# # make the script executable

# RUN chmod +x start.sh
 
# set the user to "docker" so all subsequent commands are run as the docker user

USER docker
 
# set the entrypoint to the start.sh script

ENTRYPOINT ["/usr/local/bin/startup.sh"]
CMD ["startup.sh"]