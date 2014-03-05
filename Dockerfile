# For use with Docker https://www.docker.io/gettingstarted/
#
# Quickstart:
# docker build -t $USER/opencog-embodiment .
# docker run --name embodiment -d -p 17001:17001 -p 5000:5000 -p 16312:16312 $USER/opencog-embodiment
# docker logs embodiment
# sudo lxc-attach -n `docker inspect embodiment | grep '"ID"' | sed 's/[^0-9a-z]//g'` /bin/bash

FROM ubuntu:12.04
MAINTAINER David Hart "dhart@opencog.org"
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update 
RUN apt-get -y install python-software-properties wget sudo 

# Set locale
RUN sudo locale-gen en_US en_US.UTF-8 && \
    sudo dpkg-reconfigure locales

# Get ocpkg script, replace wget with ADD when caching feature is added
ADD . /opencog
ADD https://raw.github.com/opencog/ocpkg/master/ocpkg /opencog/
RUN chmod -v u+x /opencog/ocpkg && \
    ln -s -v /opencog/ocpkg /opencog/octool && \
    ln -s -v /opencog /opencog/src && \
    mkdir -v -p /opencog/build 

# Add repositories, install dependencies, build; still depends on opencog/bin
RUN /opencog/octool -v -a -d
RUN /opencog/octool -v -b -l /opencog/build

# Run special scripts to copy embodiment files (should be in cmake not tclsh!)
RUN apt-get -y install lsof psmisc
WORKDIR /opencog/scripts/embodiment
RUN ./make_distribution

# Start embodiment cogserver, spawner, router, etc. when container runs
WORKDIR /opencog/build/dist/embodiment
CMD ["/opencog/build/dist/embodiment/spawner"]
