FROM python:latest

RUN apt-get update \
  && apt-get install -y libxml2-dev libxslt-dev python-dev cron vim \
  && curl -sLO https://github.com/maxmind/geoipupdate/releases/download/v4.3.0/geoipupdate_4.3.0_linux_amd64.deb && dpkg -i geoipupdate_4.3.0_linux_amd64.deb \
  && pip install parsedmarc \
  && rm -rf /root/.cache/ \
  && rm -rf /var/lib/{apt,dpkg}/

COPY parsedmarc.ini /etc/parsedmarc.ini
COPY GeoIP.conf /etc/GeoIP.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT /entrypoint.sh
