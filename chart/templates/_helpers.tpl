{{/* Expand the name of the chart. */}}
{{- define "protonmail-bridge.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Create a default fully qualified app name. */}}
{{- define "protonmail-bridge.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := .Chart.Name }}
{{- if contains "." .Chart.Name }}
{{- $name = replace "." "-" .Chart.Name }}
{{- end }}
{{- $suffix := (print "-" .Chart.Name) }}
{{- $baseName := trimSuffix $suffix $name }}
{{- printf "%s%s" $baseName $suffix | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/* Create chart name and version as suffix for chart annotations. */}}
{{- define "protonmail-bridge.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Selector labels are used as event selectors. */}}
{{- define "protonmail-bridge.selectorLabels" -}}
app.kubernetes.io/name: {{ include "protonmail-bridge.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Pod labels are added to all Pod objects. */}}
{{- define "protonmail-bridge.podLabels" -}}
{{- include "protonmail-bridge.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
helm.sh/chart: {{ include "protonmail-bridge.chart" . }}
{{- end }}
