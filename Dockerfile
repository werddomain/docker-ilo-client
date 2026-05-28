# Inspired by ando023/docker-firefox-java
FROM jlesage/baseimage-gui:ubuntu-16.04-v3.5.8

ENV APP_NAME="HP ILO client"
ENV ILO_VERSION=2

# Enable 32-bit architecture for old Java and Firefox 2
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get -y install \
        curl nano wget bzip2 libnss3-tools \
        libc6:i386 libstdc++6:i386 libstdc++5:i386 \
        libx11-6:i386 libxext6:i386 \
        libxrender1:i386 libxtst6:i386 \
        libgtk2.0-0:i386 libasound2:i386 \
        libdbus-glib-1-2:i386 \
        libpango1.0-0:i386 libpangoxft-1.0-0:i386 \
        libpangox-1.0-0:i386 \
        libxt6:i386 libxinerama1:i386 \
        libxaw7:i386 libxmu6:i386 && \
    rm -rf /var/lib/apt/lists/*

# Install Firefox 3.6.28 (32-bit) - The absolute latest version that still supports Java 1.5 OJI plugins
RUN cd /opt && \
    curl -sO https://archive.mozilla.org/pub/firefox/releases/3.6.28/linux-i686/en-US/firefox-3.6.28.tar.bz2 && \
    tar -xjf firefox-3.6.28.tar.bz2 && \
    rm firefox-3.6.28.tar.bz2 && \
    ln -s /opt/firefox/firefox /usr/bin/firefox

# Copy and install JRE 1.5.0_11 (32-bit)
WORKDIR /opt/java
COPY jre-1_5_0_11-linux-i586.bin .
RUN chmod +x jre-1_5_0_11-linux-i586.bin && \
    echo "yes" | ./jre-1_5_0_11-linux-i586.bin || true && \
    rm jre-1_5_0_11-linux-i586.bin && \
    mv jre1.5.0_11 jre

# Configure environment for Java
ENV JAVA_HOME=/opt/java/jre
ENV PATH=$JAVA_HOME/bin:$PATH

# Link the Java plugin to Firefox 2.0 (OJI plugin for Java 5)
RUN mkdir -p /opt/firefox/plugins && \
    ln -s /opt/java/jre/plugin/i386/ns7/libjavaplugin_oji.so /opt/firefox/plugins/libjavaplugin_oji.so

COPY userscript.sh /etc/cont-init.d/00-userscript.sh
COPY install-ca.sh /install-ca.sh
COPY profiles.ini /profiles.ini
COPY startapp.sh /startapp.sh

RUN mkdir /app-data && \
    sed -i 's/\r$//' /etc/cont-init.d/00-userscript.sh /install-ca.sh /startapp.sh && \
    chmod +x /etc/cont-init.d/00-userscript.sh /install-ca.sh /startapp.sh

WORKDIR /app
