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
postgresql Host
*/}}
{{- define "betydb.postgresqlHost" -}}
{{- if .Values.postgresql.enabled -}}
{{ .Release.Name }}-postgresql
{{- else -}}
{{ .Values.postgresql.postgresqlHost }}
{{- end -}}
{{- end -}}

{{/*
postgresql Port
*/}}
{{- define "betydb.postgresqlPort" -}}
{{- if .Values.postgresql.service -}}
{{ .Values.postgresql.service.port }}
{{- else -}}
{{ .Values.postgresql.postgresqlPort | default "5432" }}
{{- end -}}
{{- end -}}

{{/*
Environment variables for PostgreSQL
*/}}
{{- define "betydb.postgresqlEnv" -}}
- name: PGHOST
  value: {{ include "betydb.postgresqlHost" . | quote }}
- name: PGPORT
  value: {{ include "betydb.postgresqlPort" . | quote }}
- name: PGUSER
  value: {{ .Values.postgresql.postgresqlUsername | default "postgres" | quote }}
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
{{- if .Values.postgresql.enabled }}
      name: {{ .Release.Name }}-postgresql
      key: postgresql-password
{{- else }}
      name: {{ include "betydb.fullname" . }}
      key: postgresqlPassword
{{- end }}
{{- end }}

{{/*
Environment variables for BetyDB
*/}}
{{- define "betydb.betydbEnv" -}}
- name: BETYUSER
  value: {{ .Values.betyUser | quote }}
- name: BETYPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "betydb.fullname" . }}
      key: betyPassword
- name: BETYDATABASE
  value: {{ .Values.betyDatabase | quote }}
- name: LOCAL_SERVER
  value: {{ .Values.localServer | quote }}
- name: REMOTE_SERVERS
  value: {{ .Values.remoteServers | quote }}
{{- end }}
