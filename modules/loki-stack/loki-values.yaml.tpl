deploymentMode: SingleBinary
singleBinary:
  persistence:
    size: 1Gi
    storageClass: efs-sc
serviceAccount:
  create: true
  name: loki-sa
  annotations:
    eks.amazonaws.com/role-arn: ${role_arn}
loki:
  server:
    grpc_server_max_recv_msg_size: 20971520
    grpc_server_max_send_msg_size: 20971520
  auth_enabled: false
  structuredConfig:
    memberlist:
      cluster_label: "loki"
    schema_config:
      configs:
      - from: "2024-01-01"
        store: tsdb
        object_store: "s3"
        schema: "v13"
        index:
          period: 24h
          prefix: "loki_index_"
  compactor:
    compaction_interval: 1h
    retention_enabled: true
    retention_delete_delay: 48h
    retention_delete_worker_count: 150
    delete_request_store: s3
  limits_config:
    retention_period: 180d
    ingestion_rate_mb: 4
    ingestion_burst_size_mb: 6
  storage:
    bucketNames:
      chunks: ${chunks_bucket}
      ruler: ${chunks_bucket}
      admin: ${chunks_bucket}
    s3:
      region: ${region}
#  ingester:
#    autoforget_unhealthy: true
  storage_config:
  memcached:
    chunk_cache:
      enabled: true
      max_item_size: 2mb
      max_size: 512mb
    results_cache:
      enabled: true
      max_size: 512mb
  commonConfig:
    replication_factor: 1

resultsCache:
  enabled: false
chunksCache:
  enabled: false

write:
  replicas: 1
  autoscaling:
    enabled: false
  extraArgs:
    - "-log.level=info"
  maxUnavailable: 0

read:
  replicas: 1
  autoscaling:
    enabled: false
  extraArgs:
    - "-log.level=info"
  maxUnavailable: 0

backend:
  replicas: 1
  autoscaling:
    enabled: false
  extraArgs:
    - "-log.level=info"
  maxUnavailable: 0

lokiCanary:
  enabled: false

sidecar:
  rules:
    enabled: false

serviceMonitor:
  enabled: false

monitoring:
  selfMonitoring:
    enabled: false

test:
  enabled: false

enterprise:
  enabled: false

gateway:
  enabled: false
