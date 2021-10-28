### Dashboard

1. Deploy
```
kubectl apply -f kube-dashboard.yaml
# delete:
kubectl delete -f kube-dashboard.yaml
```

2. Open dashboard in your browser
```
kubectl get pod -o wide
```
show where the pod is deployed

```
kubectl -n kube-system describe $(kubectl -n kube-system get secret -n kube-system -o name | grep namespace) | grep token
```
grep the token then use it in your browser: https://node5:31111/

Note: If you are using Chrome, click the warning page, and type in "thisisunsafe", you should be able to open the dashboard.
