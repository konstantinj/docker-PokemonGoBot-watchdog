FROM docker
RUN apk add bash coreutils --no-cache
COPY watchdog.sh /
CMD ["/watchdog.sh"]
