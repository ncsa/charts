{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "betydb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "betydb.fullname" -}}
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
{{- define "betydb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "betydb.labels" -}}
app.kubernetes.io/name: {{ include "betydb.name" . }}
helm.sh/chart: {{ include "betydb.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Postgres Host
*/}}
{{- define "betydb.postgisHost" -}}
{{ .Release.Name }}-{{ .Values.postgis.postgresHost | default "postgis" }}
{{- end -}}

{{/*
Create the flags needed when initializing the BETY database
*/}}
{{- define "betydb.initializeFlags" -}}
$flags = ""
{{- if .Values.addGuestUser -}}
  {{- if .Values.addSampleUsers -}}
-g -u
  {{- else -}}
-g
  {{- end -}}
{{- else -}} 
  {{- if .Values.addSampleUsers -}}
-u
  {{- end -}}
{{- end -}}
{{- end -}}
