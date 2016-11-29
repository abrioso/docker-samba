#!/bin/sh
# value
SHARECONFIG=/share/smb.conf

USER=${USER:-samba}
PASS=${PASS:-samba}
UID=${UID:-1000}
GID=${GID:-1000}
WORKGROUP=${WORKGROUP:-WORKGROUP}
HOSTNAME=$(hostname -s)
PUBLICFOLDER1=${PUBLICFOLDER1:-data}
PUBLICNAME1=${PUBLICNAME1:-$PUBLICFOLDER1}
PRIVATEFOLDER1=${PRIVATEFOLDER1:-private}
PRIVATENAME1=${PRIVATENAME1:-$PRIVATEFOLDER1}

#PUBLICFOLDER2=${PUBLICFOLDER2:-data2}
#PUBLICNAME2=${PUBLICNAME2:-$PUBLICFOLDER2}
#PRIVATEFOLDER2=${PRIVATEFOLDER2:-private2}
#PRIVATENAME2=${PRIVATENAME2:-$PRIVATEFOLDER2}
#PUBLICFOLDER3=${PUBLICFOLDER3:-data3}
#PUBLICNAME3=${PUBLICNAME3:-$PUBLICFOLDER3}
#PRIVATEFOLDER3=${PRIVATEFOLDER3:-private3}
#PRIVATENAME3=${PRIVATENAME3:-$PRIVATEFOLDER3}
#PUBLICFOLDER4=${PUBLICFOLDER4:-data4}
#PUBLICNAME4=${PUBLICNAME4:-$PUBLICFOLDER4}
#PRIVATEFOLDER4=${PRIVATEFOLDER4:-private4}
#PRIVATENAME4=${PRIVATENAME4:-$PRIVATEFOLDER4}

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

if [[ ! -z "${PUBLICFOLDER1}" ]]; then
if [ ! -d "/share/$PUBLICFOLDER1" ]; then mkdir -p /share/$PUBLICFOLDER1 && chown -R $UID:$GID /share/$PUBLICFOLDER1; fi
cat <<EOF>> $SHARECONFIG

## share $PUBLICNAME1
[$PUBLICNAME1]
    comment = $PUBLICNAME1 public folder
    path = /share/$PUBLICFOLDER1
    read only = yes
    write list = $USER
    guest ok = yes
    # getting rid of those annoying .DS_Store files created by Mac users...
    veto files = /._*/.DS_Store/
    delete veto files = yes
EOF
fi

if [[ ! -z "${PRIVATEFOLDER1}" ]]; then
if [ ! -d "/share/$PRIVATEFOLDER1" ]; then mkdir -p /share/$PRIVATEFOLDER1 && chown -R $UID:$GID /share/$PRIVATEFOLDER1; fi
cat <<EOF>> $SHARECONFIG

## share $PRIVATENAME1
[$PRIVATENAME1]
    comment = $PRIVATENAME1 private folder
    path = /share/$PRIVATEFOLDER1
    writeable = yes
    valid users = $USER
EOF
fi

if [[ ! -z "${PRIVATEFOLDER2}" ]]; then
if [ ! -d "/share/$PRIVATEFOLDER2" ]; then mkdir -p /share/$PRIVATEFOLDER2 && chown -R $UID:$GID /share/$PRIVATEFOLDER2; fi
cat <<EOF>> $SHARECONFIG

## share $PRIVATENAME2
[$PRIVATENAME2]
    comment = $PRIVATENAME2 private folder
    path = /share/$PRIVATEFOLDER2
    writeable = yes
    valid users = $USER
EOF
fi

if [[ ! -z "${PRIVATEFOLDER3}" ]]; then
if [ ! -d "/share/$PRIVATEFOLDER3" ]; then mkdir -p /share/$PRIVATEFOLDER3 && chown -R $UID:$GID /share/$PRIVATEFOLDER3; fi
cat <<EOF>> $SHARECONFIG

## share $PRIVATENAME3
[$PRIVATENAME3]
    comment = $PRIVATENAME3 private folder
    path = /share/$PRIVATEFOLDER3
    writeable = yes
    valid users = $USER
EOF
fi

if [[ ! -z "${PRIVATEFOLDER4}" ]]; then
if [ ! -d "/share/$PRIVATEFOLDER4" ]; then mkdir -p /share/$PRIVATEFOLDER4 && chown -R $UID:$GID /share/$PRIVATEFOLDER4; fi
cat <<EOF>> $SHARECONFIG

## share $PRIVATENAME4
[$PRIVATENAME4]
    comment = $PRIVATENAME4 private folder
    path = /share/$PRIVATEFOLDER4
    writeable = yes
    valid users = $USER
EOF
fi

if [[ ! -z "${PUBLICFOLDER2}" ]]; then
if [ ! -d "/share/$PUBLICFOLDER2" ]; then mkdir -p /share/$PUBLICFOLDER2 && chown -R $UID:$GID /share/$PUBLICFOLDER2; fi
cat <<EOF>> $SHARECONFIG

## share $PUBLICNAME2
[$PUBLICNAME2]
    comment = $PUBLICNAME2 public folder
    path = /share/$PUBLICFOLDER2
    read only = yes
    write list = $USER
    guest ok = yes
    # getting rid of those annoying .DS_Store files created by Mac users...
    veto files = /._*/.DS_Store/
    delete veto files = yes
EOF
fi

if [[ ! -z "${PUBLICFOLDER3}" ]]; then
if [ ! -d "/share/$PUBLICFOLDER3" ]; then mkdir -p /share/$PUBLICFOLDER3 && chown -R $UID:$GID /share/$PUBLICFOLDER3; fi
cat <<EOF>> $SHARECONFIG

## share $PUBLICNAME3
[$PUBLICNAME3]
    comment = $PUBLICNAME3 public folder
    path = /share/$PUBLICFOLDER3
    read only = yes
    write list = $USER
    guest ok = yes
    # getting rid of those annoying .DS_Store files created by Mac users...
    veto files = /._*/.DS_Store/
    delete veto files = yes
EOF
fi

if [[ ! -z "${PUBLICFOLDER4}" ]]; then
if [ ! -d "/share/$PUBLICFOLDER4" ]; then mkdir -p /share/$PUBLICFOLDER4 && chown -R $UID:$GID /share/$PUBLICFOLDER4; fi
cat <<EOF>> $SHARECONFIG

## share $PUBLICNAME4
[$PUBLICNAME4]
    comment = $PUBLICNAME4 public folder
    path = /share/$PUBLICFOLDER4
    read only = yes
    write list = $USER
    guest ok = yes
    # getting rid of those annoying .DS_Store files created by Mac users...
    veto files = /._*/.DS_Store/
    delete veto files = yes
EOF
fi

# add a non-root user and group called "samba" with no password, no home dir, no shell, and gid/uid set to 1000
addgroup -g 1000 $USER && adduser -D -H -G $USER -s /bin/false -u 1000 $USER

# create a samba user matching our user from above with a very simple password ("samba")
echo -e "$PASS\n$PASS" | smbpasswd -a -s -c $SHARECONFIG $USER

fi

exec "$@"
