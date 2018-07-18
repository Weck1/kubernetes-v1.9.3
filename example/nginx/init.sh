kubectl apply -f .
kubectl annotate   deployment/nginx kubernetes.io/change-cause='initial deployment' -n dev
