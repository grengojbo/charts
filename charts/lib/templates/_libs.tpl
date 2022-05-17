{{ define "nodeselector" }}
nodeSelector:
  "mcs-nodepool": "system"
tolerations:
- key: dedicated
  operator: Equal
  value: system
{{ end }}
    
{{ define "lib.mysql.AddUserMount" }}
# # volumeMounts:
# - name: app-conf
#   mountPath: /app/configfiles/config.json
  subPath: config.json
{{ end }}

{{/*
Add env to templete
{{- include "lib.envs" ( dict "envs" .Values.preInstallJob.envs "envName" .Values.global.env) | indent 12 }}
*/}}
{{- define "lib.envs" }}
  {{- range $name, $map := .envs }}
- name: {{ $name }}
  value: {{ pluck $.envName $map | first | default $map._default | quote }}
  {{- end }}
{{- end }}

{{/*
Add secret env to templete
{{- include "lib.secrets.envs" ( dict "secrets" .Values.preInstallJob.secrets "externalSecrets" .Values.preInstallJob.externalSecrets "fullName" $fullName "envName" .Values.global.env) | indent 12 }}
*/}}
{{- define "lib.secrets.envs" }}
{{- range $name, $map := .externalSecrets }}
- name: {{ $name }}
  valueFrom:
    secretKeyRef:
      name: {{ pluck $.envName $map | first | default $map._default | quote }}
      key: {{ $name }}
{{- end }}
{{- range $name, $map := .secrets }}
- name: {{ $name }}
  valueFrom:
    secretKeyRef:
      name: {{ printf "%s-secrets" $.fullName }}
      key: {{ $name }}
{{- end }}
{{- end }}

{{/*
Add secret to secret manifest
{{- include "lib.secrets.data" ( dict "secrets" .Values.preInstallJob.secrets "fullName" $fullName "envName" .Values.global.env) | indent 2 }}
*/}}
{{- define "lib.secrets.data" }}
{{- range $name, $map := .secrets }}
{{ $name }}: {{ pluck $.envName $map | first | default $map._default | b64enc | quote }}
{{- end }}
{{- end }}

{{/*
Set resources limits, requests
{{- include "lib.resources" ( dict "resources" .Values.resources "envName" .Values.global.env) | indent 6 }}
*/}}
{{- define "lib.resources" }}
{{- if .resources }}
  {{- $showResources := "no" }}
  {{- $showLimits := "no" }}
  {{- $showRequests := "no" }}
  {{- $limitCpu := "" }}
  {{- $limitMemory := "" }}
  {{- $requestCpu := "" }}
  {{- $requestMemory := "" }}
  {{- if .resources.limits }}
    {{- if .resources.limits.cpu }}
      {{- if .resources.limits.cpu._default }}
        {{- $limitCpu = pluck .envName .resources.limits.cpu | first | default .resources.limits.cpu._default }}
      {{- end }}
    {{- end }}
    {{- if .resources.limits.memory }}
      {{- if .resources.limits.memory._default }}
        {{- $limitMemory = pluck .envName .resources.limits.memory | first | default .resources.limits.memory._default }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if .resources.requests }}
    {{- if .resources.requests.cpu }}
      {{- if .resources.requests.cpu._default }}
        {{- $requestCpu = pluck .envName .resources.requests.cpu | first | default .resources.requests.cpu._default }}
      {{- end }}
    {{- end }}
    {{- if .resources.requests.memory }}
      {{- if .resources.requests.memory._default }}
        {{- $requestMemory = pluck .envName .resources.requests.memory | first | default .resources.requests.memory._default }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- if and (ne $limitCpu "") (ne $limitCpu "none") }}
  {{- $showResources = "yes" }}
  {{- $showLimits = "yes" }}
{{- end }}
{{- if and (ne $limitMemory "") (ne $limitMemory "none") }}
  {{- $showResources = "yes" }}
  {{- $showLimits = "yes" }}
{{- end }}
{{- if and (ne $requestCpu "") (ne $requestCpu "none") }}
  {{- $showResources = "yes" }}
  {{- $showRequests = "yes" }}
{{- end }}
{{- if and (ne $requestMemory "") (ne $requestMemory "none") }}
  {{- $showResources = "yes" }}
  {{- $showRequests = "yes" }}
{{- end }}
{{- if eq $showResources "yes" }}
resources:
{{- if eq $showLimits "yes" }}
  limits:
  {{- if and (ne $limitCpu "") (ne $limitCpu "none") }}
    cpu: {{ $limitCpu | quote }}
  {{- end }}
  {{- if and (ne $limitMemory "") (ne $limitMemory "none") }}
    memory: {{ $limitMemory | quote }}
  {{- end }}
{{- end }}
{{- if eq $showRequests "yes" }}
  requests:
  {{- if and (ne $requestCpu "") (ne $requestCpu "none") }}
    cpu: {{ $requestCpu | quote }}
  {{- end }}
  {{- if and (ne $requestMemory "") (ne $requestMemory "none") }}
    memory: {{ $requestMemory | quote }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Set Node selection
{{- include "lib.nodeSelector" ( dict "nodeRole" .Values.nodeSelector "envName" .Values.global.env) | indent 6 }}
*/}}
{{- define "lib.nodeSelector" }}
{{- $role := pluck .envName .nodeRole | first | default .nodeRole._default }}
{{- if ne $role "none" }}
nodeSelector:
  role: {{ $role }}
{{- end }}
{{- end }}

