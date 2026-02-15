{{/*
Make a go template safe version of the deployment name
*/}}
{{- define "application.values.name"}}{{ strings.ReplaceAll "-" " " (ds "Template").name | strings.CamelCase}}
{{- end }}

{{/*
Emit a reference to this application's values
*/}}
{{- define "application.values.root"}}.Values.{{ template "application.values.name" }}
{{- end }}

{{/*
Emit a reference to this application's values as expanded map
*/}}
{{- define "application.values"}}{{ "{{- toYaml " }}{{- template "application.values.root" . }}{{ ".values | nindent 8 }} " }}
{{- end }}

{{/*
Emit the host name as a url
*/}}
{{- define "url"}}{{ "https://"}}{{ (ds "Template").ingress.host }}
{{- end }}
