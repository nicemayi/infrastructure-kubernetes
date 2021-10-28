# k8s

get token kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | awk '/^deployment-controller-token-/{print $1}') | awk '$1=="token:"{print $2}'

pkill -f 'kubectl proxy --port=8081'

### Create https ssl
```
openssl version -a

openssl genrsa -des3 -out server.key 2048
openssl rsa -in server.key -out server.key

openssl req -new -key server.key -out server.csr

# sign cert 10 years
openssl req -new -x509 -key server.key -out ca.crt -days 3650

# generate cert
openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey server.key -CAcreateserial -out server.crt
``` 

```
# inside pxc
kubectl apply -f crd.yaml
kubectl create namespace pxc
kubectl config set-context $(kubectl config current-context) --namespace=pxc

kubectl apply -f rbac.yaml
kubectl apply -f operator.yaml
kubectl create -f secrets.yaml
kubectl apply -f cr.yaml

kubectl run -i --rm --tty percona-client --image=percona:8.0 --restart=Never -- bash -il

mysql -h cluster1-haproxy -uroot -proot_password

kubectl delete all --all -n pxc
```
