---
title: Deploy Geospatial Consumption Zone on top of Azure Data Manager for Energy using Azure portal
description: Learn how to deploy Geospatial Consumption Zone on top of your Azure Data Manager for Energy instance using the Azure portal.
ms.service: azure-data-manager-energy
ms.custom: devx-track-azurecli
ms.topic: how-to
ms.author: eihaugho
author: EirikHaughom
ms.date: 05/30/2024
---

## Deploy Geospatial Consumption Zone (GCZ) on Azure Kubernetes Service (AKS)

This guide explains how to deploy Geospatial Consumption Zone (GCZ) as an **add-on extensibility service** for Azure Data Manager for Energy (ADME), using a **Helm chart** running on **Azure Kubernetes Service (AKS)**.

> ✅ Microsoft recommends deploying GCZ on a **dedicated AKS cluster** separate from ADME core services for optimal performance and isolation.

---

## ✅ Prerequisites

- Azure Subscription. If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/free).
- Azure Kubernetes Cluster (AKS) with virtual network integration. See [Create an Azure Kubernetes Service (AKS) cluster](/azure/aks/tutorial-kubernetes-deploy-cluster) and [Azure Container Networking Interface (CNI) networking](/azure/aks/azure-cni-overview) for further instructions.
- [Azure Cloud Shell](/azure/cloud-shell/overview) or [Azure CLI](/cli/azure/install-azure-cli), kubectl, and Git CLI.

## Deploy Geospatial Consumption Zone (GCZ) HELM Chart

1. Clone the GCZ repository to your local environment:

   ```bash
   git clone https://community.opengroup.org/osdu/platform/consumption/geospatial.git
   ```

1. Change directory to the `geospatial` folder:

   ```bash
   cd geospatial/devops/azure/charts/geospatial
   ```

