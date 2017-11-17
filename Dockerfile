FROM centos:7
MAINTAINER Giovanni Torres

LABEL org.label-schema.vcs-url="https://github.com/giovtorres/docker-centos7-slurm" \
      org.label-schema.docker.cmd="docker run -it -h ernie giovtorres/docker-centos7-slurm:latest" \
      org.label-schema.name="docker-centos7-slurm" \
      org.label-schema.description="Slurm All-in-one Docker container on CentOS 7"

RUN yum makecache fast \
    && yum -y install epel-release \
    && yum -y install \
        wget \
        bzip2 \
        perl \
        gcc \
        gcc-c++\
        vim-enhanced \
        git \
        make \
        munge \
        munge-devel \
        supervisor \
        python-devel \
        python-pip \
        python34 \
        python34-devel \
        python34-pip \
        mariadb-server \
        mariadb-devel \
        psmisc \
        bash-completion \
    && yum clean all

RUN pip install Cython nose \
    && pip3 install Cython nose

RUN groupadd -r slurm && useradd -r -g slurm slurm

ADD slurm /usr/local/src/slurm

RUN set -x \
    && cd /usr/local/src/slurm \
    && ./configure --enable-debug --enable-front-end --prefix=/usr \
       --sysconfdir=/etc/slurm --with-mysql_config=/usr/bin \
       --libdir=/usr/lib64 \
    && make install \
    && install -D -m644 etc/cgroup.conf.example /etc/slurm/cgroup.conf.example \
    && install -D -m644 etc/slurm.conf.example /etc/slurm/slurm.conf.example \
    && install -D -m644 etc/slurm.epilog.clean /etc/slurm/slurm.epilog.clean \
    && install -D -m644 etc/slurmdbd.conf.example /etc/slurm/slurmdbd.conf.example \
    && install -D -m644 contribs/slurm_completion_help/slurm_completion.sh /etc/profile.d/slurm_completion.sh \
    && cd \
    && rm -rf /usr/local/src/slurm \
    && mkdir /etc/sysconfig/slurm \
        /var/spool/slurmd \
        /var/run/slurmd \
        /var/lib/slurmd \
        /var/log/slurm \
    && /sbin/create-munge-key

COPY slurm.conf /etc/slurm/slurm.conf
COPY slurmdbd.conf /etc/slurm/slurmdbd.conf
COPY supervisord.conf /etc/

VOLUME ["/var/lib/mysql", "/var/lib/slurmd", "/var/spool/slurmd", "/var/log/slurm"]

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/bash"]
