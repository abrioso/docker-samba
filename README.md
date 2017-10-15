[![](https://images.microbadger.com/badges/image/abrioso/samba.svg)](https://microbadger.com/images/abrioso/samba "Get your own image badge on microbadger.com")[![](https://images.microbadger.com/badges/version/abrioso/samba.svg)](https://microbadger.com/images/abrioso/samba "Get your own version badge on microbadger.com")


# samba-alpine
A simple and super lightweight Samba docker container, based on the latest Alpine Linux base image 🐧🐋💻.

By default, the share will be accessible read-only for everyone, with write access for user "rio" with password "letsdance". See smb.conf for details, or feel free to use your own config (see below).

Runs Samba's smbd and nmbd within the same container, using supervisord. Due to the fact that nmbd wants to broadcast
and become the "local master" on your subnet, you need to supply the "--net=host" flag to make the server visible to the hosts subnet (likely your LAN).

Quick start for the impatient:
```shell
docker run -d --net=host -v /path/to/share/:/share --name samba babim/samba
```

When NetBIOS discovery is not needed
```shell
docker run -d -p 137-139:137-139 -p 445:445 -v /path/to/share/:/share --name samba babim/samba
```

With your own smb.conf and supervisord.conf configs:
```shell
docker run -d -p 137-139:137-139 -p 445:445 -v /path/to/configs/:/config -v /path/to/share/:/share --name samba babim/samba
```

To have the container start when the host boots, add docker's restart policy:
```shell
docker run -d --restart=always -p 137-139:137-139 -p 445:445 -v /path/to/share/:/share --name samba babim/samba
```
## Environment value (with -e option)
```
USER
PASS
auid
agid
WORKGROUP
```

## Default without -e
```
USER = samba
PASS = samba
auid/agid = 1000/1000
WORKGROUP = WORKGROUP
```
## BULK
```
-e PUBLICFOLDER="public1 public2 public3"
-e PRIVATEFOLDER="private1 private2 private3"
```
Docker will auto create folder




