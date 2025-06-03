{{/*
Expand the name of the chart.
*/}}
{{- define "radarr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "radarr.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "radarr.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "radarr.labels" -}}
helm.sh/chart: {{ include "radarr.chart" . }}
{{ include "radarr.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "radarr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "radarr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "radarr.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "radarr.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate certificates for webhook
*/}}
{{- define "radarr.gen-certs" -}}
{{- $altNames := list ( printf "%s.%s" (include "radarr.name" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "radarr.name" .) .Release.Namespace ) -}}
{{- $ca := genCA "radarr-ca" 365 -}}
{{- $cert := genSignedCert ( include "radarr.name" . ) nil $altNames 365 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end }}

{{/*
Generate PVC name for a given volume
*/}}
{{- define "radarr.pvcName" -}}
{{- $volumeName := .volumeName -}}
{{- $context := .context -}}
{{- $volume := index $context.Values.radarr.persistence $volumeName -}}
{{- if $volume.existingClaim -}}
{{- $volume.existingClaim -}}
{{- else -}}
{{- printf "%s-%s" (include "radarr.fullname" $context) $volumeName -}}
{{- end -}}
{{- end }}

{{/*
Generate PV name for NFS volumes
*/}}
{{- define "radarr.pvName" -}}
{{- $volumeName := .volumeName -}}
{{- $context := .context -}}
{{- printf "%s-%s-nfs" (include "radarr.fullname" $context) $volumeName -}}
{{- end }}

{{/*
Check if a volume should create PVC (enabled and no existing claim)
*/}}
{{- define "radarr.shouldCreatePVC" -}}
{{- $volumeName := .volumeName -}}
{{- $context := .context -}}
{{- $volume := index $context.Values.radarr.persistence $volumeName -}}
{{- if and $volume.enabled (not $volume.existingClaim) -}}
{{- true -}}
{{- end -}}
{{- end }}

{{/*
Check if a volume should create NFS PV
*/}}
{{- define "radarr.shouldCreateNFSPV" -}}
{{- $volumeName := .volumeName -}}
{{- $context := .context -}}
{{- $volume := index $context.Values.radarr.persistence $volumeName -}}
{{- if and $volume.enabled (not $volume.existingClaim) $volume.nfs.enabled -}}
{{- true -}}
{{- end -}}
{{- end }}