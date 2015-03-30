
FROM    ubuntu:trusty
MAINTAINER Jeff Kehler "jeff@dmcaguardian.com"

# prevent apt from starting postgres right after the installation
RUN echo "#!/bin/sh\nexit 101" > /usr/sbin/policy-rc.d; chmod +x /usr/sbin/policy-rc.d

RUN apt-get update
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y -q postgresql-9.3 postgresql-contrib-9.3
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean

# allow autostart again
RUN rm /usr/sbin/policy-rc.d

ENV PG_ROOT_DIR /opt/postgresql
ENV PG_DATA_DIR /opt/postgresql/data
ENV PG_HBA_FILE /opt/postgresql/pg_hba.conf
ENV PG_CONF_FILE /opt/postgresql/postgresql.conf

ADD . /
RUN chmod +x /start.sh

# Configure the database to use our data dir and Allow connections from anywhere
RUN sed -i -e"s|data_directory =.*$|data_directory = '$PG_DATA_DIR'|" /etc/postgresql/9.3/main/postgresql.conf && \
    sed -i -e"s|hba_file =.*$|hba_file = '$PG_HBA_FILE'|" /etc/postgresql/9.3/main/postgresql.conf && \
    sed -i -e"s|stats_temp_directory = .*$|stats_temp_directory = '$PG_DATA_DIR/pg_stat_tmp'|" /etc/postgresql/9.3/main/postgresql.conf && \
    echo "host    all    all    0.0.0.0/0    md5" >> /etc/postgresql/9.3/main/pg_hba.conf && \
    echo "local    all    all                   md5" >> /etc/postgresql/9.3/main/pg_hba.conf


VOLUME ["/opt/postgresql"]

EXPOSE 5432
