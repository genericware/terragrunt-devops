{{/*
argo-cd
*/}}
{{/* todo: argo-cd config */}}
{{- define "app-of-apps.valuesObjectArgoCD" -}}
{{- end }}

{{/*
cert-manager
*/}}
{{/* todo: link logging format */}}
{{/* todo: tracing */}}
{{- define "app-of-apps.valuesObjectCertManager" -}}
installCRDs: true
extraArgs:
  - --logging-format=json
webhook:
  extraArgs:
    - --logging-format=json
cainjector:
  extraArgs:
    - --logging-format=json
startupapicheck:
  podAnnotations:
    sidecar.istio.io/inject: "false"
{{- end }}

{{/*
istio-base
*/}}
{{- define "app-of-apps.valuesFilesIstioBase" -}}
- values.yaml
{{- end }}

{{/*
istio-ingress
*/}}
{{- define "app-of-apps.valuesObjectIstioIngress" -}}
global:
  logAsJson: true
labels:
  app.kubernetes.io/name: istio-ingress
  app.kubernetes.io/version: v{{ .Values.applications.istio.revision }}
{{- end }}

{{/*
istiod
*/}}
{{/* todo: link log format */}}
{{/* todo: link tracing */}}
{{- define "app-of-apps.valuesObjectIstiod" -}}
pilot:
  podLabels:
    app.kubernetes.io/name: istiod
    app.kubernetes.io/version: v{{ .Values.applications.istio.revision }}
meshConfig:
  rootNamespace: {{ .Values.applications.istio.istiod.namespace }}
  trustDomain: "cluster.local"
global:
  logAsJson: true
  accessLogFile: /dev/stdout
  proxy:
    tracer: "zipkin"
  tracer:
    zipkin:
      address: "tempo-distributed-distributor.tempo.svc.cluster.local:9411"
{{- end }}

{{/*
kiali-operator
*/}}
{{/* todo: link log format */}}
{{/* todo: link log level */}}
{{/* todo: link metrics enable/disable */}}
{{/* todo: link tracing enable/disable */}}
{{/* todo: link grafana enable/disable */}}
{{- define "app-of-apps.valuesObjectKialiOperator" -}}
cr:
    create: true
    namespace: {{ .Values.applications.kiali.namespace }}
    spec:
    deployment:
      logger:
        log_level: info
        log_format: json
    api:
      namespaces:
        exclude:
          - "kube-public"
          - "kube-system"
          - "kube-node-lease"
          - "kiali-operator"
    server:
      audit_log: true
      cors_allow_all: false
      gzip_enabled: true
      observability:
        metrics:
          enabled: true
          port: 9090
        tracing:
          collector_url: "http://jaeger-operator-jaeger-collector.jaeger:14268/api/traces"
          enabled: true
      port: 20001
    istio_labels:
      app_label_name: "app.kubernetes.io/name"
      version_label_name: "app.kubernetes.io/version"
    kiali_feature_flags:
      certificates_information_indicators:
        enabled: true
        secrets:
        - "cacerts"
        - "istio-ca-secret"
      ui_defaults:
        graph:
          traffic:
            grpc: "requests" # Valid values: none, requests, sent, received and total
            http: "requests" # Valid values: none and requests
            tcp:  "sent"     # Valid values: none, sent, received and total
          find_options:
          - description: "Find: slow edges (> 1s)"
            expression: "rt > 1000"
          - description: "Find: unhealthy nodes"
            expression:  "! healthy"
          - description: "Find: unknown nodes"
            expression:  "name = unknown"
          hide_options:
          - description: "Hide: healthy nodes"
            expression: "healthy"
          - description: "Hide: unknown nodes"
            expression:  "name = unknown"
        metrics_per_refresh: "1m"
        namespaces: ["istio-system", "istio-ingress"]
        refresh_interval: "60s"
    health_config:
      rate:
        - namespace: ".*"
          kind: ".*"
          name: ".*"
          tolerance:
            - code: "^5\\d\\d$"
              direction: ".*"
              protocol: "http"
              degraded: 0
              failure: 10
            - code: "^4\\d\\d$"
              direction: ".*"
              protocol: "http"
              degraded: 10
              failure: 20
            - code: "^[1-9]$|^1[0-6]$"
              direction: ".*"
              protocol: "grpc"
              degraded: 0
              failure: 10
    external_services:
      istio:
        root_namespace: {{ .Values.applications.istio.istiod.namespace }}
        url_service_version: "http://istiod.istio-system:15014/version"
        istiod_pod_monitoring_port: 15014
        component_status:
          components:
          - app_label: "istiod"
            is_core: true
            is_proxy: false
            namespace: {{ .Values.applications.istio.istiod.namespace }}
          - app_label: "istio-ingress"
            is_core: false
            is_proxy: true
            namespace: {{ .Values.applications.istio.gateway.namespace }}
          enabled: true
      grafana:
        enabled: true
        in_cluster_url: "http://kube-prometheus-grafana.kube-prometheus:80/"
        url: "http://kube-prometheus-grafana.kube-prometheus:3000/"
      prometheus:
        url: "http://kube-prometheus-kube-prome-prometheus.kube-prometheus:9090/"
        is_core: true
      tracing:
        enabled: true
        in_cluster_url: "http://tempo-distributed-gateway.tempo.svc.cluster.local:80/jaeger-query"
        use_grpc: false
{{- end }}

