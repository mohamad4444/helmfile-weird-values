{{- define "keycloak.name" -}}
{{ .Chart.Name }}
{{- end -}}

{{- define "keycloak.fullname" -}}
{{ .Release.Name }}-{{ include "keycloak.name" . }}
{{- end -}}

{{- define "keycloak.labels" -}}
app.kubernetes.io/name: {{ include "keycloak.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: Helm
{{- end -}}
