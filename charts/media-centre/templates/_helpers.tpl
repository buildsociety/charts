{{/*
Expand the name of the chart.
*/}}
{{- define "media-centre.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "media-centre.fullname" -}}
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
{{- define "media-centre.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "media-centre.labels" -}}
helm.sh/chart: {{ include "media-centre.chart" . }}
{{ include "media-centre.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "media-centre.selectorLabels" -}}
app.kubernetes.io/name: {{ include "media-centre.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "media-centre.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "media-centre.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the shared media PVC name
*/}}
{{- define "media-centre.mediaPvcName" -}}
{{- if .Values.global.media.existingClaim }}
{{- .Values.global.media.existingClaim }}
{{- else }}
{{- printf "%s-media" (include "media-centre.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Get the shared downloads PVC name
*/}}
{{- define "media-centre.downloadsPvcName" -}}
{{- if .Values.global.downloads.existingClaim }}
{{- .Values.global.downloads.existingClaim }}
{{- else }}
{{- printf "%s-downloads" (include "media-centre.fullname" .) }}
{{- end }}
{{- end }}