{{/*
kube-prometheus-stack
*/}}
{{/* todo: link log format */}}
{{/* todo: link log level */}}
{{/* todo: tracing */}}
{{/* todo: link tracing */}}
{{/* todo: enable/disable loki datasource */}}
{{/* todo: enable/disable tempo datasource */}}
{{- define "app-of-apps.valuesObjectKubePrometheusStack" -}}
alertmanager:
  alertmanagerSpec:
    logLevel: info
    logFormat: json

grafana:
  grafana.ini:
    log:
      mode: console
    log.console:
      level: info
      format: json
  additionalDataSources:
    # tempo
    - name: Tempo
      type: tempo
      uid: tempo
      access: proxy
      url: http://tempo-distributed-query-frontend.tempo.svc.cluster.local:3100/
      basicAuth: false
      isDefault: false
      editable: false
      version: 1
      apiVersion: 1
      jsonData:
        httpMethod: GET
        serviceMap:
          datasourceUid: prometheus
    # loki
    - name: Loki
      type: loki
      uid: loki
      access: proxy
      url: http://loki-distributed-query-frontend.loki.svc.cluster.local:3100/
      basicAuth: false
      isDefault: false
      editable: false
      version: 1
      apiVersion: 1

prometheusOperator:
  logLevel: info
  logFormat: json
  podLabels:
    app.kubernetes.io/name: prometheus-operator

  ## Admission webhook support for PrometheusRules
  admissionWebhooks:
    certManager:
      enabled: true
      issuerRef:
        {{ if eq .Values.network.issuer "selfsigned" }}
        name: istio-ca
        {{ end }}

prometheus:
  prometheusSpec:
    logLevel: info
    logFormat: json
    serviceMonitorSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false
    additionalScrapeConfigs:
      - job_name: 'kubernetes-pods'
        honor_labels: true

        kubernetes_sd_configs:
          - role: pod

        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape_slow]
            action: drop
            regex: true
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scheme]
            action: replace
            regex: (https?)
            target_label: __scheme__
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
          - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
            action: replace
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: $1:$2
            target_label: __address__
          - action: labelmap
            regex: __meta_kubernetes_pod_annotation_prometheus_io_param_(.+)
            replacement: __param_$1
          - action: labelmap
            regex: __meta_kubernetes_pod_label_(.+)
          - source_labels: [__meta_kubernetes_namespace]
            action: replace
            target_label: namespace
          - source_labels: [__meta_kubernetes_pod_name]
            action: replace
            target_label: pod
          - source_labels: [__meta_kubernetes_pod_phase]
            regex: Pending|Succeeded|Failed|Completed
            action: drop

