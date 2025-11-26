{{- define "frontend-service.name" -}}
frontend-service
{{- end -}}

{{- define "frontend-service.fullname" -}}
{{ .Release.Name }}-frontend-service
{{- end -}}
