# For use with Docker https://www.docker.io/gettingstarted/
#
# sudo mount -v --bind ~/opencog ~/opencog/docker/buildslave/opencog
# docker build -t $USER/opencog-buildslave .
# docker run -d -e BUILDSLAVE_NAME=$HOSTNAME -e BUILDSLAVE_PASSWD=foobar $USER/opencog-buildslave

FROM opencog/opencog-deps
MAINTAINER David Hart "dhart@opencog.org"

RUN apt-get update --assume-yes && \
    apt-get install python-pip \
                    python-dev \
		    locales \
            --assume-yes

RUN localedef -c -i en_US -f UTF-8 en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN pip install buildbot-slave==0.8.8

RUN adduser --disabled-password -uid 1099 --gecos "Buildbot,,," --home /buildbot buildbot

RUN su buildbot sh -c "buildslave create-slave --umask=022 /buildbot buildbot.opencog.org:9989 BUILDSLAVE_NAME BUILDSLAVE_PASSWD"

ADD opencog /buildbot/opencog_master_trusty/build
RUN chown -R buildbot:buildbot /buildbot
WORKDIR /buildbot/opencog_master_trusty/build

RUN git remote rm origin
RUN git remote add origin git://github.com/opencog/opencog

# set buildslave admin and host info
RUN echo "David Hart <dhart@opencog.org>" > /buildbot/info/admin && \
    grep "model name" /proc/cpuinfo | head -1 | cut -d ":" -f 2 | tr -d " " > /buildbot/info/host && \
    grep DISTRIB_DESCRIPTION /etc/lsb-release | cut -d "=" -f 2 | tr -d "\"" >> /buildbot/info/host \
    echo "https://github.com/opencog/opencog/blob/master/docker/buildslave/Dockerfile" >> /buildbot/info/host

CMD su buildbot sh -c "\
sed -i s:BUILDSLAVE_NAME:$BUILDSLAVE_NAME:g /buildbot/buildbot.tac && \
sed -i s:BUILDSLAVE_PASSWD:$BUILDSLAVE_PASSWD:g /buildbot/buildbot.tac && \
BUILDSLAVE_PASSWD=xxxxxx /usr/local/bin/buildslave start --nodaemon /buildbot"
