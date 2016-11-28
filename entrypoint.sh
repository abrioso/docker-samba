#!/bin/sh
# value
USER1=${USER:-samba}
PASS=${PASS:-samba}
WORKGROUP=${WORKGROUP:-WORKGROUP}
HOSTNAME=$(hostname -s)
PUBLICFOLDER1=${PUBLICFOLDER1:-data}
PUBLICNAME1=${PUBLICSHARE1:-$PUBLICFOLDER1}
PRIVATEFOLDER1=${PRIVATEFOLDER1:-private}
PRIVATENAME1=${PRIVATENAME1:-$PRIVATEFOLDER1}

#PUBLICFOLDER2=${PUBLICFOLDER2:-data}
#PUBLICNAME2=${PUBLICNAME2:-$PUBLICFOLDER2}
#PRIVATEFOLDER2=${PRIVATEFOLDER2:-private}
#PRIVATENAME2=${PRIVATENAME2:-$PRIVATEFOLDER2}
#PUBLICFOLDER3=${PUBLICFOLDER3:-data}
#PUBLICNAME3=${PUBLICNAME3:-$PUBLICFOLDER3}
#PRIVATEFOLDER3=${PRIVATEFOLDER3:-private}
#PRIVATENAME3=${PRIVATENAME3:-$PRIVATEFOLDER3}
#PUBLICFOLDER4=${PUBLICFOLDER4:-data}
#PUBLICNAME4=${PUBLICNAME4:-$PUBLICFOLDER4}
#PRIVATEFOLDER4=${PRIVATEFOLDER4:-private}
#PRIVATENAME4=${PRIVATENAME4:-$PRIVATEFOLDER4}

if [ ! -D "/share/$PUBLICFOLDER" ]; then mkdir -p /share/$PUBLICFOLDER; fi

# add a non-root user and group called "samba" with no password, no home dir, no shell, and gid/uid set to 1000
RUN addgroup -g 1000 $USER1 && adduser -D -H -G $USER1 -s /bin/false -u 1000 $USER1

# create a samba user matching our user from above with a very simple password ("samba")
RUN echo -e "$PASS\n$PASS" | smbpasswd -a -s -c /config/smb.conf $USER1

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
    comment = $PUBLICNAME public folder
    path = /share/$PUBLICFOLDER
    read only = yes
    write list = $USER1
    guest ok = yes
    # getting rid of those annoying .DS_Store files created by Mac users...
    veto files = /._*/.DS_Store/
    delete veto files = yes
EOF

if [[ ! -z "${PRIVATEFOLDER1}" ]]; then
if [ ! -D "/share/$PRIVATEFOLDER1" ]; then mkdir -p /share/$PRIVATEFOLDER1; fi
cat <<EOF>> /config/smb.conf
[$PRIVATENAME1]
    comment = $PRIVATENAME1 private folder
    path = /share/$PRIVATEFOLDER1
    writeable = yes
    valid users = babim
    # getting rid of those annoying .DS_Store files created by Mac users...
    veto files = /._*/.DS_Store/
    delete veto files = yes
EOF
fi

if [[ ! -z "${PRIVATEFOLDER2}" ]]; then
if [ ! -D "/share/$PRIVATEFOLDER2" ]; then mkdir -p /share/$PRIVATEFOLDER2; fi
cat <<EOF>> /config/smb.conf
[$PRIVATENAME2]
    comment = $PRIVATENAME2 private folder
    path = /share/$PRIVATEFOLDER2
    writeable = yes
    valid users = babim
    # getting rid of those annoying .DS_Store files created by Mac users...
    veto files = /._*/.DS_Store/
    delete veto files = yes
EOF
fi
if [[ ! -z "${PRIVATEFOLDER3}" ]]; then
if [ ! -D "/share/$PRIVATEFOLDER3" ]; then mkdir -p /share/$PRIVATEFOLDER3; fi
cat <<EOF>> /config/smb.conf
[$PRIVATENAME3]
    comment = $PRIVATENAME3 private folder
    path = /share/$PRIVATEFOLDER3
    writeable = yes
    valid users = babim
    # getting rid of those annoying .DS_Store files created by Mac users...
    veto files = /._*/.DS_Store/
    delete veto files = yes
EOF
fi
if [[ ! -z "${PRIVATEFOLDER4}" ]]; then
if [ ! -D "/share/$PRIVATEFOLDER4" ]; then mkdir -p /share/$PRIVATEFOLDER4; fi
cat <<EOF>> /config/smb.conf
[$PRIVATENAME4]
    comment = $PRIVATENAME4 private folder
    path = /share/$PRIVATEFOLDER4
    writeable = yes
    valid users = babim
    # getting rid of those annoying .DS_Store files created by Mac users...
    veto files = /._*/.DS_Store/
    delete veto files = yes
EOF
fi

if [[ ! -z "${PUBLICFOLDER2}" ]]; then
if [ ! -D "/share/$PUBLICFOLDER2" ]; then mkdir -p /share/$PUBLICFOLDER2; fi
cat <<EOF>> /config/smb.conf
[$PUBLICNAME2]
    comment = $PUBLICNAME2 public folder
    path = /share/$PUBLICFOLDER2
    read only = yes
    write list = $USER1
    guest ok = yes
    # getting rid of those annoying .DS_Store files created by Mac users...
    veto files = /._*/.DS_Store/
    delete veto files = yes
EOF
fi
if [[ ! -z "${PUBLICFOLDER3}" ]]; then
if [ ! -D "/share/$PUBLICFOLDER3" ]; then mkdir -p /share/$PUBLICFOLDER2; fi
cat <<EOF>> /config/smb.conf
[$PUBLICNAME3]
    comment = $PUBLICNAME3 public folder
    path = /share/$PUBLICFOLDER3
    read only = yes
    write list = $USER1
    guest ok = yes
    # getting rid of those annoying .DS_Store files created by Mac users...
    veto files = /._*/.DS_Store/
    delete veto files = yes
EOF
fi
if [[ ! -z "${PUBLICFOLDER4}" ]]; then
if [ ! -D "/share/$PUBLICFOLDER4" ]; then mkdir -p /share/$PUBLICFOLDER4; fi
cat <<EOF>> /config/smb.conf
[$PUBLICNAME4]
    comment = $PUBLICNAME4 public folder
    path = /share/$PUBLICFOLDER4
    read only = yes
    write list = $USER1
    guest ok = yes
    # getting rid of those annoying .DS_Store files created by Mac users...
    veto files = /._*/.DS_Store/
    delete veto files = yes
EOF
fi

fi

exec "$@"
