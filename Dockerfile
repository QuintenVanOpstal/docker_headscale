FROM docker.io/headscale/headscale:0.26.0
USER root
RUN apk add --no-cache bash  # Add shell
COPY headscale/entrypoint/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