1. Define variables for the deployment:

   ### [Unix Shell](#tab/unix-shell)

   ```bash
   # OSDU / Azure Identity Configuration
   AZURE_DNS_NAME="<YOUR_OSDU_INSTANCE_FQDN>"  # Example: osdu-ship.msft-osdu-test.org
   AZURE_TENANT_ID="<TENANT_ID_of_target_OSDU_deployment>"   # Entra ID tenant ID. Example: aaaabbbb-0000-cccc-1111-dddd2222eeee
   AZURE_CLIENT_ID="<CLIENT_ID_of_target_OSDU_deployment>"  # App Registration client ID. Example: 00001111-aaaa-2222-bbbb-3333cccc4444
   AZURE_CLIENT_SECRET="<CLIENT_SECRET_of_target_OSDU_deployment>"  # App Registration client secret. Example: Aa1Bb~2Cc3.-Dd4Ee5Ff6Gg7Hh8Ii9_Jj0Kk1Ll2
   AZURE_APP_ID="<CLIENT_ID_of_the_app-id_for_authentication>"
   AZURE_KEY_VAULT_URL="<YOUR_AZURE_KEYVAULT_URL>"

   # OAuth Redirect URL
   CALLBACK_URL="<CALLBACK_URL_configured_in_Entra_ID_App>"  # Example: http://localhost:8080
   PRIVATE_NETWORK="true"

   # Container Registry + GCZ Images
   AZURE_ACR="msosdu.azurecr.io"
   GCZ_PROVIDER_IMAGE_NAME="geospatial-provider"
   GCZ_PROVIDER_IMAGE_TAG="0.28.2"
   GCZ_TRANSFORMER_IMAGE_NAME="geospatial-transformer"
   GCZ_TRANSFORMER_IMAGE_TAG="0.28.2"

   # Istio Configuration (Enable ONLY if Istio exists on AKS)
   ISTIO_ENABLED="false"
   ISTIO_GCZ_DNS_HOST="<YOUR_GCZ_ISTIO_HOSTNAME>"   # Example: gcz.contoso.com
   ISTIO_GATEWAY_NAME="<YOUR_ISTIO_GATEWAY_NAME>"   # Example: istio-system/ingressgateway

   # Data Partition for GCZ
   DATA_PARTITION_ID="<YOUR_DATA_PARTITION_ID>"  # Example: opendes

   # AKS Deployment Configuration
   NAMESPACE="ignite"  # Recommended default namespace
   GCZ_IGNITE_SERVICE="osdu-gcz-service-gridgain-headless"  # Default Ignite Service name

   # Helm Release Settings
   CHART="osdu-gcz-service"
   CHART_VERSION="1.28.0"
   VERSION="0.28.2"
   ```

   ### [Windows PowerShell](#tab/windows-powershell)

   ```powershell
   # GCZ Deployment Environment Variables

   # OSDU / Azure Identity Configuration
   $AZURE_DNS_NAME="<YOUR_OSDU_INSTANCE_FQDN>"  # Example: osdu-ship.msft-osdu-test.org
   $AZURE_TENANT_ID="<TENANT_ID_of_target_OSDU_deployment>"  # Entra ID tenant ID. Example: aaaabbbb-0000-cccc-1111-dddd2222eeee
   $AZURE_CLIENT_ID="<CLIENT_ID_of_target_OSDU_deployment>"  # App Registration client ID. Example: 00001111-aaaa-2222-bbbb-3333cccc4444
   $AZURE_CLIENT_SECRET="<CLIENT_SECRET_of_target_OSDU_deployment>"  # App Registration client secret. Example: Aa1Bb~2Cc3.-Dd4Ee5Ff6Gg7Hh8Ii9_Jj0Kk1Ll2
   $AZURE_APP_ID="<CLIENT_ID_of_the_app-id_for_authentication>"
   $AZURE_KEY_VAULT_URL="<YOUR_AZURE_KEYVAULT_URL>"

   # OAuth Redirect URL
   $CALLBACK_URL="<CALLBACK_URL_configured_in_Entra_ID_App>" # Example: http://localhost:8080
   $PRIVATE_NETWORK="true"

   # Container Registry + GCZ Image Configuration
   $AZURE_ACR="msosdu.azurecr.io"
   $GCZ_PROVIDER_IMAGE_NAME="geospatial-provider"
   $GCZ_PROVIDER_IMAGE_TAG="0.28.2"
   $GCZ_TRANSFORMER_IMAGE_NAME="geospatial-transformer"
   $GCZ_TRANSFORMER_IMAGE_TAG="0.28.2"

   # Istio Configuration (Enable ONLY if Istio exists on AKS)
   $ISTIO_ENABLED="false"
   $ISTIO_GCZ_DNS_HOST="<YOUR_GCZ_ISTIO_HOSTNAME>"   # Example: gcz.contoso.com
   $ISTIO_GATEWAY_NAME="<YOUR_ISTIO_GATEWAY_NAME>"   # Example: istio-system/ingressgateway

   # Data Partition
   $DATA_PARTITION_ID="<YOUR_DATA_PARTITION_ID>"  # Example: opendes

   # AKS Deployment Details
   $NAMESPACE="ignite"
   $GCZ_IGNITE_SERVICE="osdu-gcz-service-gridgain-headless"

   # Helm Release Details
   $CHART="osdu-gcz-service"
   $CHART_VERSION="1.28.0"
   $VERSION="0.28.2"
   ```

