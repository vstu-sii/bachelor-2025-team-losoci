set -euo pipefail

echo "Перезапускаем Deployment vue в namespace prod..."
kubectl -n prod rollout restart deployment/vue

echo "Готово! Новая версия сайта будет доступна через 5–10 секунд"
echo "→ http://192.168.58.5"