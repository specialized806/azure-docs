---
title: Azure API Management Self-Hosted Gateway - Workload Identity Authentication
description: Enable the Azure API Management self-hosted gateway to authenticate with its associated cloud-based API Management instance using Microsoft Entra workload identity authentication. 
services: api-management
author: dlepow

ms.service: azure-api-management
ms.topic: how-to
ms.date: 02/12/2026
ms.author: danlep
---

# Use workload identity authentication for the self-hosted gateway

[!INCLUDE [api-management-availability-premium-dev](../../includes/api-management-availability-premium-dev.md)]

The Azure API Management [self-hosted gateway](self-hosted-gateway-overview.md) needs connectivity with its associated cloud-based API Management instance for reporting status, checking for and applying configuration updates, and sending metrics and events. 

In addition to using a gateway access token (authentication key) or Microsoft Entra app with client secrets, you can enable the self-hosted gateway to authenticate to its associated cloud instance by using [Microsoft Entra workload identity](../aks/workload-identity-overview.md). With workload identity authentication, you can eliminate the need to manage secrets or certificates, since authentication is handled through federated identity credentials between your Kubernetes cluster and Microsoft Entra ID.

## Scenario overview

The self-hosted gateway configuration API can check Azure role-based access control (RBAC) to determine who has permissions to read the gateway configuration. With workload identity, you create a Microsoft Entra app that is associated with a Kubernetes service account through federated identity credentials. The self-hosted gateway can then authenticate to the API Management instance using this workload identity without requiring secrets.

