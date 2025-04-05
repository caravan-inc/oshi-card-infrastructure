FROM grafana/loki:3.4.1

COPY config.yaml /etc/loki/config.yaml

CMD ["-config.file=/etc/loki/config.yaml", "-config.expand-env=true"]
