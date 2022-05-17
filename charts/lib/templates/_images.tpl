{{/* vim: set filetype=mustache: */}}
{{/*
OLD
# image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
Return the proper image name
{{ include "lib.images" ( dict "imageRoot" .Values.path.to.the.image "appName" $fullName "envName" .Values.global.env "global" $) }}
*/}}
{{- define "lib.images" }}
{{- $registryName := pluck .envName .imageRoot.registry | first | default .imageRoot.registry._default }}
{{- $repositoryName := .imageRoot.repository | default .appName }}
{{- $tag := pluck .envName .imageRoot.tag | first | default .imageRoot.tag._default }}
{{- $pullPolicy := pluck .envName .imageRoot.pullPolicy | first | default .imageRoot.pullPolicy._default }}
{{- if .global }}
    {{- if .global.imageRegistry }}
     {{- $registryName = .global.imageRegistry }}
    {{- end }}
		{{- if eq $tag "none" }}
			{{- if eq .envName "local" }}
				{{- $tag = .envName }}
			{{- else }}
				{{- $tag = .global.Chart.AppVersion }}
			{{- end }}
		{{- end }}
{{- end }}
{{- if eq $registryName "none" }}
image: {{ printf "%s:%s" $repositoryName $tag | quote }}
{{- else if eq $registryName "builder" }}
{{- $imageName := .imageRoot.build.name | default "none" }}
{{- $prefix := .imageRoot.build.prefix | default "none" }}
{{- $sufix := .imageRoot.build.sufix | default "none" }}
{{- if eq $imageName "none" }}
	{{- $imageName = .appName }}
	{{- if ne $prefix "none" }}
		{{- if eq $prefix "environment" }}
			{{- $prefix = .envName }}
		{{- end }}
		{{- $imageName = printf "%s-%s" $prefix $imageName }}
	{{- end }}
	{{- if ne $sufix "none" }}
		{{- if eq $sufix "environment" }}
			{{- $sufix = .envName }}
		{{- end }}
		{{- $imageName = printf "%s-%s" $imageName $sufix }}
	{{- end }}
{{- end }}
image: {{ printf "%s:%s" $imageName $tag | quote }}
{{- else }}
image: {{ printf "%s/%s:%s" $registryName $repositoryName $tag | quote }}
{{- end }}
imagePullPolicy: {{ $pullPolicy | quote }}
{{- end }}
