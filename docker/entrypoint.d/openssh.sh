if [[ ! -f /etc/ssh/ssh_host_rsa_key ]]; then
    ssh-keygen -A
fi

SUPERVISORD_CONF_FILE=/etc/supervisord.d/sshd.conf
if [[ ! -f $SUPERVISORD_CONF_FILE ]]; then
    (
cat <<INI
[program:sshd]
command = /usr/sbin/sshd -D
stdout_events_enabled = true
stderr_events_enabled = true

INI
) | tee $SUPERVISORD_CONF_FILE >/dev/null
fi

sed -i -E "s/^#?StrictModes .*/StrictModes no/" /etc/ssh/sshd_config
> /etc/motd
