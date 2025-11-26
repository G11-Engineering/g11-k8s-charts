{{- define "media-service.name" -}}
media-service
{{- end -}}

{{- define "media-service.fullname" -}}
{{ .Release.Name }}-media-service
{{- end -}}
