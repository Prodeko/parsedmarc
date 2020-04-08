#!/bin/sh

set -e

echo "Container has been started"

echo "Running geoipupdate"
geoipupdate

# Setup a cron job
echo "27 5 * * 3 /usr/bin/geoipupdate >> /var/log/cron.log 2>&1
# This extra line makes it a valid cron" > geoipupdate.txt

crontab geoipupdate.txt
cron

echo "Running parsedmarc"
# Run parsedmarc
parsedmarc -c /etc/parsedmarc.ini 2>&1