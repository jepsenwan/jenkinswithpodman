FROM ubuntuwithpodman:v3 AS podman

FROM jenkins/jnlp-slave:latest
USER root
RUN apt-get update && apt-get -y install libgpgme-dev  libgtk2.0-0  &&apt-get install -yq iptables uidmap && apt-get clean
COPY --from=podman /usr/local/bin/* /usr/local/bin/
#COPY --from=podman /usr/libexec/podman /usr/libexec/podman
RUN mkdir -p /root/go/src/github.com/containers
COPY --from=podman root/go/src/github.com/containers/* /root/go/src/github.com/containers
ENV GOSU_VERSION=1.11 
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64.asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && rm -r /root/.gnupg/ \
    && chmod +x /usr/local/bin/gosu \
    # Verify that the binary works
    && gosu nobody true
RUN mkdir -p /home/jenkins/.local/share/containers/storage
#chown -R jenkins:jenkins /home/jenkins
VOLUME /home/jenkins/.local/share/containers/storage
COPY docker /usr/local/bin/
COPY entrypoint.sh /
RUN chown jenkins:jenkins /home/jenkins/.local/share/containers/storage &&  chown -R jenkins:jenkins /home/jenkins/agent

ENTRYPOINT [ "/usr/local/bin/jenkins-slave","-url","http://10.200.10.52:8080" ]
