{{- define "comment-service.name" -}}
comment-service
{{- end -}}

{{- define "comment-service.fullname" -}}
{{ .Release.Name }}-comment-service
{{- end -}}
