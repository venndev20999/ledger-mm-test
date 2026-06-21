# DevOps Take-Home

Thanks for taking the time. This exercise mirrors the kind of work the role
involves: packaging a service, running it on Kubernetes, describing its
infrastructure as code, wiring up CI, and debugging when things go sideways.

**Everything runs on your laptop. You do not need a cloud account, a credit
card, or any external credentials.** The only things touching a network are
pulling public base images and (optionally) GitHub Actions, which runs on
GitHub-hosted runners for free.

---

## Time expectations

Aim for **3–4 focused hours.** It is deliberately a little broader than that so
you can show strengths — we do **not** expect every section to be polished.
We would much rather see three things done well, with honest notes on the rest,
than everything done shallowly. Tell us where you stopped and what you'd do with
more time.

Please don't burn a weekend on this. If you're hitting the time budget, stop and
write up what's left in `DECISIONS.md`.

---

## What you're given

```
app/                  Reference Flask service (do not need to modify) + tests
app/Dockerfile        A deliberately naive starter Dockerfile to improve
docker-compose.yml    A skeleton to complete
k8s/                  Where your manifests/chart go (see k8s/README.md)
terraform/            Where your Terraform goes (see terraform/README.md)
.github/workflows/    A CI skeleton to fill in
debug/                A broken deployment to diagnose and fix
Makefile              Convenience targets (optional to use/extend)
```

The app exposes `GET /` (does a Redis increment + a Postgres `SELECT now()`),
`GET /healthz` (liveness), and `GET /readyz` (readiness — 200 only when both
Postgres and Redis are reachable). It is configured entirely through environment
variables: `PORT`, `APP_NAME`, `DATABASE_URL`, `REDIS_URL`.

## Prerequisites

You'll want these installed locally (all free, no account required):
`docker`, `kind`, `kubectl`, `terraform`, `make`, and `python3` (only if you
want to run the unit tests outside a container). If you prefer `minikube` or
`k3d` over `kind`, that's fine — just say so.

---

## The tasks

### 1. Package the app (Docker)
Turn `app/Dockerfile` into something you'd be comfortable shipping. We're
looking for image hygiene and an understanding of *why* each change matters
(not a checklist). Run the app with a real WSGI server rather than the Flask
dev server.

### 2. Local dev stack (docker-compose)
Complete `docker-compose.yml` so `docker compose up` brings up the app together
with Postgres and Redis, the app starts only once its dependencies are healthy,
and `curl localhost:8000/` returns a 200 with a real `db_time`.

### 3. Run it on Kubernetes (kind)
Deploy the app to a local `kind` cluster with production-minded manifests (see
`k8s/README.md`). Get it healthy and reachable. Run Postgres and Redis
in-cluster; persistence is not required (call out the tradeoff).

### 4. Infrastructure as code (Terraform)
Describe the deployment with Terraform using the `kubernetes` and/or `helm`
providers against your local cluster (see `terraform/README.md`). No cloud
providers. `terraform fmt` clean, `terraform validate` passing.

### 5. CI pipeline
Fill in `.github/workflows/ci.yml` so the pipeline lints, tests, builds, scans
the image, and validates your manifests and Terraform — all without cloud
credentials. A pipeline that goes green while checking nothing is worse than no
pipeline.

### 6. Debug a broken deployment
Work through `debug/SYMPTOMS.md`. Diagnose, fix, make it reachable, and write a
short incident-style root-cause note. We care about your method as much as the
fix.

### 7. Write-up (`DECISIONS.md`)
A page or so: key decisions and tradeoffs, what you deliberately left out and
why, what you'd change for a real production environment (think secrets,
persistence, observability, scaling, security), and roughly how long you spent.

---

## Submitting

Send us a **git repository** (a link to a private repo, or a zip including the
`.git` directory) with your commit history intact — we like seeing how you work,
not just the final state. Make sure your root `README` (or `DECISIONS.md`)
contains the **exact commands** to:

1. run the app locally with docker-compose,
2. stand up the kind cluster and deploy (manifests and/or Terraform),
3. reach the running app and see a successful response,
4. tear everything down.

We should be able to follow them on a clean machine. If something is
half-finished, that's fine — just be clear about it.

## Ground rules

- Use whatever tools and references you normally would, including AI assistants.
  If you do, we may ask you to walk us through any part of your submission and
  explain the reasoning — so make sure you understand what you submit.
- Don't add secrets you'd be unhappy to see in a real repo.
- Questions are welcome — reach out rather than guessing at something blocking.

Have fun with it.
