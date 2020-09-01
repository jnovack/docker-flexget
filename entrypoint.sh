#!/bin/sh
set -e

# Check mount
# Check if config.yml exists. If not, copy in
if [ -f /opt/flexget/config.yml ]; then
    echo "$(date '+%Y-%m-%d %H:%m') INIT     Using existing config.yml"
else
    echo "$(date '+%Y-%m-%d %H:%m') FATAL    config.yml not found in /opt/flexget"
    exit 1
fi

# PUID and PGUID
echo "$(date '+%Y-%m-%d %H:%m') INIT     Setting permissions on files/folders inside container"
if [ -n "${PUID}" ] && [ -n "${PGID}" ]; then
    if [ -z "$(getent group "${PGID}")" ]; then
      groupadd -g "${PGID}" flexget
        fi

    if [ -z "$(getent passwd "${PUID}")" ]; then
      useradd -M -s /bin/sh -u "${PUID}" -g "${PGID}" flexget
        fi

    flex_user=$(getent passwd "${PUID}" | cut -d: -f1)
    flex_group=$(getent group "${PGID}" | cut -d: -f1)

    chown -R "${flex_user}":"${flex_group}" /opt/flexget
    chmod -R 775 /opt/flexget
fi

# Remove lockfile if exists
if [ -f /opt/flexget/.config-lock ]; then
    echo "$(date '+%Y-%m-%d %H:%m') INIT     Removing lockfile"
    rm -f /opt/flexget/.config-lock
fi

# Set FG_WEBUI_PASSWD
if [[ ! -z "${FG_WEBUI_PASSWD:=correcthorsebatterystaple}" ]]; then
    echo "$(date '+%Y-%m-%d %H:%m') INIT     FG_WEBUI_PASSWD: ${FG_WEBUI_PASSWD}"
    echo "$(date '+%Y-%m-%d %H:%m') INIT     Starting flexget webui..."
    flexget web passwd "${FG_WEBUI_PASSWD}"
fi

echo "$(date '+%Y-%m-%d %H:%m') INIT     Starting flexget daemon:"
flexget_command="flexget -c /opt/flexget/config.yml --loglevel ${FG_LOG_LEVEL:=info} daemon start --autoreload-config"
echo "$(date '+%Y-%m-%d %H:%m') INIT         $flexget_command"
if [ -n "$flex_user" ]; then
    exec su "${flex_user}" -m -c "${flexget_command}"
else
    exec $flexget_command
fi