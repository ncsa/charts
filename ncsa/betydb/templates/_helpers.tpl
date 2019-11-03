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
{{- if .Values.postgis.enabled -}}
{{ .Release.Name }}-{{ .Values.postgis.postgresHost | default "postgis" }}
{{- else -}}
{{ .Values.postgis.postgresHost }}
{{- end -}}
{{- end -}}

{{/*
Postgres Host
*/}}
{{- define "betydb.postgisPort" -}}
{{- if .Values.postgis.service -}}
{{ .Values.postgis.service.port }}
{{- else -}}
{{ .Values.postgis.postgresPort | default "5432" }}
{{- end -}}
{{- end -}}

{{/*
Environment variables for PostgreSQL
*/}}
{{- define "betydb.postgisEnv" -}}
- name: PGHOST
  value: {{ include "betydb.postgisHost" . | quote }}
- name: PGPORT
  value: {{ include "betydb.postgisPort" . | quote }}
- name: PGUSER
  value: {{ .Values.postgis.postgresUser | default "postgres" | quote }}
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
{{- if .Values.postgis.enabled }}
      name: {{ .Release.Name }}-postgis
{{- else }}
      name: {{ include "betydb.fullname" . }}
{{- end }}
      key: postgres-password
{{- end }}

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
      key: bety-password
- name: BETYDATABASE
  value: {{ .Values.betyDatabase | quote }}
- name: LOCAL_SERVER
  value: {{ .Values.localServer | quote }}
{{- if .Values.initializeURL }}
- name: INITIALIZE_URL
  value: "-w {{ .Values.initializeURL }}"
{{- end }}
{{- end }}