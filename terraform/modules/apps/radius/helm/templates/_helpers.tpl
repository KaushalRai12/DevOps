{{- define "subnets" -}}
{{- join ", " .Values.subnets }}
{{- end -}}
