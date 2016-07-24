FROM ubuntu:16.04
MAINTAINER Kirill Gusyatin "kirill.gus@gmail.com"

# Install apt packages
RUN apt-get update && apt-get install -y \
    software-properties-common libncurses5 \
    libstdc++6 zlib1g expect wget build-essential \
    git lib32stdc++6 lib32z1 npm nodejs nodejs-legacy \
    s3cmd build-essential curl openjdk-8-jdk-headless \
    sendemail libio-socket-ssl-perl libnet-ssleay-perl \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && add-apt-repository -y ppa:webupd8team/java \
    && curl -sL https://deb.nodesource.com/setup_4.x | bash - \
    && apt-get update \
    && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
    && apt-get install -y oracle-java8-installer nodejs \
    && apt-get autoclean

# Install android SDK, tools and platforms
RUN cd /opt && curl https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz -o android-sdk.tgz && tar xzf android-sdk.tgz && rm android-sdk.tgz
ENV ANDROID_SDK_URL http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz

ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

RUN echo 'y' | /opt/android-sdk-linux/tools/android update sdk -u -a -t platform-tools,build-tools-23.0.3,android-23,extra-android-support,extra-google-m2repository,extra-android-m2repository

COPY tools /opt/tools
ENV PATH ${PATH}:/opt/tools

ENV ANDROID_PLATFORM_VERSION 23
ENV ANDROID_BUILD_TOOLS_VERSION 23.0.3
ENV ANDROID_EXTRA_PACKAGES android-22,build-tools-22.0.1,build-tools-23.0.0,build-tools-23.0.1,build-tools-23.0.2
ENV ANDROID_REPOSITORIES extra-android-m2repository,extra-android-support,extra-google-m2repository

RUN /opt/tools/android-accept-licenses.sh "android update sdk --no-ui --all --filter tools,platform-tools,build-tools-$ANDROID_BUILD_TOOLS_VERSION,android-$ANDROID_PLATFORM_VERSION,$ANDROID_EXTRA_PACKAGES,$ANDROID_REPOSITORIES"

# Install npm packages
RUN npm install -g xcode-build-tools@3.2.1 phantomjs-prebuilt cordova ionic && npm cache clean

RUN mkdir -p /opt/workspace

WORKDIR /opt/workspace
