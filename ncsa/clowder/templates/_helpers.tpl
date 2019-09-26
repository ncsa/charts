{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "clowder.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "clowder.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "clowder.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "clowder.labels" -}}
app.kubernetes.io/name: {{ include "clowder.name" . }}
helm.sh/chart: {{ include "clowder.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Clowder URI
*/}}
{{- define "clowder.clowderuri" -}}
http://{{ include "clowder.fullname" . }}:9000/{{ .Values.clowder.ingress.path }}
{{- end -}}

{{/*
Mongo URI
*/}}
{{- define "clowder.mongodburi" -}}
mongodb://{{ include "clowder.fullname" . }}-mongodb:27017/clowder
{{- end -}}

{{/*
RabbitMQ URI
*/}}
{{- define "clowder.rabbitmquri" -}}
amqp://guest:guest@{{ include "clowder.fullname" . }}-rabbitmq/%2F
{{- end -}}
