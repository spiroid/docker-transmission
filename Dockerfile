# transmission container
# VERSION               0.0.1
FROM tianon/debian:jessie

MAINTAINER Jonathan Dray <jonathan.dray+docker@gmail.com>

# We are in a non interactive environment so
# we tell apt to not ask for packages configuration options
ENV DEBIAN_FRONTEND noninteractive


# Debian update package information
# Set environment variables
RUN sed -i 's/ftp.us/ftp.fr/g' /etc/apt/sources.list
ADD resources/etc/apt/apt.conf.d/01norecommends /etc/apt/apt.conf.d/01norecommends
RUN apt-get update -y -q


# System locales configuration
RUN apt-get install -y --no-install-recommends locales
RUN echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen
ENV LANG fr_FR.UTF-8


# Install transmission
RUN apt-get install -y -q transmission-daemon


# Copy configuration
# Transmission configuration
ADD resources/etc/transmission-daemon /etc/transmission-daemon
# Set up a startup script
RUN chmod 755 /etc/transmission-daemon/foreground.sh


# Setup required directories
RUN mkdir -p /srv/download /srv/incomplete /srv/watch
RUN chown debian-transmission /srv/download /srv/incomplete /srv/watch


# Install supervisord
# # Usefull to start and monitor multiple processes (easier than systemd in a docker context)
RUN apt-get install -y -q supervisor
ADD resources/etc/supervisor/ /etc/supervisor/


# Expose transmission webinterface 9091 port
EXPOSE 9091


# Container startup script (need to be changed to supervisord)
CMD ["/usr/bin/supervisord"]
