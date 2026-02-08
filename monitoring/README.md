# Monitoring configurations for GitOps repo

#

# Các file monitoring config từ repo cũ sẽ được chuyển sang đây:

# - prometheus.yml → monitoring/prometheus/prometheus.yml

# - alert_rules.yml → monitoring/prometheus/alert_rules.yml

# - prometheus-recording-rules.yml → monitoring/prometheus/recording_rules.yml

# - alertmanager.yml → monitoring/alertmanager/alertmanager.yml

# - grafana/ → monitoring/grafana/

# - loki-config.yml → monitoring/loki/loki-config.yml

# - promtail-config.yml → monitoring/promtail/promtail-config.yml

# - logstash.conf → monitoring/logstash/logstash.conf

#

# Monitoring configs thuộc về GitOps repo vì chúng là K8s deployment configs,

# KHÔNG phải application source code hay infrastructure provisioning.
