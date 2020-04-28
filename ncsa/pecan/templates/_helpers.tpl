{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "pecan.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pecan.fullname" -}}
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
{{- define "pecan.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "pecan.labels" -}}
app.kubernetes.io/name: {{ include "pecan.name" . }}
helm.sh/chart: {{ include "pecan.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Cluster environment
*/}}
{{- define "pecan.env.cluster" -}}
- name: NAME
  value: {{ required "A valid .Values.clustername entry required!" .Values.clustername }}
- name: FQDN
{{- if .Values.clusterfqdn }}
  value: {{ .Values.clusterfqdn | quote }}
{{- else }}
  value: {{ .Values.clustername | quote }}
{{- end }}
{{- end -}}

{{/*
RabbitMQ URI environment
*/}}
{{- define "pecan.env.rabbitmq" -}}
- name: RABBITMQ_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-rabbitmq
      key: rabbitmq-password
- name: RABBITMQ_URI
  value: "amqp://{{ .Values.rabbitmq.rabbitmq.username }}:$(RABBITMQ_PASSWORD)@{{ .Release.Name }}-rabbitmq/%2F"
{{- end -}}

{{/*
Postgresql Environment for postgres
*/}}
{{- define "pecan.env.postgresql" -}}
- name: PGHOST
{{- if .Values.betydb.postgresql.postgresqlHost }}
  value: {{ .Values.betydb.postgresql.postgresqlHost | quote }}
{{- else }}
  value: "{{ .Release.Name }}-postgresql"
{{- end }}
- name: PGPORT
  value: {{ .Values.betydb.postgresql.service.port | default 5432 | quote }}
- name: PGUSER
  value: {{ .Values.betydb.postgresql.postgresqlUser | default "postgres" | quote }}
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-postgresql
      key: postgresql-password
- name: BETYUSER
  value: {{ .Values.betydb.betyUser | default "bety" | quote }}
- name: BETYPASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-betydb
      key: betyPassword
- name: BETYDATABASE
  value: {{ .Values.betydb.betyDatabase | quote }}
{{- end -}}

{{/*
BETYDB Environment for postgresql
*/}}
{{- define "pecan.env.betydb" -}}
- name: BETYDBURL
  value: "http://{{ .Release.Name }}-betydb:{{ .Values.betydb.service.port | default "8000" }}{{ .Values.betydb.ingress.path | default "/" }}"
{{- end -}}