Workload identity uses [OpenID Connect (OIDC)](https://openid.net/connect/) to enable Kubernetes applications to access Azure resources securely. This approach provides:

- **No secrets to manage** - Authentication tokens are provided automatically by the Kubernetes cluster
- **Automatic token rotation** - Tokens are short-lived and rotated automatically
- **Enhanced security** - Eliminates the risk of secret leakage or expiration
- **AKS native integration** - Built-in support for Azure Kubernetes Service workload identity

To enable workload identity authentication, complete the following steps:

1. Create two custom roles to:
    - Let the configuration API get access to customer's RBAC information
    - Grant permissions to read the self-hosted gateway configuration
1. Grant RBAC access to the API Management instance's managed identity 
1. Create a Microsoft Entra app and configure federated identity credentials
1. Grant the Microsoft Entra app access to read the gateway configuration
1. Deploy the gateway with workload identity configuration

## Prerequisites

- An API Management instance in the Developer or Premium service tier. If needed, complete the following quickstart: [Create an Azure API Management instance](get-started-create-service-instance.md).
- An Azure Kubernetes Service (AKS) cluster with [workload identity and OIDC issuer enabled](../aks/workload-identity-deploy-cluster.md).
- Provision a [gateway resource](api-management-howto-provision-self-hosted-gateway.md) on the instance.
- Enable a [system-assigned managed identity](api-management-howto-use-managed-service-identity.md) on the instance.
- Self-hosted gateway container image version 2.11.0 or later 

### Limitations and notes

- Only system-assigned managed identity is supported.
- This article focuses on deployment to Azure Kubernetes Service (AKS).

[!INCLUDE [api-management-gateway-role-assignments](../../includes/api-management-gateway-role-assignments.md)]

### Assign API Management Gateway Configuration Reader Role

<a name='step-1-register-azure-ad-app-and-configure-workload-identity'></a>

#### Step 1: Register Microsoft Entra app and configure workload identity

Create a new Microsoft Entra app. For steps, see [Create a Microsoft Entra application and service principal that can access resources](../active-directory/develop/howto-create-service-principal-portal.md). The Microsoft Entra app is used by the self-hosted gateway to authenticate to the API Management instance.

> [!IMPORTANT]
> The workload identity does **not** require you to create a client secret. Authentication is handled through federated identity credentials.

Take note of the following application values for use in the next steps:
- Application (client) ID
- Directory (tenant) ID

Next, configure federated identity credentials to establish trust between your Microsoft Entra app and the Kubernetes service account:

1. In the Azure portal, navigate to your Microsoft Entra app registration.
1. Select **Certificates & secrets** > **Federated credentials** > **+ Add credential**.
1. Select the **Kubernetes accessing Azure resources** scenario.
1. Configure the federated credential:
   - **Cluster issuer URL**: The OIDC issuer URL from your AKS cluster (obtain using `az aks show --resource-group <resource-group> --name <cluster-name> --query "oidcIssuerProfile.issuerUrl"`)
   - **Namespace**: The Kubernetes namespace where you'll deploy the gateway (for example, `apim-gateway-wi`)
   - **Service account**: The name of the Kubernetes service account (for example, `apim-gateway-workload-identity`)
   - **Name**: A descriptive name for the credential (for example, `apim-gateway-federated-credential`)
1. Select **Add** to create the federated credential.

For more information, see [Configure a federated identity credential on an app](/entra/workload-id/workload-identity-federation-create-trust).

#### Step 2: Assign API Management Gateway Configuration Reader Service Role

[Assign](../active-directory/develop/howto-create-service-principal-portal.md#assign-a-role-to-the-application) the API Management Gateway Configuration Reader Service Role to the app.

- Scope: The API Management instance (or resource group or subscription in which the app is deployed)
- Role: API Management Gateway Configuration Reader Role
- Assign access to: Microsoft Entra app

## Deploy the self-hosted gateway

Deploy the self-hosted gateway to Kubernetes using workload identity. The following YAML configuration shows the required components and settings.

> [!IMPORTANT]
> Make sure to replace the placeholder values with your actual configuration:
> - `<namespace-name>`: Your Kubernetes namespace
> - `<client-id>`: Your Microsoft Entra application (client) ID
> - `<gateway-name>`: Your API Management gateway name
> - `<service-name>.configuration.azure-api.net`: Your API Management configuration endpoint
  
```yml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: apim-gateway-workload-identity
  namespace: <namespace-name>
  labels:
    azure.workload.identity/use: "true"
  annotations:
    azure.workload.identity/client-id: "<client-id>"
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
        azure.workload.identity/use: "true"
    spec:
      serviceAccountName: apim-gateway-workload-identity
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
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: apim-gateway-env
  namespace: <namespace-name>
data:
  gateway.name: <gateway-name>
  config.service.auth: workloadIdentity
  config.service.endpoint: https://<service-name>.configuration.azure-api.net
  telemetry.logs.std.level: info
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

#### ServiceAccount

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: "<client-id>"
  labels:
    azure.workload.identity/use: "true"
```

The service account is configured for workload identity with:
- **Label** `azure.workload.identity/use: "true"` - Indicates this service account uses workload identity
- **Annotation** `azure.workload.identity/client-id` - Specifies the Microsoft Entra application (client) ID that the service account maps to

#### Deployment

```yaml
spec:
  template:
    metadata:
      labels:
        azure.workload.identity/use: "true"
    spec:
      serviceAccountName: apim-gateway-workload-identity
```

The deployment configuration includes:
- **Pod label** `azure.workload.identity/use: "true"` - Enables workload identity for pods in this deployment
- **serviceAccountName** - References the workload identity-enabled service account created above

#### ConfigMap

```yaml
data:
  config.service.auth: workloadIdentity
  config.service.endpoint: https://<service-name>.configuration.azure-api.net
  gateway.name: <gateway-name>
```

The ConfigMap defines the gateway's authentication and connection settings:
- **config.service.auth: workloadIdentity** - Specifies workload identity as the authentication method (no secrets required)
- **config.service.endpoint** - The API Management configuration endpoint
- **gateway.name** - The name of the gateway resource in your API Management instance

#### Service

The Service resource creates a LoadBalancer to expose the gateway's HTTP and HTTPS ports externally, allowing traffic to reach the self-hosted gateway.

### Deploy to Kubernetes

Save the YAML configuration to a file (for example, `apim-gateway-workload-identity.yaml`) and deploy it to your AKS cluster:

```bash
kubectl apply -f apim-gateway-workload-identity.yaml
```

Verify the deployment:

```bash
kubectl get pods -n <namespace-name>
kubectl logs -n <namespace-name> <pod-name>
```

[!INCLUDE [api-management-self-hosted-gateway-kubernetes-services](../../includes/api-management-self-hosted-gateway-kubernetes-services.md)]

## Related content

- Learn more about the API Management [self-hosted gateway](self-hosted-gateway-overview.md).
- Learn more about [Microsoft Entra workload identity for AKS](../aks/workload-identity-overview.md).
- Learn more about guidance for [running the self-hosted gateway on Kubernetes in production](how-to-self-hosted-gateway-on-kubernetes-in-production.md).
- Learn [how to deploy API Management self-hosted gateway to Azure Arc-enabled Kubernetes clusters](how-to-deploy-self-hosted-gateway-azure-arc.md).
- Compare with [Microsoft Entra authentication using client secrets](self-hosted-gateway-enable-azure-ad.md).
