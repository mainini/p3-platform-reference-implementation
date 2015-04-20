FROM ubuntu:trusty

EXPOSE 8181 8151 8205 8300 8301 8302 8303 8305 8306 8307 8308 8310

# Upgrade system and install required debs
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl lxc openjdk-7-jre-headless lighttpd git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# Prepare docker-in-docker
RUN curl -sSL https://get.docker.com/ubuntu/ | sh
RUN curl https://raw.githubusercontent.com/jpetazzo/dind/master/wrapdocker -o /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker
VOLUME /var/lib/docker

# Fetch all self-containing P3-jars
RUN cd /usr/local/lib/ && \
    curl -Ls $(curl -s https://api.github.com/repos/fusepoolP3/p3-ldp-marmotta/releases | grep browser_download_url | head -n 1 | cut -d '"' -f 4) > p3-ldp-marmotta.jar && \
    curl -Ls $(curl -s https://api.github.com/repos/fusepoolP3/p3-proxy/releases | grep browser_download_url | head -n 1 | cut -d '"' -f 4) > p3-proxy.jar && \
    curl -Ls $(curl -s https://api.github.com/repos/fusepoolP3/p3-dictionary-matcher-factory-gui/releases | grep browser_download_url | head -n 1 | cut -d '"' -f 4) > p3-dictionary-matcher-factory-gui.jar && \
    curl -Ls $(curl -s https://api.github.com/repos/fusepoolP3/p3-batchrefine-factory-gui/releases | grep browser_download_url | head -n 1 | cut -d '"' -f 4) > p3-batchrefine-factory-gui.jar && \
    curl -Ls $(curl -s https://api.github.com/repos/fusepoolP3/p3-xslt-factory-gui/releases | grep browser_download_url | head -n 1 | cut -d '"' -f 4) > p3-xslt-factory-gui.jar && \
    curl -Ls $(curl -s https://api.github.com/repos/fusepoolP3/p3-pipeline-transformer/releases | grep browser_download_url | head -n 1 | cut -d '"' -f 4) > p3-pipeline-transformer.jar && \
    curl -Ls $(curl -s https://api.github.com/repos/fusepoolP3/p3-transformer-web-client/releases | grep browser_download_url | head -n 1 | cut -d '"' -f 4) > p3-transformer-web-client.jar && \
    curl -Ls $(curl -s https://api.github.com/repos/fusepoolP3/p3-silkdedup/releases | grep browser_download_url | head -n 1 | cut -d '"' -f 4) > p3-silkdedup.jar && \
    curl -Ls $(curl -s https://api.github.com/repos/fusepoolP3/p3-any23-transformer/releases | grep browser_download_url | head -n 1 | cut -d '"' -f 4) > p3-any23-transformer.jar && \
    curl -Ls $(curl -s https://api.github.com/repos/fusepoolP3/p3-geo-enriching-transformer/releases | grep browser_download_url | head -n 1 | cut -d '"' -f 4) > p3-geo-enriching-transformer.jar && \
    curl -Ls $(curl -s https://api.github.com/repos/fusepoolP3/p3-xslt-transformer/releases | grep browser_download_url | head -n 1 | cut -d '"' -f 4) > p3-xslt-transformer.jar && \
    curl -Ls $(curl -s https://api.github.com/repos/fusepoolP3/p3-dictionary-matcher-transformer/releases | grep browser_download_url | head -n 1 | cut -d '"' -f 4) > p3-dictionary-matcher-transformer.jar && \
    curl -Ls $(curl -s https://api.github.com/repos/fusepoolP3/p3-literal-extraction-transformer/releases | grep browser_download_url | head -n 1 | cut -d '"' -f 4) > p3-literal-extraction-transformer.jar && \
    curl -Ls $(curl -s https://api.github.com/repos/fusepoolP3/p3-geocoordinates-transformer/releases | grep browser_download_url | head -n 1 | cut -d '"' -f 4) > p3-geocoordinates-transformer.jar

# Setup webserver and add HTML-only GUIs
ADD lighttpd.conf /etc/lighttpd/lighttpd.conf
RUN rm -r /var/www/* && \
    cd /var/www && \
    git clone https://github.com/fusepoolP3/p3-pipeline-gui-js.git && \
    git clone https://github.com/fusepoolP3/p3-resource-gui.git && \
    rm -rf /var/www/*/.git

# Setup user & environment
RUN adduser --disabled-password --gecos "P3 Platform" --uid 3000 p3
ENV HOME /home/p3
WORKDIR /home/p3

# Setup & run startup-script
ADD startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh
CMD /usr/local/bin/startup.sh