1. Create the HELM chart:

   ### [Unix Shell](#tab/unix-shell)

   ```bash
   cat > osdu_gcz_custom_values.yaml << EOF
   # GCZ Configuration - Azure Deployment

   global:
     ignite:
       namespace: $NAMESPACE
       name: ignite
       image:
         name: gridgain/community
         tag: 8.8.43
       configuration:
         gcz_ignite_namespace: "$GCZ_IGNITE_NAMESPACE"
         gcz_ignite_service: "$GCZ_IGNITE_SERVICE"

     provider:
       namespace: $NAMESPACE
       entitlementsGroupsURL: "https://$AZURE_DNS_NAME/api/entitlements/v2/groups"
       image:
         repository: community.opengroup.org:5555
         name: osdu/platform/consumption/geospatial/geospatial-provider-master
         tag: latest
       service:
         type: LoadBalancer
       configuration:
         privateNetwork: "$PRIVATE_NETWORK"

     transformer:
       namespace: $NAMESPACE
       image:
         repository: community.opengroup.org:5555
         name: osdu/platform/consumption/geospatial/geospatial-transformer-master
         tag: latest
       service:
         type: LoadBalancer
       configuration:
         privateNetwork: "$PRIVATE_NETWORK"
         datapartitionid: $DATA_PARTITION_ID
         clientId: $AZURE_CLIENT_ID
         tenantId: $AZURE_TENANT_ID
         callbackURL: $CALLBACK_URL
         scope: $SCOPE
         searchQueryURL: "https://$AZURE_DNS_NAME/api/search/v2/query"
         searchCursorURL: "https://$AZURE_DNS_NAME/api/search/v2/query_with_cursor"
         schemaURL: "https://$AZURE_DNS_NAME/api/schema-service/v1/schema"
         entitlementsURL: "https://$AZURE_DNS_NAME/api/entitlements/v2"
         fileRetrievalURL: "https://$AZURE_DNS_NAME/api/dataset/v1/retrievalInstructions"
         crsconvertorURL: "https://$AZURE_DNS_NAME/api/crs/converter/v3/convertTrajectory"
         storageURL: "https://$AZURE_DNS_NAME/api/storage/v2/records"
         clientSecret: $(echo "$AZURE_CLIENT_SECRET" | base64)
         gcz_ignite_namespace: "$GCZ_IGNITE_NAMESPACE"
         gcz_ignite_service: "$GCZ_IGNITE_SERVICE"
   EOF
   ```

   ### [Windows PowerShell](#tab/windows-powershell-2)

   ```powershell
   @"
   # This file contains the essential configs for the gcz on azure helm chart

   ################################################################################
   # Specify the values for each service.
   #
   global:
     ignite:
       namespace: $NAMESPACE
       name: ignite
       image:
         name: gridgain/community
         tag: 8.8.43
       configuration:
         gcz_ignite_namespace: "$GCZ_IGNITE_NAMESPACE"
         gcz_ignite_service: "$GCZ_IGNITE_SERVICE"

     provider:
       namespace: $NAMESPACE
       entitlementsGroupsURL: "https://$AZURE_DNS_NAME/api/entitlements/v2/groups"
       image:
         repository: community.opengroup.org:5555
         name: osdu/platform/consumption/geospatial/geospatial-provider-master
         tag: latest
       service:
         type: LoadBalancer
       configuration:
         privateNetwork: "$PRIVATE_NETWORK"

     transformer:
       namespace: $NAMESPACE
       image:
         repository: community.opengroup.org:5555
         name: osdu/platform/consumption/geospatial/geospatial-transformer-master
         tag: latest
       service:
         type: LoadBalancer
       configuration:
         privateNetwork: "$PRIVATE_NETWORK"
         datapartitionid: $DATA_PARTITION_ID
         clientId: $AZURE_CLIENT_ID
         tenantId: $AZURE_TENANT_ID
         callbackURL: $CALLBACK_URL
         scope: $SCOPE
         searchQueryURL: "https://$AZURE_DNS_NAME/api/search/v2/query"
         searchCursorURL: "https://$AZURE_DNS_NAME/api/search/v2/query_with_cursor"
         schemaURL: "https://$AZURE_DNS_NAME/api/schema-service/v1/schema"
         entitlementsURL: "https://$AZURE_DNS_NAME/api/entitlements/v2"
         fileRetrievalURL: "https://$AZURE_DNS_NAME/api/dataset/v1/retrievalInstructions"
         crsconvertorURL: "https://$AZURE_DNS_NAME/api/crs/converter/v3/convertTrajectory"
         storageURL: "https://$AZURE_DNS_NAME/api/storage/v2/records"
         clientSecret: $(echo "$AZURE_CLIENT_SECRET" | base64)
         gcz_ignite_namespace: "$GCZ_IGNITE_NAMESPACE"
         gcz_ignite_service: "$GCZ_IGNITE_SERVICE"
   "@ | Out-File -FilePath osdu_gcz_custom_values.yaml
   ```

