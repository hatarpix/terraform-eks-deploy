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
  auth_enabled: false
  commonConfig:
    replication_factor: 1
  schemaConfig:
    configs:
    - from: "2024-01-01"
      store: tsdb
      index:
        prefix: loki_index_
        period: 24h
      object_store: s3
      schema: v13
  storage:
    type: 's3'
    bucketNames:
      chunks: ${chunks_bucket}
      ruler:  ${ruler_bucket}
      admin:  ${admin_bucket}
    s3:
      region: ${region}
chunksCache:
  allocatedMemory: 1024

