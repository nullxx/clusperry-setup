# Requirements ⚠️

* Setup a persistent volume (gluster-setup folder)
* Please create your own image and replace it in `build-push.sh` file

# Publishing to private registry example
```bash
bash build-push.sh v0.1.1
```
# Setup
* Edit manifest `hostPath.path` with your own volume path.
* Edit manifest.yaml container image with yours.
* Remember you need to setup your own registry secret (mine one is called `gitlab-registry-secret`)
* `cp .env.example .env` and place your values.

# Apply to k8s

```bash
kubectl apply -f manifest.yaml
```
