{{/*
Expand the name of the chart.
*/}}
{{- define "fah.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "fah.fullname" -}}
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
{{- define "fah.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fah.labels" -}}
helm.sh/chart: {{ include "fah.chart" . }}
{{ include "fah.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fah.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fah.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
CPU DaemonSet labels
*/}}
{{- define "fah.cpu.labels" -}}
{{ include "fah.labels" . }}
app.kubernetes.io/component: cpu
{{- end }}

{{/*
CPU DaemonSet selector labels
*/}}
{{- define "fah.cpu.selectorLabels" -}}
{{ include "fah.selectorLabels" . }}
app.kubernetes.io/component: cpu
{{- end }}

{{/*
GPU DaemonSet labels
*/}}
{{- define "fah.gpu.labels" -}}
{{ include "fah.labels" . }}
app.kubernetes.io/component: gpu
{{- end }}

{{/*
GPU DaemonSet selector labels
*/}}
{{- define "fah.gpu.selectorLabels" -}}
{{ include "fah.selectorLabels" . }}
app.kubernetes.io/component: gpu
{{- end }}

{{/*
Get the secret name
*/}}
{{- define "fah.secretName" -}}
{{- if .Values.secret.existingSecret }}
{{- .Values.secret.existingSecret }}
{{- else }}
{{- .Values.secret.name | default (printf "%s-secrets" (include "fah.fullname" .)) }}
{{- end }}
{{- end }}

{{/*
Get the PriorityClass name
*/}}
{{- define "fah.priorityClassName" -}}
{{- .Values.priorityClass.name | default (include "fah.fullname" .) }}
{{- end }}
