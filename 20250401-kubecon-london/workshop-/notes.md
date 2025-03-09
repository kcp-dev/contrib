# Issues with Podman-backed kind:

Shows up at least on Fedora:

```
$ kind create cluster ...
enabling experimental podman provider
ERROR: failed to create cluster: running kind with rootless provider requires setting systemd property "Delegate=yes", see https://kind.sigs.k8s.io/docs/user/rootless/
```
