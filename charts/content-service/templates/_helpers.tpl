{{- define "content-service.name" -}}
content-service
{{- end -}}

{{- define "content-service.fullname" -}}
{{ .Release.Name }}-content-service
{{- end -}}
