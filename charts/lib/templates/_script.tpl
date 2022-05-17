{{/*
Generate bash deploy script
{{ include "lib.script.laravel" (dict "args" .Values.preInstallJob "name" "run-pre-install.sh" "envName" .Values.global.env) | indent 4 }}
*/}}
{{- define "lib.script.laravel" }}
#!/bin/bash

echo "[RUN] {{ .name }} script..."

{{ if eq .name "run-pre-install.sh" }}
if [[ -f /usr/local/bin/pre-run-base ]]; then
  echo "[RUN] /usr/local/bin/pre-run-base script..."
  /usr/local/bin/pre-run-base
fi
{{ end }}

echo "[RUN] first script..."
{{- $listFirst := pluck .envName .args.first | first | default .args.first._default }}
{{- range $i, $val := $listFirst }}
{{ $val}}
{{- end }}

{{- if not .args.disableDefault }}
echo "[RUN] default script..."
# npm install
# npm run production
php artisan view:clear
php artisan cache:clear
php artisan config:clear
php artisan optimize

# php artisan migrate --force
# php artisan migrate:fresh --force --seed
# php artisan migrate --no-interaction
# php artisan migrate
# php artisan key:generate
{{- end }}

#sudo chown -R $USER:www-data storage
#sudo chown -R $USER:www-data bootstrap/cache
#chmod -R 775 storage
#chmod -R 775 bootstrap/cache

echo "[RUN] second script..."
{{- $listSecond := pluck .envName .args.second | first | default .args.second._default }}
{{- range $i, $val := $listSecond }}
{{ $val}}
{{- end }}
{{- end }}