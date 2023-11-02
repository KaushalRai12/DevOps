{{/* Deployment name */}}
{{- define "deployName" -}}
{{ .Chart.Name }}{{ coalesce .Values.suffix "" }}
{{- end }}
