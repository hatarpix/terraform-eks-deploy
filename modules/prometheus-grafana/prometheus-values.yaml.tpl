prometheus:
  prometheusSpec:
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: efs-sc
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 31Gi
    additionalScrapeConfigs: |
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
          - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
            action: replace
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: $1:$2
            target_label: __address__
      - job_name: loki
        static_configs:
          - targets: ["loki.loki.svc.cluster.local:3100"]
          
alertmanager:
  alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
          storageClassName: efs-sc
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 2Gi

grafana:
  assertNoLeakedSecrets: false
  enabled: true
  adminPassword: '${grafana_password}'
  ingress:
    enabled: true
    ingressClassName: nginx
    annotations:
      kubernetes.io/ingress.class: nginx
    hosts:
    - ${grafana_host}
    path: /
    tls:
    - secretName: ssl-cert
      hosts:
      - ${grafana_host}
  grafana.ini:
    database:
      host: ${grafana_db_host}
      name: ${grafana_db_name}
      password: ${grafana_db_password}
      type: postgres
      user: ${grafana_db_user}
      ssl_mode: require
    server:
      domain: ${grafana_host}
      root_url: https://${grafana_host}
    smtp:
      enabled: true
      host: ${email_server}:${email_port}
      from_address: ${grafana_email}
      from_name: Grafana
      startTLS_policy: OpportunisticStartTLS
  smtp:
    existingSecret: email
    userKey: email_user
    passwordKey: email_password
  additionalDataSources:
    - name: Loki
      type: loki
      url: http://loki-gateway.loki.svc.cluster.local
      access: proxy
      isDefault: false
