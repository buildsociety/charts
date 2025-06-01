{{/*
Generate PersistentVolumes and PersistentVolumeClaims for an application
Usage: {{ include "common.persistence" (dict "appName" "radarr" "persistence" .Values.radarr.persistence "context" .) }}
*/}}
{{- define "common.persistence" -}}
{{- $appName := .appName -}}
{{- $persistence := .persistence -}}
{{- $context := .context -}}
{{- range $volumeName, $volume := $persistence }}
{{- if and $volume.enabled (not $volume.existingClaim) }}
{{- if $volume.nfs.enabled }}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ include (printf "%s.fullname" $appName) $context }}-{{ $volumeName }}-nfs
  labels:
    {{- include (printf "%s.labels" $appName) $context | nindent 4 }}
    component: {{ $volumeName }}-nfs
spec:
  capacity:
    storage: {{ $volume.size }}
  accessModes:
    - {{ $volume.accessMode }}
  nfs:
    server: {{ $volume.nfs.server }}
    path: {{ $volume.nfs.path }}
  {{- if $volume.nfs.mountOptions }}
  mountOptions:
    {{- toYaml $volume.nfs.mountOptions | nindent 4 }}
  {{- end }}
  persistentVolumeReclaimPolicy: Retain
  storageClassName: ""
{{- end }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include (printf "%s.fullname" $appName) $context }}-{{ $volumeName }}
  labels:
    {{- include (printf "%s.labels" $appName) $context | nindent 4 }}
    component: {{ $volumeName }}
spec:
  accessModes:
    - {{ $volume.accessMode }}
  resources:
    requests:
      storage: {{ $volume.size }}
  {{- if $volume.nfs.enabled }}
  volumeName: {{ include (printf "%s.fullname" $appName) $context }}-{{ $volumeName }}-nfs
  storageClassName: ""
  {{- else if $volume.storageClass }}
  storageClassName: {{ $volume.storageClass }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generate Gluetun PersistentVolume and PersistentVolumeClaim
Usage: {{ include "common.gluetun.persistence" (dict "appName" "radarr" "gluetun" .Values.gluetun "context" .) }}
*/}}
{{- define "common.gluetun.persistence" -}}
{{- $appName := .appName -}}
{{- $gluetun := .gluetun -}}
{{- $context := .context -}}
{{- if and $gluetun.enabled $gluetun.persistence.enabled (not $gluetun.persistence.existingClaim) }}
{{- if $gluetun.persistence.nfs.enabled }}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ include (printf "%s.fullname" $appName) $context }}-gluetun-nfs
  labels:
    {{- include (printf "%s.labels" $appName) $context | nindent 4 }}
    component: gluetun-nfs
spec:
  capacity:
    storage: {{ $gluetun.persistence.size }}
  accessModes:
    - {{ $gluetun.persistence.accessMode }}
  nfs:
    server: {{ $gluetun.persistence.nfs.server }}
    path: {{ $gluetun.persistence.nfs.path }}
  {{- if $gluetun.persistence.nfs.mountOptions }}
  mountOptions:
    {{- toYaml $gluetun.persistence.nfs.mountOptions | nindent 4 }}
  {{- end }}
  persistentVolumeReclaimPolicy: Retain
  storageClassName: ""
{{- end }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include (printf "%s.fullname" $appName) $context }}-gluetun
  labels:
    {{- include (printf "%s.labels" $appName) $context | nindent 4 }}
    component: gluetun
spec:
  accessModes:
    - {{ $gluetun.persistence.accessMode }}
  resources:
    requests:
      storage: {{ $gluetun.persistence.size }}
  {{- if $gluetun.persistence.nfs.enabled }}
  volumeName: {{ include (printf "%s.fullname" $appName) $context }}-gluetun-nfs
  storageClassName: ""
  {{- else if $gluetun.persistence.storageClass }}
  storageClassName: {{ $gluetun.persistence.storageClass }}
  {{- end }}
{{- end }}
{{- end }}