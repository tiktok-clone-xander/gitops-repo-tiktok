{{/*
Common labels
*/}}
{{- define "tiktok-clone.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: tiktok-clone
environment: {{ .Values.global.environment }}
{{- end }}

{{/*
Service labels
*/}}
{{- define "tiktok-clone.serviceLabels" -}}
{{ include "tiktok-clone.labels" . }}
app.kubernetes.io/component: {{ .serviceName }}
{{- end }}

{{/*
Image pull policy
*/}}
{{- define "tiktok-clone.imagePullPolicy" -}}
{{ .Values.global.imagePullPolicy | default "IfNotPresent" }}
{{- end }}

{{/*
Namespace helper
*/}}
{{- define "tiktok-clone.namespace" -}}
{{ .Values.namespace | default .Release.Namespace }}
{{- end }}