{{/*
Set Node selection
{{- include "lib.autoscaling.replicaCount" ( dict "autoscaling" .Values.autoscaling "envName" .Values.global.env) | indent 6 }}
*/}}
{{- define "lib.autoscaling.replicaCount" }}
{{- $replicaCount := pluck .envName .autoscaling.minReplicas | first | default .autoscaling.minReplicas._default }}
revisionHistoryLimit: {{ .autoscaling.revisionHistoryLimit | default 3 }}
strategy:
  type: {{ .autoscaling.updateStrategy }}
  {{- if and (eq .autoscaling.updateStrategy "RollingUpdate") (gt $replicaCount (1 | float64)) }}
  rollingUpdate:
    maxSurge: 1  # сколько модулей мы можем добавить за раз
    maxUnavailable: 0 # сколько модулей может быть недоступно во время непрерывного обновления.
    # maxSurge: 0       # эта стратегия сперва удалит а потом добавит pod
    # maxUnavailable: 1 # применять только если количество реплик больше 1
  {{- end }}
{{- if not .autoscaling.enabled }}
replicas: {{ $replicaCount }}
{{- end }}
{{- end }}

{{/*
Container port
{{- include "lib.app.ports" . | indent 12 }}
*/}}
{{- define "lib.app.ports" }}
{{- $self := . }}
{{- $isPhpFpm := "no" }}
{{- if or (eq $self.Values.upstreamFramework "laravel") (eq $self.Values.upstreamFramework "yii2") }}
  {{- if eq $self.Values.php.upstrem "php-fpm" }}
    {{- $isPhpFpm = "yes" }}  
  {{- end }}
{{- end }}
{{- if eq $isPhpFpm "yes" }}
- name: php-fpm
  containerPort: {{ $self.Values.php.port }}
  protocol: TCP
{{- else }}
- name: http
  containerPort: {{ $self.Values.service.port }}
  protocol: TCP
{{- end }}
{{- end }}

{{/*
Creating Image Pull Secrets
.dockerconfigjson: {{ include "lib.imageCredentials" (dict "imageCredentials" .Values.imageCredentials "envName" .Values.global.env) }}
*/}}
{{- define "lib.imageCredentials" }}
{{- $map := pluck .envName .imageCredentials | first | default .imageCredentials._default }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" $map.registry $map.username $map.password $map.email (printf "%s:%s" $map.username $map.password | b64enc) | b64enc }}
{{- end }}

{{/*
Image Pull Secrets
{{- include "lib.imagePullSecret" (dict "imageCredentials" .Values.imageCredentials "imagePullSecrets" .Values.imagePullSecrets "fullName" $fullName "envName" .Values.global.env) | indent 6 }}
*/}}
{{- define "lib.imagePullSecret" }}
{{- if or .imageCredentials .imagePullSecrets }}
imagePullSecrets:
  {{- if .imageCredentials }}
  - {{ (printf "%s-secrets" .fullName) | quote }}
  {{- end }}
  {{- range $i, $val := .imagePullSecrets }}
  - {{ $val | quote }}
  {{- end }}
{{- end }}
{{- end }}