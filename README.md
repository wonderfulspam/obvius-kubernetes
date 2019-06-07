# obvius-kubernetes
### From docker-compose to Kubernetes:  
\- An Obvius case study


##### Some sample commands and their output
`kubectl get pods`:
```NAME                      READY   STATUS    RESTARTS   AGE
   apache-7585c877bf-28md2   1/1     Running   0          19h
   db-7b9cb9d5d-sx8dd        1/1     Running   0          22h
   nfs-busybox-8wdlp         1/1     Running   0          150m
   nfs-busybox-m6lgk         1/1     Running   0          150m
   nfs-server-6wwtc          1/1     Running   0          163m
   solr-6db49d577b-vk58p     1/1     Running   0          34m
   web-7dcd9b675f-sc554      1/1     Running   0          77m
```
`kubectl describe service apache`:
```Name:                     apache
   Namespace:                default
   Labels:                   io.kompose.service=apache
   Annotations:              kompose.cmd: kompose convert
                             kompose.version: 1.16.0 (0c01309)
                             kubectl.kubernetes.io/last-applied-configuration:
                               {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{"kompose.cmd":"kompose convert","kompose.version":"1.16.0 (0c01309)"},"crea...
   Selector:                 io.kompose.service=apache
   Type:                     LoadBalancer
   IP:                       10.3.246.224
   LoadBalancer Ingress:     35.228.58.130
   Port:                     default  80/TCP
   TargetPort:               80/TCP
   NodePort:                 default  31552/TCP
   Endpoints:                10.0.0.15:80
   Port:                     secure  443/TCP
   TargetPort:               443/TCP
   NodePort:                 secure  32063/TCP
   Endpoints:                10.0.0.15:443
   Port:                     solr  8983/TCP
   TargetPort:               8983/TCP
   NodePort:                 solr  31692/TCP
   Endpoints:                10.0.0.15:8983
   Session Affinity:         None
   External Traffic Policy:  Cluster
   Events:
     Type    Reason                Age                From                Message
     ----    ------                ----               ----                -------
     Normal  EnsuringLoadBalancer  56m (x2 over 59m)  service-controller  Ensuring load balancer
     Normal  EnsuredLoadBalancer   55m (x2 over 59m)  service-controller  Ensured load balancer```
