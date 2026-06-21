# Debug task

A teammate applied `debug/broken-deployment.yaml` to the local cluster and
reports:

- `kubectl get pods` shows the pods bouncing — `READY` stays at `0/1` and the
  `RESTARTS` count keeps climbing.
- They tried to reach the service from another pod and got nothing back.
- "It's just nginx, it should be trivial — what's going on?"

## What we want from you

1. Reproduce it on your local `kind` cluster.
2. Diagnose the root cause(s). Tell us the exact commands you used to
   investigate and what each one told you. We care about your method as much as
   the fix.
3. Fix it. Put your corrected manifest at `debug/fixed-deployment.yaml`.
4. Make the app actually reachable: add whatever is needed so you can
   successfully `curl` it (a Service plus a port-forward is fine for a local
   demo), and include the command you used to verify.
5. Write a short root-cause note in `debug/FINDINGS.md` (a few sentences per
   issue: symptom -> cause -> fix). Pretend it's going into an incident review.

Hint: read the events. `kubectl describe pod <name>` is your friend.
