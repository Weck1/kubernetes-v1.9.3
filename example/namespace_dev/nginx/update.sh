kubectl set image deployment/nginx  nginx=nginx:1.15 -n dev
kubectl rollout history deployments nginx -n dev 