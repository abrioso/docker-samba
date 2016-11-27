#!/bin/sh
# value
USER1=${USER:-samba}
PASS=${PASS:-samba}
WORKGROUP=${WORKGROUP:-WORKGROUP}
HOSTNAME=$(hostname -s)
PUBLICFOLDER=${PUBLICFOLDER:-data}
PUBLICNAME=${PUBLICSHARE:-$PUBLICFOLDER}
PRIVATEFOLDER=${PRIVATEFOLDER:-private}
PRIVATENAME=${PRIVATENAME:-$PRIVATEFOLDER}

if [ ! -D "/share/$PUBLICFOLDER" ]; then mkdir -p /share/$PUBLICFOLDER; fi

# add a non-root user and group called "samba" with no password, no home dir, no shell, and gid/uid set to 1000
RUN addgroup -g 1000 $USER1 && adduser -D -H -G $USER1 -s /bin/false -u 1000 $USER1

# create a samba user matching our user from above with a very simple password ("samba")
RUN echo -e "$PASS\n$PASS" | smbpasswd -a -s -c /config/smb.conf $USER1

# set config supervisord
if [ ! -f "/config/supervisord.conf" ]; then
cat <<EOF>> /config/supervisord.conf
[supervisord]
nodaemon=true
loglevel=info

# set some defaults and start samba in foreground (-F), logging to stdout (-S), and using our config (-s path)

[program:smbd]
command=smbd -F -S -s /config/smb.conf
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:nmbd]
command=nmbd -F -S -s /config/smb.conf
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
EOF
fi

# set config samba
if [ ! -f "/config/smb.conf" ]; then
cat <<EOF>> /config/smb.conf
[global]
    netbios name = $HOSTNAME
    workgroup = $WORKGROUP
    server string = Samba %v in an Alpine Linux Docker container
    security = user
    guest account = nobody
    map to guest = Bad User

    # disable printing services
    load printers = no
    printing = bsd
    printcap name = /dev/null
    disable spoolss = yes

[$PUBLICNAME]
    comment = Data
    path = /share/$PUBLICFOLDER
    read only = yes
    write list = $USER1
    guest ok = yes
    # getting rid of those annoying .DS_Store files created by Mac users...
    veto files = /._*/.DS_Store/
    delete veto files = yes
EOF

if [[ ! -z "${USER}" ]]; then
if [ ! -D "/share/$PRIVATEFOLDER" ]; then mkdir -p /share/$PRIVATEFOLDER; fi
cat <<EOF>> /config/smb.conf
[$PRIVATENAME]
    comment = Data private
    path = /share/$PRIVATEFOLDER
    writeable = yes
    valid users = babim
    # getting rid of those annoying .DS_Store files created by Mac users...
    veto files = /._*/.DS_Store/
    delete veto files = yes
EOF
fi

fi

exec "$@"
