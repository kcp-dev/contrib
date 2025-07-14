# Configuring KCP for OIDC

KCP fully supports OIDC authentication and authorization as supported by
kubernetes' apiserver. The full documentation is available [here](https://docs.kcp.io/kcp/main/concepts/authentication/oidc/).

This example uses [dex](https://dexidp.io/) as an OIDC provider and
demonstrates how to configure KCP to authenticate against it.

## Prerequisites

- docker
- jq

Clone the [contrib](https://github.com/kcp-dev/contrib) repository and
enter the `examples/oidc` directory.

## Create network

Create a separate docker network for the kcp components to run in:

```bash
docker network create kcp
```

## Setup dex idp

Generate certificates for dex - while dex can be used without TLS, kube
authentication requires the use of TLS certificates:

```bash
openssl req -x509 -newkey rsa:4096 \
    -keyout dex/server.key \
    -out dex/server.crt \
    -passout pass: \
    -sha256 \
    -days 3650 \
    -nodes \
    -subj "/C=XX/ST=XX/L=XX/O=XX/OU=XX/CN=dex" \
    -addext "subjectAltName = DNS:dex"
```

Run dex in docker:

```bash
docker run --network kcp --detach --rm --name dex \
    -v ./dex:/dex:ro \
    ghcr.io/dexidp/dex:latest \
    dex serve /dex/dex-config.yaml
```

The configuration configures one static user `admin@example.com` with
the password `admin` and a client `kcp`.

Validate functionality with oidc-login:

<!--
short sleep for the ci to wait for dex to be ready
```bash
while ! docker run --network=kcp --rm alpine/curl:latest --insecure --fail https://dex:5557/healthz; do
    sleep 1
done
```
-->

```bash
docker run --network=kcp --rm -v ./dex/server.crt:/dex.crt  \
    ghcr.io/int128/kubelogin:master \
    setup \
    --oidc-issuer-url=https://dex:5557/ \
    --oidc-client-id=kcp \
    --certificate-authority=/dex.crt \
    --grant-type=password \
    --username=admin@example.com \
    --password=admin
```

## Setup kcp

### Authentication configuration

Create a simple authentication config:

```bash
cat <<EOF > authentication-config.yaml
apiVersion: apiserver.config.k8s.io/v1beta1
kind: AuthenticationConfiguration
jwt:
- issuer:
    url: https://dex:5557/
    certificateAuthority: |-
$(awk '{ print "      " $0 }' dex/server.crt)
    audiences:
      - kcp
  claimValidationRules:
  # This validation is required to use claims.email in claimMappings.
  - expression: 'claims.email_verified == true'
    message: email_verified must be set to true
  claimMappings:
    username:
      expression: "claims.email + ':external-user'"
    groups:
      claim: roles
      prefix: "oidc:"
EOF
```

The `claimMappings` instructs the apiserver to recognize the user
`admin@example.com` as `admin@example.com:external-user` and to assign
groups based on the `roles` claim, prefixed with `oidc:`.

A sensible mapping is to have an id for each authentication provider and
to set the prefix to this id to prevent RBAC oversights.

```yaml
apiVersion: apiserver.config.k8s.io/v1beta1
kind: AuthenticationConfiguration
jwt:
- issuer:
    url: https://auth.example.corp/
    # ...
  claimMappings:
    username:
      claim: sub
      prefix: "auth-example-corp:"
    groups:
      claim: roles
      prefix: "auth-example-corp:"
- issuer:
    url: https://auth.supplier.org/
    # ...
  claimMappings:
    username:
      claim: sub
      prefix: "auth-supplier-org:"
    groups:
      claim: roles
      prefix: "auth-supplier-org:"
```

### Run KCP

Now launch KCP with the authentication config:

<!--
# ensure gha runs the latest image
```bash
docker pull ghcr.io/kcp-dev/kcp:main
```
-->

```bash
docker run --network kcp --rm --detach --name kcp \
    -p 6443:6443 \
    -v ./authentication-config.yaml:/authentication-config.yaml:ro \
    ghcr.io/kcp-dev/kcp:main \
    start \
    --bind-address=0.0.0.0 \
    --external-hostname=localhost \
    --authentication-config=/authentication-config.yaml
```

KCP can take around 30s to start up, so we wait until we can copy the
admin kubeconfig from the container and then wait for the default
namespace to become active:

<!--
wait for the ci
```bash
while sleep 1; do
    # loops until the kubeconfig is created
    while ! docker exec kcp test -f /.kcp/admin.kubeconfig; do sleep 1; done
    docker cp kcp:/.kcp/admin.kubeconfig admin.kubeconfig
    # loops until the wait doesn't immediately fail due to missing rbac or namespace
    kubectl --kubeconfig=admin.kubeconfig wait --for=jsonpath='{.status.phase}'=Active ns default || continue
    # once the kubectl-wait succeeds we are done
    break
done
```
-->


```bash
while ! docker exec kcp test -f /.kcp/admin.kubeconfig; do sleep 1; done
docker cp kcp:/.kcp/admin.kubeconfig admin.kubeconfig
kubectl --kubeconfig=admin.kubeconfig wait --for=jsonpath='{.status.phase}'=Active namespace default
```

Use the admin kubeconfig to create a configmap in the root workspace to
read as an oidc user later:

```bash
kubectl --kubeconfig=admin.kubeconfig create configmap hello-world \
    --from-literal=message="Hello, KCP with OIDC"
```

## Authenticating with OIDC

With a local setup with dex the three-step process of SSO between app,
auth provider and user is not possible, so we will simulate it by
getting a token from dex using kubelogin and then using that token to
authenticate with KCP.

We create a new kubeconfig for oidc `oidc.kubeconfig.yaml`, for that we
will also need the certificate of the KCP apiserver:

```bash
docker cp kcp:/.kcp/apiserver.crt apiserver.crt
kubectl --kubeconfig oidc.kubeconfig.yaml config set-cluster kcp \
    --server https://localhost:6443/clusters/root \
    --certificate-authority=apiserver.crt
```

Get a token from dex using kubelogin and store it in `oidc.token`:

```bash
docker run --rm --network kcp -v ./dex/server.crt:/dex.crt  \
    ghcr.io/int128/kubelogin:master \
    get-token \
    --oidc-issuer-url=https://dex:5557/ \
    --oidc-client-id=kcp \
    --oidc-extra-scope=email \
    --certificate-authority=/dex.crt \
    --grant-type=password \
    --username=admin@example.com \
    --password=admin \
    | jq -r '.status.token' > oidc.token
```

And set the token in the credentials of the kubeconfig - this is
basically what kubectl does behind the scenes:

```bash
kubectl --kubeconfig oidc.kubeconfig.yaml config set-credentials kcp-oidc \
   --auth-provider=oidc \
   --auth-provider-arg=idp-issuer-url=https://dex:5557/ \
   --auth-provider-arg=client-id=kcp \
   --auth-provider-arg=idp-certificate-authority=dex/server.crt \
   --token=$(cat oidc.token)
```

The `idp-issuer-url` is the same as in the `AuthenticationConfiguration`.
The apiserver will use this to validate our token against the oidc
provider and to use the correct claims mapping.

Usually a kubectl config with oidc would look like this:

```yaml
apiVersion: v1
kind: Config
# ...
users:
  - name: admin@example.com
    user:
      exec:
        apiVersion: client.authentication.k8s.io/v1
        interactiveMode: Never
        command: kubectl
        args:
          - oidc-login
          - get-token
          - --oidc-issuer-url=https://dex:5557/
          - --oidc-client-id=kcp
          - --oidc-extra-scope=email
```

What we configured above is what `kubectl oidc-login get-token` would output as JSON.

And now to bind it together:

```bash
kubectl --kubeconfig oidc.kubeconfig.yaml config set-context kcp-oidc \
    --cluster=kcp \
    --user=kcp-oidc

kubectl --kubeconfig oidc.kubeconfig.yaml config use-context kcp-oidc
```

With the oidc kubeconfig built we can now access the KCP cluster as an
oidc user:

```bash noci
kubectl --kubeconfig oidc.kubeconfig.yaml get configmap hello-world
```

And we run into a permission issue - just because a user is
authenticated does not mean they are also authorized.

## RBAC with OIDC

To authorize users we use the same RBAC rules as with any other kube
user or group. In the authentication config we suffixed the user's email
with `:external-user` - so we create a role binding for this user:


```bash
kubectl --kubeconfig admin.kubeconfig apply -f- <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: dex:admin
rules:
- apiGroups: [""]
  resources:
    - configmaps
  verbs:
    - get
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: dex:admin
subjects:
- kind: User
  name: admin@example.com:external-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: dex:admin
  apiGroup: rbac.authorization.k8s.io
EOF
```

If we now try to access the configmap again with the oidc kubeconfig we
are able to read it:

```bash
kubectl --kubeconfig oidc.kubeconfig.yaml get configmap hello-world -o yaml
```

And we still cannot delete existing configmaps:

```bash noci
kubectl --kubeconfig oidc.kubeconfig.yaml delete configmap hello-world
```

... or create new ones:

```bash noci
kubectl --kubeconfig oidc.kubeconfig.yaml create configmap this-errors \
    --from-literal=message="This will not work"
```

# Cleanup

Stop the docker containers, delete the network and delete the files:

```bash
docker stop kcp dex
docker network rm kcp
rm -f authentication-config.yaml
rm -f dex/server.crt dex/server.key
rm -f oidc.kubeconfig.yaml oidc.token apiserver.crt
```