kube-state-metrics:
  metricLabelsAllowlist:
    - pods=[*]
    - deployments=[app.kubernetes.io/name,app.kubernetes.io/component,app.kubernetes.io/instance]
{{- end }}

{{/*
loki-distributed
*/}}
{{/* todo: link log format */}}
{{/* todo: link log level */}}
{{/* todo: tracing */}}
{{/* todo: link tracing */}}
{{/* todo: secrets */}}
{{/* todo: link storage */}}
{{- define "app-of-apps.valuesObjectLokiDistributed" -}}
gateway:
  nginxConfig:
    logFormat: |
      main escape=json
        '{'
          '"time_local":"$time_local",'
          '"remote_addr":"$remote_addr",'
          '"remote_user":"$remote_user",'
          '"request":"$request",'
          '"status": "$status",'
          '"body_bytes_sent":"$body_bytes_sent",'
          '"request_time":"$request_time",'
          '"http_referrer":"$http_referer",'
          '"http_user_agent":"$http_user_agent"'
        '}';
loki:
  podLabels:
    app.kubernetes.io/name: loki-distributed
    app.kubernetes.io/version: v{{ .Values.applications.loki.revision }}
  config: |
    auth_enabled: false

    server:
      http_listen_port: 3100
      log_format: json
      log_level: info

    common:
      compactor_address: https://loki.loki-distributed-compactor.svc.cluster.local:3100

    distributor:
      ring:
        kvstore:
          store: memberlist

    memberlist:
      join_members:
        - loki-distributed-memberlist

    ingester:
      chunk_block_size: 262144
      chunk_encoding: snappy
      chunk_idle_period: 30m
      chunk_retain_period: 1m
      lifecycler:
        ring:
          kvstore:
            store: memberlist
          replication_factor: 1
      max_transfer_retries: 0
      wal:
        dir: /var/loki/wal

    limits_config:
      enforce_metric_name: false
      max_cache_freshness_per_query: 10m
      reject_old_samples: true
      reject_old_samples_max_age: 168h
      split_queries_by_interval: 15m

    schema_config:
      configs:
      - from: 2020-09-07
        store: boltdb-shipper
        object_store: s3
        schema: v11
        index:
          period: 24h
          prefix: loki_index_

    storage_config:
      aws:
        s3: s3://admin:testtesttest@minio.minio.svc.cluster.local:9000/loki-local-development
        s3forcepathstyle: true

      boltdb_shipper:
        active_index_directory: /var/loki/index
        cache_location: /var/loki/cache
        cache_ttl: 168h
        shared_store: s3

    runtime_config:
      file: /var/loki-distributed-runtime/runtime.yaml

    chunk_store_config:
      max_look_back_period: 0s

    table_manager:
      retention_deletes_enabled: false
      retention_period: 0s

    query_range:
      align_queries_with_step: true
      cache_results: true
      max_retries: 5
      results_cache:
        cache:
          enable_fifocache: true
          fifocache:
            max_size_items: 1024
            ttl: 24h

    frontend_worker:
      frontend_address: loki-distributed-query-frontend:9095

    frontend:
      compress_responses: true
      log_queries_longer_than: 5s
      tail_proxy_url: http://loki-distributed-querier:3100

    compactor:
      shared_store: s3

    ruler:
      alertmanager_url: https://alertmanager.xx
      external_url: https://alertmanager.xx
      ring:
        kvstore:
          store: memberlist
      rule_path: /tmp/loki/scratch
      storage:
        local:
          directory: /etc/loki/rules
        type: local
{{- end }}

