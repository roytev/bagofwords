{{/*
Expand the name of the chart.
*/}}
{{- define "bagofwords.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
Truncated to 63 characters. If the release name already contains the chart
name, avoid duplication (e.g. "bagofwords-bagofwords" → "bagofwords").
*/}}
{{- define "bagofwords.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart label — "name-version" with dots replaced by dashes.
*/}}
{{- define "bagofwords.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to every resource.
*/}}
{{- define "bagofwords.labels" -}}
helm.sh/chart: {{ include "bagofwords.chart" . }}
{{ include "bagofwords.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels — used in matchLabels and pod template labels.
*/}}
{{- define "bagofwords.selectorLabels" -}}
app.kubernetes.io/name: {{ include "bagofwords.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ServiceAccount name.
*/}}
{{- define "bagofwords.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "bagofwords.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
groundhog2k postgres subchart service hostname.
The chart name is "postgres", so the service is "<release>-postgres"
(or just "<release>" if the release name already contains "postgres").
*/}}
{{- define "bagofwords.postgresqlHost" -}}
{{- $name := "postgres" -}}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Auto-constructed BOW_DATABASE_URL for the bundled postgres subchart.
Only used when postgres.enabled=true and externalDatabase.enabled=false.
Uses userDatabase credentials (not the superuser).
*/}}
{{- define "bagofwords.databaseUrl" -}}
{{- $db := .Values.postgres.userDatabase -}}
{{- printf "postgresql://%s:%s@%s:5432/%s" $db.user.value $db.password.value (include "bagofwords.postgresqlHost" .) $db.name }}
{{- end }}
