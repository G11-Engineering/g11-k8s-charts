{{- define "user-service.name" -}}
user-service
{{- end -}}

{{- define "user-service.fullname" -}}
{{ .Release.Name }}-user-service
{{- end -}}
