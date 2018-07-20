kubectl create namespace tst 
kubectl apply -f .
kubectl annotate   deployment/nginx kubernetes.io/change-cause='initial deployment' -n tst 
kubectl rollout history deployments nginx -n tst
