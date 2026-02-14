---
title: Azure API Management Self-Hosted Gateway - Default Token Authentication
description: Enable the Azure API Management self-hosted gateway to authenticate with its associated cloud-based API Management instance using the default token-based authentication method.
services: api-management
author: dlepow

ms.service: azure-api-management
ms.topic: how-to
ms.date: 02/13/2026
ms.author: danlep
---

# Use default token authentication for the self-hosted gateway

[!INCLUDE [api-management-availability-premium-dev](../../includes/api-management-availability-premium-dev.md)]

The Azure API Management [self-hosted gateway](self-hosted-gateway-overview.md) needs connectivity with its associated cloud-based API Management instance for reporting status, checking for and applying configuration updates, and sending metrics and events.

This article shows you how to enable the self-hosted gateway to authenticate using the default token-based authentication method. This approach uses a configuration token and endpoint URL to establish secure communication between the self-hosted gateway and your API Management instance. For other authentication options, see [Self-hosted gateway authentication options](self-hosted-gateway-authentication-options.md).

## Scenario overview

The default authentication method uses a gateway-specific authentication token that identifies the gateway and grants it access to read configuration from the API Management instance. The token is paired with your API Management configuration endpoint URL.

This approach provides:

- **Simple setup** - No complex role assignments or identity federation required
- **Quick deployment** - Straightforward configuration without additional Azure resources
- **Direct control** - Manage gateway access through the API Management instance directly
- **Immediate availability** - No dependency on external identity systems

To enable default token authentication, complete the following steps:

1. Provision a gateway resource in your API Management instance
1. Generate the gateway configuration token
2. Configure the gateway with the token and endpoint
3. Deploy the gateway to an appropriate hosting environment (for example, Kubernetes)

## Prerequisites

- An API Management instance in the Developer or Premium service tier. If needed, complete the following quickstart: [Create an Azure API Management instance](get-started-create-service-instance.md).
- Provision a [gateway resource](api-management-howto-provision-self-hosted-gateway.md) on the instance.
- An Azure Kubernetes Service (AKS) cluster or Kubernetes cluster.
- Self-hosted gateway container image version 2.0 or later

## Generate the gateway token

When you provision a gateway resource in API Management, a default authentication token is generated automatically. To retrieve the token:

1. In the Azure portal, navigate to your API Management instance.
1. Select **Deployment and infrastructure** > **Gateways**.
1. Select your gateway from the list.
1. On the gateway overview page, select the **Deployment** tab.
1. Copy the **Configuration token** value. This token is used to authenticate the self-hosted gateway to the API Management instance.

> [!IMPORTANT]
> Keep the configuration token secure. This token grants access to your gateway configuration. Do not commit it to source control or expose it publicly.

## Deploy the self-hosted gateway

Deploy the self-hosted gateway to Kubernetes using the default token authentication. The following YAML configuration shows the required components and settings.

> [!IMPORTANT]
> Make sure to replace the placeholder values with your actual configuration:
> - `<namespace-name>`: Your Kubernetes namespace
> - `<service-name>`: Your API Management instance name
> - `<gateway-name>`: Your gateway name
> - `<configuration-token>`: Your gateway configuration token

```yml
---
apiVersion: v1
kind: Secret
metadata:
  name: apim-gateway-token
  namespace: <namespace-name>
type: Opaque
stringData:
  config.service.auth.key: "<configuration-token>"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: apim-gateway-env
  namespace: <namespace-name>
data:
  gateway.name: <gateway-name>
  config.service.auth: key
  config.service.endpoint: https://<service-name>.configuration.azure-api.net
  telemetry.logs.std.level: info
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apim-gateway
  namespace: <namespace-name>
spec:
  replicas: 1
  selector:
    matchLabels:
      app: apim-gateway
  template:
    metadata:
      labels:
        app: apim-gateway
    spec:
      containers:
      - name: apim-gateway
        image: mcr.microsoft.com/azure-api-management/gateway:v2
        ports:
        - name: http
          containerPort: 8080
          protocol: TCP
        - name: https
          containerPort: 8081
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /internal-status-0123456789abcdef
            port: http
            scheme: HTTP
          periodSeconds: 5
          successThreshold: 1
          timeoutSeconds: 1
        resources:
          limits:
            cpu: "2"
            memory: 2Gi
          requests:
            cpu: "2"
            memory: 2Gi
        envFrom:
        - configMapRef:
            name: apim-gateway-env
        - secretRef:
            name: apim-gateway-token
---
apiVersion: v1
kind: Service
metadata:
  name: apim-gateway-loadbalancer
  namespace: <namespace-name>
spec:
  type: LoadBalancer
  selector:
    app: apim-gateway
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 8080
  - name: https
    port: 443
    protocol: TCP
    targetPort: 8081
```

### Configuration breakdown

The YAML file contains four key components:

#### Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: apim-gateway-token
type: Opaque
stringData:
  config.service.auth.key: "<configuration-token>"
```

The Secret resource securely stores the gateway configuration token:
- **config.service.auth.key** - Contains the authentication token generated from your API Management gateway resource

#### ConfigMap

```yaml
data:
  config.service.auth: key
  config.service.endpoint: https://<service-name>.configuration.azure-api.net
  gateway.name: <gateway-name>
```

The ConfigMap defines the gateway's authentication and connection settings:
- **config.service.auth: key** - Specifies token-based authentication as the method
- **config.service.endpoint** - The API Management configuration endpoint URL
- **gateway.name** - The name of the gateway resource in your API Management instance

#### Deployment

The Deployment resource configures the gateway container with:
- Environment variables from both the ConfigMap and Secret
- Resource limits and requests for CPU and memory
- Health checks via readiness probes

#### Service

The Service resource creates a LoadBalancer to expose the gateway's HTTP and HTTPS ports externally, allowing traffic to reach the self-hosted gateway.

### Deploy to Kubernetes

Save the YAML configuration to a file (for example, `apim-gateway-token.yaml`) and deploy it to your Kubernetes cluster:

```bash
kubectl apply -f apim-gateway-token.yaml
```

Verify the deployment:

```bash
kubectl get pods -n <namespace-name>
kubectl logs -n <namespace-name> <pod-name>
```

## Token rotation and management

The configuration token has a defined lifetime. When a token expires, the gateway will lose connectivity to the API Management instance.

To rotate the token:

1. In the Azure portal, navigate to your API Management instance.
1. Select **Deployment and infrastructure** > **Gateways**.
1. Select your gateway.
1. On the **Deployment** tab, select **Regenerate token**.
1. Copy the new token.
1. Update the Kubernetes Secret with the new token:

```bash
kubectl patch secret apim-gateway-token -n <namespace-name> -p '{"data":{"config.service.auth.key":"'$(echo -n "<new-token>" | base64)'"}}' --type=merge
```

[!INCLUDE [api-management-self-hosted-gateway-kubernetes-services](../../includes/api-management-self-hosted-gateway-kubernetes-services.md)]

## Related content

- Learn more about the API Management [self-hosted gateway](self-hosted-gateway-overview.md).
- Learn more about guidance for [running the self-hosted gateway on Kubernetes in production](how-to-self-hosted-gateway-on-kubernetes-in-production.md).
- Compare with [Microsoft Entra workload identity authentication](self-hosted-gateway-enable-workload-identity.md).
- Compare with [Microsoft Entra authentication using client secrets](self-hosted-gateway-enable-azure-ad.md).