{{/*
Common labels
*/}}
{{- define "artemis.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "artemis.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create secret name
*/}}
{{- define "artemis.secretName" -}}
{{- if .Values.artemis.security.existingSecret }}
{{- .Values.artemis.security.existingSecret }}
{{- else }}
{{- printf "%s-secrets" .Release.Name }}
{{- end }}
{{- end -}}

{{/*
Create configmap name
*/}}
{{- define "artemis.configmapName" -}}
{{- if .Values.artemis.security.existingConfigMap }}
{{- .Values.artemis.security.existingConfigMap }}
{{- else }}
{{- printf "%s-config" .Release.Name }}
{{- end }}
{{- end -}}

{{/*
PVC name
*/}}
{{- define "artemis.pvcName" -}}
{{- printf "%s-pvc" .Release.Name }}
{{- end -}}