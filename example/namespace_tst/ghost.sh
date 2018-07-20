kubectl create namespace tst
kubectl run ghost --image=ghost --port=2368 -n tst
kubectl scale deployment ghost --replicas=4 -n tst
kubectl expose deployment ghost -n tst --type=LoadBalancer
kubectl apply -f ./ghost-ingress-tst.yaml 
