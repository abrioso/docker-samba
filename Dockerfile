FROM babim/alpinebase

LABEL Description="Simple and lightweight Samba docker container, based on Alpine Linux." Version="0.1"

# install samba and supervisord and clear the cache afterwards
RUN apk add --no-cache samba samba-common-tools supervisor

# create a dir for the config and the share
RUN mkdir /config /share

# copy config files from project folder to get a default config going for samba and supervisord
COPY *.conf /config/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# add a non-root user and group called "samba" with no password, no home dir, no shell, and gid/uid set to 1000
RUN addgroup -g 1000 samba && adduser -D -H -G samba -s /bin/false -u 1000 samba

# create a samba user matching our user from above with a very simple password ("samba")
RUN echo -e "samba\nsamba" | smbpasswd -a -s -c /config/smb.conf samba

# volume mappings
VOLUME /config /shared

# exposes samba's default ports (137, 138 for nmbd and 139, 445 for smbd)
EXPOSE 137/udp 138/udp 139 445

ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-c", "/config/supervisord.conf"]
