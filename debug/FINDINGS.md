# Update default nginx port to 80 for calling to internal nginx port 

```log
│   Normal   Scheduled  65s                 default-scheduler  Successfully assigned default/broken-web-66967c45c5-wj72g to tl-worker-4-dev                                                                                                                          │
│   Normal   Pulled     45s (x2 over 62s)   kubelet            Container image "nginx:1.27-alpine" already present on machine                                                                                                                                        │
│   Normal   Created    45s (x2 over 62s)   kubelet            Created container web                                                                                                                                                                                 │
│   Normal   Killing    45s                 kubelet            Container web failed liveness probe, will be restarted                                                                                                                                                │
│   Normal   Started    42s (x2 over 60s)   kubelet            Started container web                                                                                                                                                                                 │
│   Warning  Unhealthy  30s (x13 over 59s)  kubelet            Readiness probe failed: Get "http://10.244.2.204:8080/": dial tcp 10.244.2.204:8080: connect: connection refused                                                                                      │
│   Warning  Unhealthy  30s (x5 over 55s)   kubelet            Liveness probe failed: Get "http://10.244.2.204:8080/": dial tcp 10.244.2.204:8080: connect: connection refused    

```

ref: https://hub.docker.com/_/nginx