1. Change service type to `LoadBalancer` for the `provider` and `transformer` services configuration files.

   ### [Unix Shell](#tab/unix-shell)

   {% raw %}
   ```bash
   cat > ../provider/templates/service.yaml << EOF
   apiVersion: v1
   kind: Service
   metadata:
       name: gcz-provider
       namespace: {{ $.Values.global.provider.namespace }}
       annotations:
           service.beta.kubernetes.io/azure-load-balancer-internal: "{{ $.Values.global.provider.configuration.privateNetwork }}"
   spec:
       selector:
           app: provider
       ports:
       - port: 80
         protocol: TCP
         targetPort: 8083
       type: {{ $.Values.global.provider.service.type }}
   EOF

   cat > ../transformer/templates/service.yaml << EOF
   apiVersion: v1
   kind: Service
   metadata:
       name: gcz-transformer
       namespace: {{ $.Values.global.transformer.namespace }}
       annotations:
           service.beta.kubernetes.io/azure-load-balancer-internal: "{{ $.Values.global.transformer.configuration.privateNetwork }}"
   spec:
       selector:
           app: transformer
       ports:
       - port: 80
         protocol: TCP
         targetPort: 8080
       type: {{ $.Values.global.transformer.service.type }}
   EOF
   ```
   {% endraw %}

   ### [Windows PowerShell](#tab/windows-powershell)

   {% raw %}
   ```powershell
   @"
   apiVersion: v1
   kind: Service
   metadata:
       name: gcz-provider
       namespace: {{ $.Values.global.provider.namespace }}
       annotations:
           service.beta.kubernetes.io/azure-load-balancer-internal: "{{ $.Values.global.provider.configuration.privateNetwork }}"
   spec:
       selector:
           app: provider
       ports:
       - port: 80
         protocol: TCP
         targetPort: 8083
       type: {{ $.Values.global.provider.service.type }}
   "@ | Out-File -FilePath ../provider/templates/service.yaml

   @"
   apiVersion: v1
   kind: Service
   metadata:
       name: gcz-transformer
       namespace: {{ $.Values.global.transformer.namespace }}
       annotations:
           service.beta.kubernetes.io/azure-load-balancer-internal: "{{ $.Values.global.transformer.configuration.privateNetwork }}"
   spec:
       selector:
           app: transformer
       ports:
       - port: 80
         protocol: TCP
         targetPort: 8080
       type: {{ $.Values.global.transformer.service.type }}
   "@ | Out-File -FilePath ../transformer/templates/service.yaml
   ```
   {% endraw %}

1. Review the transformer configuration file `application.yml` to ensure the correct schemas are included.

   ```bash
   nano ../transformer/application.yml
   ```

1. Review the provider configuration file `koop-config.json`.

   ```bash
   nano ../provider/koop-config.json
   ```

1. Authenticate to the Azure Kubernetes Service (AKS) cluster:

   ```bash
   az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --admin
   ```

1. Create AKS Namespace:

   ```bash
   kubectl create namespace $NAMESPACE
   ```

1. Deploy HELM dependencies:

   ```bash
   helm dependency build
   ```

1. Deploy the GCZ HELM chart:

   ```bash
   helm upgrade -i "$CHART" . -n "$NAMESPACE" -f osdu_gcz_custom_values.yaml \
     --set-file global.provider.configLoaderJs="../../../../gcz-provider/gcz-provider-core/config/configLoader.js"
   ```

1. Verify the deployment:

   ```bash
   kubectl get pods -n $NAMESPACE
   ```

   Now you should see the pods for the `ignite`, `provider`, and `transformer` services.

1. Next get note the External IPs for the `provider` and `transformer` services.

   ```bash
   kubectl get service -n $NAMESPACE
   ```

   These IPs are used to connect to the GCZ API endpoints.

> [!IMPORTANT]
> If you wish to update the configuration files (e.g., `application.yml` or `koop-config.json`), you must update the AKS configuration (configmap) and then delete the existing pods for the `provider` and `transformer` services. The pods will be recreated with the new configuration. If you change the configuration using the GCZ APIs, the changes **will not** persist after a pod restart.
