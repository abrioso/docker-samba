#!/bin/sh
# value
SHARECONFIG=/share/smb.conf

USER=${USER:-samba}
PASS=${PASS:-samba}
auid=${auid:-1000}
agid=${agid:-$auid}
WORKGROUP=${WORKGROUP:-WORKGROUP}
HOSTNAME=$(hostname -s)

PUBLICFOLDER=${PUBLICFOLDER:-data}
PRIVATEFOLDER=${PRIVATEFOLDER:-private}
PUBLICNAME=${PUBLICNAME:-$PUBLICFOLDER}
PRIVATENAME=${PRIVATENAME:-$PRIVATEFOLDER}

# set config supervisord
if [ ! -f "/config/supervisord.conf" ]; then
cat <<EOF>> /config/supervisord.conf
[supervisord]
nodaemon=true
loglevel=info
# set some defaults and start samba in foreground (-F), logging to stdout (-S), and using our config (-s path)
[program:smbd]
command=smbd -F -S -s $SHARECONFIG
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
[program:nmbd]
command=nmbd -F -S -s $SHARECONFIG
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
EOF
fi

# set config samba
if [ ! -f "$SHARECONFIG" ]; then
cat <<EOF>> $SHARECONFIG
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
EOF

# bulk
if [[ ! -z "${PUBLICFOLDER}" ]]; then
for mnt in `echo ${PUBLICFOLDER}`; do
  src=$(echo $mnt | awk -F':' '{ print $1 }')
  if [ ! -d "/share/$src" ]; then mkdir -p /share/$src && chown -R $UID:$GID "/share/$src"; fi
  cat <<EOF>> $SHARECONFIG

## share $src
[$src]
    comment = $src public folder
    path = "/share/$src"
    read only = yes
    write list = $USER
    guest ok = yes
    # getting rid of those annoying .DS_Store files created by Mac users...
    veto files = /._*/.DS_Store/
    delete veto files = yes
EOF
done
fi

if [[ ! -z "${PRIVATEFOLDER}" ]]; then
for mnt in `echo ${PRIVATEFOLDER}`; do
  src=$(echo $mnt | awk -F':' '{ print $1 }')
  if [ ! -d "/share/$src" ]; then mkdir -p /share/$src && chown -R $UID:$GID "/share/$src"; fi
  cat <<EOF>> $SHARECONFIG

## share $src
[$src]
    comment = $src private folder
    path = "/share/$src"
    writeable = yes
    valid users = $USER
EOF
done
fi

fi

if [[ "$auid" = "0" ]]; then
       echo "You cant run with root"
       pause 30
       exit
elif id $USER >/dev/null 2>&1; then
        echo "user exists"
else
        echo "user does not exist"
# add a non-root user and group called "samba" with no password, no home dir, no shell, and gid/uid set to 1000
addgroup -g $agid $USER && adduser -D -H -G $USER -s /bin/false -u $auid $USER
# create a samba user matching our user from above with a very simple password ("samba")
echo -e "$PASS\n$PASS" | smbpasswd -a -s -c $SHARECONFIG $USER
fi

exec "$@"
