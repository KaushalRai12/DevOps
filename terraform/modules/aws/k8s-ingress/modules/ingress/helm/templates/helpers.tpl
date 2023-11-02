{{/* Generate the port list */}}
{{- define "listenPorts" -}}
{{- range $port := .Values.listenPorts }}{{(print "{\"" $port.protocol "\": " $port.port "}")}},{{- end }}
{{- end }}

{{/* Generate the attributes */}}
{{- define "loadBalancerAttributes" -}}
{{- range $attr := .Values.attributes }}{{(print $attr.name "=" $attr.value)}},{{- end }}
{{- end }}

{{/* Secret name */}}
{{- define "secretName" -}}
{{ printf "%s-oidc" .Values.name }}
{{- end }}