{{/*
minio
*/}}
{{/* todo: link log format */}}
{{/* todo: link log level */}}
{{/* todo: tracing */}}
{{/* todo: secrets */}}
{{- define "app-of-apps.valuesObjectMinIO" -}}
mode: standalone
podLabels:
  app.kubernetes.io/name: minio
  app.kubernetes.io/version: v{{ .Values.applications.minio.targetRevision }}
existingSecret: root-minio-secret
persistence:
  size: 5Gi
resources:
  requests:
    memory: 4Gi
postJob:
  podAnnotations:
    sidecar.istio.io/inject: "false"
users:
  - accessKey: admin
    existingSecret: admin-minio-secret
    existingSecretKey: secretKey
    policy: consoleAdmin
  - accessKey: loki
    existingSecret: loki-minio-secret
    existingSecretKey: secretKey
    policy: readwrite
  - accessKey: tempo
    existingSecret: tempo-minio-secret
    existingSecretKey: secretKey
    policy: readwrite

buckets:
  - name: loki-{{ .Values.project.region }}-{{ .Values.project.environment }}
    policy: none
    purge: false
  - name: tempo-{{ .Values.project.region }}-{{ .Values.project.environment }}
    policy: none
    purge: false
{{- end }}

{{/*
promtail
*/}}
{{- define "app-of-apps.valuesObjectPromtail" -}}
podLabels:
  app.kubernetes.io/version: v{{ .Values.applications.promtail.revision }}
config:
  logLevel: info
  logFormat: json
  clients:
    - url: http://loki-distributed-gateway.loki/loki/api/v1/push
  enableTracing: {{ .Values.tracing.enabled }}
  snippets:
    pipelineStages:
      - json:
          expressions:
            log: log
            stream: stream
            time: time
      # argo-cd
      - match:
          selector: '{instance="argo-cd", container!="istio-proxy"}'
          stages:
            - json:
                expressions:
                  level: level
                source: log
            - labels:
                level: level
            - output:
                source: log
      # cert-manager
      - match:
          selector: '{instance="cert-manager", container!="istio-proxy"}'
          stages:
            - output:
                source: log
      {{ if .Values.applications.istio.enabled }}
      # istio
      - match:
          selector: '{app=~"istio-ingress|istiod"}'
          stages:
            - json:
                expressions:
                  level: level
                source: log
            - labels:
                level: level
            - output:
                source: log
      - match:
          selector: '{container="istio-proxy"}'
          stages:
            - json:
                expressions:
                  level: level
                source: log
            - labels:
                level: level
            - output:
                source: log
      {{- end }}
      {{if .Values.applications.kiali.enabled }}
      # kiali
      - match:
          selector: '{instance="kiali", container!="istio-proxy"}'
          stages:
            - json:
                expressions:
                  level: level
                source: log
            - labels:
                level: level
            - output:
                source: log
      {{- end }}
      {{if .Values.applications.knative.enabled }}
      # knative
      - match:
          selector: '{app=~"knative-eventing|knative-serving", container!="istio-proxy"}'
          stages:
            - json:
                expressions:
                  level: level
                source: log
            - labels:
                level: level
            - output:
                source: log
      - match:
          selector: '{app="knative-operator", container!="istio-proxy"}'
          stages:
            - json:
                expressions:
                  level: severity
                source: log
            - labels:
                level: level
            - output:
                source: log
      {{- end }}
      {{if .Values.applications.prometheus.enabled }}
      # prometheus
      - match:
          selector: '{instance="kube-prometheus", container!="istio-proxy"}'
          stages:
            - json:
                expressions:
                  level: level
                source: log
            - labels:
                level: level
            - output:
                source: log
      {{- end }}
      {{if .Values.applications.loki.enabled }}
      # loki
      - match:
          selector: '{instance="loki-distributed", container!~"istio-proxy|nginx"}'
          stages:
            - json:
                expressions:
                  level: level
                source: log
            - labels:
                level: level
            - output:
                source: log
      {{- end }}
      {{ if .Values.applications.tempo.enabled }}
      # tempo
      - match:
          selector: '{instance="tempo-distributed", container!="istio-proxy"}'
          stages:
            - json:
                expressions:
                  level: level
                source: log
            - labels:
                level: level
            - output:
                source: log
      {{- end }}
{{- end }}

