FROM archlinux:base

LABEL maintainer="rsharo@users.noreply.github.com"

RUN pacman -Syu --noconfirm

# Tools required for secure repo access
RUN pacman -S --noconfirm ca-certificates gnupg

# Docker key and repo
# pub   4096R/2C52609D 2015-07-14
#       Key fingerprint = 5811 8E89 F3A9 1289 7C07  0ADB F762 2157 2C52 609D
# uid                  Docker Release Tool (releasedocker) <docker@docker.com>
# **IMPORTANT**  If this script fails on the "--fingerprint" line , you may have a falsified key!
# THIS MIGHT NOT BE NECESSARY
RUN gpg --recv-keys 58118e89f3a912897c070adbf76221572c52609d
RUN gpg --fingerprint 2c52609d | grep "Key fingerprint = 5811 8E89 F3A9 1289 7C07  0ADB F762 2157 2C52 609D"
RUN echo '[docker]' > /etc/pacman.conf
RUN echo 'deb https://apt.dockerproject.org/repo debian-jessie main' > /etc/pacman.conf

# Steam (Valve) key and repo
# pub   2048R/8ABDDD96 2013-11-05
#       Key fingerprint = 48FD 4330 8E37 C3A4 18B9  2A15 7DEE B743 8ABD DD96
# uid                  Valve SteamOS Release Key <steamos@steampowered.com>
# sub   2048R/103C02AE 2013-11-05
# **IMPORTANT**  If this script fails on the "--fingerprint" line , you may have a falsified key!
RUN gpg --recv-keys 48fd43308e37c3a418b92a157deeb7438abddd96
RUN gpg --fingerprint 8abddd96 | grep "Key fingerprint = 48FD 4330 8E37 C3A4 18B9  2A15 7DEE B743 8ABD DD96"
RUN echo 'deb http://repo.steampowered.com/steamos alchemist main contrib non-free' > /etc/apt/sources.list.d/alchemist.list
RUN echo 'deb http://repo.steampowered.com/steamos brewmaster main contrib non-free' > /etc/apt/sources.list.d/brewmaster.list


# Tools for building docker images
RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm debootstrap binutils docker

# Retrieve valve-archive-keyring.gpg
RUN apt-get -y install valve-archive-keyring

# We are running in a container -- tweak mkimage.sh so it skips "docker build"
WORKDIR /usr/share/docker-engine/contrib
RUN sed -e 's/docker build/echo SKIPPING docker build/' mkimage.sh > mkimage_rootfsonly.sh
RUN chmod 555 mkimage_rootfsonly.sh

# SteamOS clobbers the Debian keyring with their own (Valve) keyring.
# Our build machine is true Debian: tell debootstrap to use valve-archive-keyring.gpg
WORKDIR /usr/share/debootstrap/scripts/
RUN	if [ -e alchemist ] ; then \
		sed -i.orig -e 's/debian-archive-keyring.gpg/valve-archive-keyring.gpg/' alchemist ; \
	else \
		sed -e 's/debian-archive-keyring.gpg/valve-archive-keyring.gpg/' wheezy > alchemist ; \
	fi
RUN	if [ -e brewmaster ] ; then \
		sed -i.orig -e 's/debian-archive-keyring.gpg/valve-archive-keyring.gpg/' brewmaster ; \
	else \
		sed -e 's/debian-archive-keyring.gpg/valve-archive-keyring.gpg/' jessie > brewmaster ; \
	fi
RUN ln -s alchemist alchemist_beta
RUN ln -s brewmaster brewmaster_beta

# Makefile mounts the following path. Uncomment this line if not using the makefile.
#VOLUME [ "/root/steamos" ]

WORKDIR /root
SHELL [ "/bin/bash" , "-c" ]
ENTRYPOINT [ "/usr/share/docker-engine/contrib/mkimage_rootfsonly.sh", "-d", "steamos", "debootstrap" ]

# resulting Dockerfile and tarball will be found in /root/steamos
CMD [ "--variant=minbase", "brewmaster", "http://repo.steampowered.com/steamos" ]

