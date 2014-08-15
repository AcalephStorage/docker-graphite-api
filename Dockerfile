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

RUN apt-get install -y build-essential python-dev libffi-dev libcairo2-dev python-pip supervisor curl

RUN pip install gunicorn Flask-Cache statsd raven blinker

# patched version with cache
RUN pip install https://github.com/Dieterbe/graphite-api/tarball/check-series-early

# graphite-influxdb PR#16 which fixes metrics api
RUN pip install https://github.com/svanharmelen/graphite-influxdb/tarball/bugfix

# latest influxdb-python
RUN pip uninstall -y influxdb
RUN pip install https://github.com/influxdb/influxdb-python/tarball/master

# add graphite-api config
ADD graphite-api.yaml /etc/graphite-api.yaml
RUN chmod 0644 /etc/graphite-api.yaml

ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# HACK. added 1 second interval.
ADD ./maintain_cache.py /usr/local/bin/maintain_cache.py
RUN chmod 0744 /usr/local/bin/maintain_cache.py

RUN mkdir /srv/graphite && chmod 777 /srv/graphite

# cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# graphite-api
EXPOSE 8000

VOLUME [ "/var/log/supervisor" ]

CMD ["/usr/bin/supervisord"]