{{/*
strimzi-kafka-operator
*/}}
{{- define "app-of-apps.valuesObjectStrimziKafkaOperator" -}}
logConfiguration: |
  name = COConfig
  monitorInterval = 30

  appender.console.type = Console
  appender.console.name = STDOUT
  appender.console.layout.type = JsonLayout
  appender.console.layout.properties = true
  appender.console.layout.compact = true
  appender.console.layout.eventEol = true

  rootLogger.level = INFO
  rootLogger.appenderRefs = stdout
  rootLogger.appenderRef.console.ref = STDOUT
  rootLogger.additivity = false

  # Kafka AdminClient logging is a bit noisy at INFO level
  logger.kafka.name = org.apache.kafka
  logger.kafka.level = WARN
  logger.kafka.additivity = false

  # Zookeeper is very verbose even on INFO level -> We set it to WARN by default
  logger.zookeepertrustmanager.name = org.apache.zookeeper
  logger.zookeepertrustmanager.level = WARN
  logger.zookeepertrustmanager.additivity = false

  # Keeps separate level for Netty logging -> to not be changed by the root logger
  logger.netty.name = io.netty
  logger.netty.level = INFO
  logger.netty.additivity = false

labels:
  app.kubernetes.io/name: strimzi-kafka-operator
  app.kubernetes.io/version: v{{ .Values.applications.kafka.revision }}
{{- end }}

{{/*
tempo-distributed
*/}}
{{/* todo: link log format */}}
{{/* todo: link log level */}}
{{/* todo: tracing */}}
{{/* todo: link tracing */}}
{{/* todo: secrets */}}
{{/* todo: metrics */}}
{{/* todo: link metrics */}}
{{/* todo: link storage */}}
{{- define "app-of-apps.valuesObjectTempoDistributed" -}}
tempo:
  memberlist:
    appProtocol: tcp
server:
  logLevel: info
  logFormat: json
querier:
  appProtocol:
    grpc: grpc
  frontend_worker:
    frontend_address: tempo-distributed-query-frontend.tempo.svc.cluster.local:3100
ingester:
  appProtocol:
    grpc: grpc
  persistence:
    enabled: true
distributor:
  appProtocol:
    grpc: grpc
metricsGenerator:
  enabled: true
  appProtocol:
    grpc: grpc
queryFrontend:
  query:
    enabled: true
    extraArgs:
      - '--grpc-storage-plugin.configuration-file=/config/tempo-query.yaml'
    extraEnv:
      - name: TMPDIR
        value: /tmp2
    extraVolumeMounts:
      - mountPath: /tmp2
        name: tmp2
      - name: config-query
        mountPath: /config/tempo-query.yaml
        subPath: tempo-query.yaml
  extraVolumes:
    - name: tmp2
      emptyDir: { }
    - name: config-query
      configMap:
        name: tempo-distributed-config
        items:
          - key: "tempo-query.yaml"
            path: "tempo-query.yaml"
gateway:
  enabled: true
  nginxConfig:
    serverSnippet: |
      location ~ ^/jaeger-query/(.*) {
        proxy_pass       http://tempo-distributed-query-frontend.tempo.svc.cluster.local:16686/$1$is_args$args;
      }
minio:
  enabled: false
storage:
  trace:
    backend: s3
    s3:
      bucket: tempo-{{ .Values.project.region }}-{{ .Values.project.environment }}
      access_key: tempo
      secret_key: testtesttest
      endpoint: minio.minio.svc.cluster.local:9000
      insecure: true
traces:
  otlp:
    http:
      enabled: true
  jaeger:
    grpc:
      enabled: true
  zipkin:
    enabled: true
{{- end }}
