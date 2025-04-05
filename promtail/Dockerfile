FROM grafana/promtail:3.4

COPY config.yaml /etc/promtail/config.yaml

CMD ["-config.file=/etc/promtail/config.yaml", "-config.expand-env=true"]
