FROM mariadb:10.0

COPY my.cnf.highmem /etc/mysql/my.cnf.highmem

RUN echo "deb http://repo.percona.com/apt jessie main" > /etc/apt/sources.list.d/percona.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 1C4CBDCDCD2EFD2A
RUN apt-get -q update && apt-get -q upgrade -y
RUN apt-get -q install -y tar bzip2 unzip wget runit python3 vim
RUN apt-get -q install -y --force-yes percona-xtrabackup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD /docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
RUN mkdir -p /etc/my_init.d

COPY my_init /sbin/my_init
COPY service /etc/service/

COPY innobackupex_config /usr/local/etc/innobackupex_config
COPY backup /usr/local/sbin/backup
COPY restore /usr/local/sbin/restore

RUN sed "s/^\(\(log_bin\|expire_logs_days\|max_binlog_size\).*\)/#\1/" -i /etc/mysql/my.cnf

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["/sbin/my_init"]
