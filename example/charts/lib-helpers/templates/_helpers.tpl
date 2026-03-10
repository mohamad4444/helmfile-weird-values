{{- define "lib-helpers.fullname" -}}
{{- printf "%s-%s" .Release.Name .Values.env | trunc 63 | trimSuffix "-" -}}
{{- end -}}
