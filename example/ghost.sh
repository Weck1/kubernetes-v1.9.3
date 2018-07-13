kubectl create namespace dev
kubectl run ghost --image=ghost --port=2368 -n dev
kubectl scale deployment ghost --replicas=4 -n dev
kubectl expose deployment ghost -n dev
kubectl apply -f ./ghost-ingress-dev.yaml 
