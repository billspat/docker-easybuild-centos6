FROM rjeschmi/lmod

MAINTAINER Robert Schmidt <rjeschmi@gmail.com>

ADD build/config.cfg /software/config/config.cfg
RUN chown -R build.build /software

RUN mkdir -p /software/easybuild-develop
ADD build/install-EasyBuild-fpm.sh /build/install-EasyBuild-fpm.sh
RUN chmod +x /build/install-EasyBuild-fpm.sh
RUN /build/install-EasyBuild-fpm.sh rjeschmi /software/easybuild-develop

ADD build/z99_StdEnv.sh /etc/profile.d/z99_StdEnv.sh

RUN mkdir -p /software/easybuild
RUN chown -R build.build /software/easybuild


RUN mkdir -p /export/easybuild
RUN useradd -u 1000 easybuild
RUN chown -R easybuild.easybuild /export

ADD ./easybuild-docker.sh /usr/bin/easybuild-docker
RUN chmod +x /usr/bin/easybuild-docker

USER easybuild
WORKDIR /export/easybuild

VOLUME /export/easybuild
VOLUME /software/easybuild-develop

USER root
RUN yum -y install python-keyring zlib-devel openssl-devel libibverbs-devel unzip rpm-build createrepo


RUN su -l -c 'eb Ruby-2.1.5.eb --prefix=/software/easybuild --robot' - build
RUN su -l -c 'eb Ruby-FPM-2.1.5-1.0.0.eb --prefix=/software/easybuild --robot' - build

USER easybuild

CMD ["/usr/bin/easybuild-docker"]

