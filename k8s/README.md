# Kubernetes manifests

Put your manifests for the **ledger-api** here (raw YAML, Kustomize, or a Helm
chart — your call; mention the choice in DECISIONS.md).

At minimum we expect the app to come up healthy and be reachable inside the
cluster. Beyond that, show us what "production-minded" means to you.

Things we look for (not all required — pick what matters and justify the rest):
- Deployment with readiness AND liveness probes wired to the right endpoints
- CPU/memory requests and limits
- Config via ConfigMap and secrets handled sanely (not committed in plaintext)
- A Service, and a way to reach the app (port-forward is fine for a local demo)
- More than one replica + a sensible rollout strategy / PodDisruptionBudget
- A NetworkPolicy, HPA, or similar if you think it's warranted

You can run Postgres and Redis in-cluster (a simple Deployment, a StatefulSet,
or a community Helm chart). Persistence is NOT required for this exercise — be
explicit about that tradeoff.
