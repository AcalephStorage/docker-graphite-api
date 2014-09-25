FROM ubuntu:trusty
MAINTAINER Acaleph <admin@acale.ph>

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y language-pack-en
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

RUN apt-get install -y build-essential python-dev libffi-dev libcairo2-dev python-pip curl

RUN pip install gunicorn Flask-Cache statsd raven blinker

# patched version with cache
RUN pip install https://github.com/Dieterbe/graphite-api/tarball/support-templates2

# latest graphite-influxdb
RUN pip install https://github.com/vimeo/graphite-influxdb/tarball/master

# latest influxdb-python
RUN pip uninstall -y influxdb
RUN pip install https://github.com/influxdb/influxdb-python/tarball/master

# add graphite-api config
ADD graphite-api.yaml /etc/graphite-api.yaml
RUN chmod 0644 /etc/graphite-api.yaml

RUN mkdir /srv/graphite && chmod 777 /srv/graphite

# cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./run /usr/local/bin/run-graphite-api
RUN chmod 0744 /usr/local/bin/run-graphite-api

ENV INFLUXDB_HOST influxdb
ENV INFLUXDB_PORT 8086
ENV GRAPHITE_USERNAME graphite
ENV GRAPHITE_PASSWORD graphite
ENV GRAPHITE_DATABASE graphite

# graphite-api
EXPOSE 8000

CMD ["/usr/local/bin/run-graphite-api"]
