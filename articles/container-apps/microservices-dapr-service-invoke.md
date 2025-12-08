---
title: "Tutorial: Use Dapr Service Invocation for Microservices Communication"
titleSuffix: "Azure Container Apps"
description: Enable two sample Dapr applications to communicate and leverage Azure Container Apps.
author: hhunter-ms
ms.author: hannahhunter
ms.service: azure-container-apps
ms.topic: how-to
ms.date: 08/02/2024
zone_pivot_group_filename: container-apps/dapr-zone-pivot-groups.json
zone_pivot_groups: dapr-languages-set
ms.custom:
  - devx-track-dotnet
  - devx-track-js
  - devx-track-python
  - sfi-image-nochange
---

# Tutorial: Use Dapr Service Invocation for microservices communication 

In this tutorial, you create and run two microservices that communicate securely using auto-mTLS and reliably using built-in retries via [the Dapr Service Invocation API](./dapr-overview.md#supported-dapr-apis-components-and-tooling). You'll:

> [!div class="checklist"]
> * Run the application locally.
> * Deploy the application to Azure Container Apps via the Azure Developer CLI with the provided Bicep. 

The sample service invocation project includes:
1. A `checkout` service that uses HTTP proxying on a loop to invoke a request on the `order-processor` service.  
1. An `order-processor` service that receives the request from the `checkout` service.  

:::image type="content" source="media/microservices-dapr-azd/service-invocation-quickstart.png" alt-text="Diagram of the service invocation services.":::

## Prerequisites

- The [Azure Developer CLI](/azure/developer/azure-developer-cli/install-azd)
- The Dapr CLI, [installed](https://docs.dapr.io/getting-started/install-dapr-cli/) and [initialized](https://docs.dapr.io/getting-started/install-dapr-selfhost/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/downloads)

::: zone pivot="nodejs"

## Run the Node.js applications locally

Before you deploy the application to Container Apps, take the steps in the following sections to run the `order-processor` and `checkout` services locally with Dapr.

### Prepare the project

1. Clone the [sample applications](https://github.com/Azure-Samples/svc-invoke-dapr-nodejs) to your local machine.

   ```bash
   git clone https://github.com/Azure-Samples/svc-invoke-dapr-nodejs.git
   ```

1. Go to the sample root directory.

   ```bash
   cd svc-invoke-dapr-nodejs
   ```

### Run the applications by using the Dapr CLI

Run the `order-processor` service and the `checkout` service by taking the following steps.

1. From the sample root directory, go to the *order-processor* directory.

   ```bash
   cd order-processor
   ```
1. Install the dependencies.

   ```bash
   npm install
   ```

1. Run the `order-processor` service.

   ```bash
   dapr run --app-port 5001 --app-id order-processor --app-protocol http --dapr-http-port 3501 -- npm start
   ```

1. In a new terminal window, go to the sample root directory, and then go to the *checkout* directory.

   ```bash
   cd checkout
   ```

1. Install the dependencies.

   ```bash
   npm install
   ```

1. Run the `checkout` service.

   ```bash
   dapr run  --app-id checkout --app-protocol http --dapr-http-port 3500 -- npm start
   ```

#### Expected output

In the `checkout` terminal, the `checkout` service sends information about 20 orders to the `order-processor` service and then temporarily pauses.

```
== APP == Order passed: {"orderId":1}
== APP == Order passed: {"orderId":2}
== APP == Order passed: {"orderId":3}
== APP == Order passed: {"orderId":4}
== APP == Order passed: {"orderId":5}
== APP == Order passed: {"orderId":6}
== APP == Order passed: {"orderId":7}
== APP == Order passed: {"orderId":8}
== APP == Order passed: {"orderId":9}
== APP == Order passed: {"orderId":10}
== APP == Order passed: {"orderId":11}
== APP == Order passed: {"orderId":12}
== APP == Order passed: {"orderId":13}
== APP == Order passed: {"orderId":14}
== APP == Order passed: {"orderId":15}
== APP == Order passed: {"orderId":16}
== APP == Order passed: {"orderId":17}
== APP == Order passed: {"orderId":18}
== APP == Order passed: {"orderId":19}
== APP == Order passed: {"orderId":20}
```

In the `order-processor` terminal, the `order-processor` service receives information about 20 orders and then temporarily pauses.

```
== APP == Order received: { orderId: 1 }
== APP == Order received: { orderId: 2 }
== APP == Order received: { orderId: 3 }
== APP == Order received: { orderId: 4 }
== APP == Order received: { orderId: 5 }
== APP == Order received: { orderId: 6 }
== APP == Order received: { orderId: 7 }
== APP == Order received: { orderId: 8 }
== APP == Order received: { orderId: 9 }
== APP == Order received: { orderId: 10 }
== APP == Order received: { orderId: 11 }
== APP == Order received: { orderId: 12 }
== APP == Order received: { orderId: 13 }
== APP == Order received: { orderId: 14 }
== APP == Order received: { orderId: 15 }
== APP == Order received: { orderId: 16 }
== APP == Order received: { orderId: 17 }
== APP == Order received: { orderId: 18 }
== APP == Order received: { orderId: 19 }
== APP == Order received: { orderId: 20 }
```

### Stop the applications

Select **Cmd/Ctrl**+**C** in both terminals to stop the service-to-service invocation.

## Deploy the application template by using the Azure Developer CLI

To deploy the application to Container Apps by using [`azd`](/azure/developer/azure-developer-cli/overview) commands, take the steps in the following sections.

### Prepare the project

In a new terminal window, go to the [sample](https://github.com/Azure-Samples/svc-invoke-dapr-nodejs) root directory.

```bash
cd svc-invoke-dapr-nodejs
```

### Provision and deploy by using the Azure Developer CLI

1. Run `azd init` to initialize the project.

   ```azdeveloper
   azd init
   ```

   When prompted in the terminal, enter a unique environment name. The command uses this name as a prefix for the resource group that it creates to hold all Azure resources.

1. Run `azd up` to prepare the infrastructure and deploy the application to Container Apps in a single command.

   ```azdeveloper
   azd up
   ```

   When prompted in the terminal, provide the following parameters.

   | Parameter | Description |
   | --------- | ----------- |
   | Azure Location  | The Azure location for your resources |
   | Azure subscription | The Azure subscription for your resources |

   This process may take some time to finish. While the `azd up` command runs, the output displays two Azure portal links that you can use to monitor the deployment progress. The output also demonstrates how `azd up`:

   - Creates and configures all necessary Azure resources via the Bicep files in the *./infra* directory by using `azd provision`. After the Azure Developer CLI deploys these resources, you can use the Azure portal to access them. The files that are used to configure the Azure resources include:
     - *main.parameters.json*.
     - *main.bicep*.
     - An *app* resources directory organized by functionality.
     - A *core* reference library that contains the Bicep modules used by the `azd` template.
   - Deploys the code using `azd deploy`.

#### Expected output

The `azd init` command displays output that's similar to the following lines:

```azdeveloper
Initializing an app to run on Azure (azd init)

? Enter a unique environment name: [? for help] <environment-name>

? Enter a unique environment name: <environment-name>

SUCCESS: Initialized environment <environment-name>.
```

The `azd up` command displays output that's similar to the following lines:

```azdeveloper
? Select an Azure Subscription to use:  3. <subscription-name> (aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e)
? Enter a value for the 'location' infrastructure parameter: 51. (US) East US 2 (eastus2)

Packaging services (azd package)

  (✓) Done: Packaging service api
  - Container: service-invoke-dapr-node-aca/api-<environment-name>:azd-deploy-1765226976


  (✓) Done: Packaging service worker
  - Container: service-invoke-dapr-node-aca/worker-<environment-name>:azd-deploy-1765226992


Provisioning Azure resources (azd provision)
Provisioning Azure resources can take some time.

Subscription: <subscription-name> (aaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e)
Location: East US 2

  You can view detailed progress in the Azure Portal:
  https://portal.azure.com/#view/HubsExtension/DeploymentDetailsBlade/~/overview/id/%2Fsubscriptions%2Faaaa0a0a-bb1b-cc2c-dd3d-eeeeee4e4e4e%2Fproviders%2FMicrosoft.Resources%2Fdeployments%2F<environment-name>-1765226998

  (✓) Done: Resource group: rg-<environment-name> (2.341s)
  (✓) Done: Log Analytics workspace: log-a1bc2de3fh4ij (25.882s)
  (✓) Done: Application Insights: appi-a1bc2de3fh4ij (1.314s)
  (✓) Done: Portal dashboard: dash-a1bc2de3fh4ij (1.833s)
  (✓) Done: Container Registry: cra1bc2de3fh4ij (17.672s)
  (✓) Done: Container Apps Environment: cae-a1bc2de3fh4ij (1m53.997s)
  (✓) Done: Container App: ca-checkout-a1bc2de3fh4ij (27.995s)
  (✓) Done: Container App: ca-order-processor-a1bc2de3fh4ij (22.651s)

Deploying services (azd deploy)

  (✓) Done: Deploying service api
  - Endpoint: https://ca-order-processor-a1bc2de3fh4ij.wittymeadow-c2de3fh4.eastus2.azurecontainerapps.io/

  (✓) Done: Deploying service worker
  - Endpoint: https://ca-checkout-a1bc2de3fh4ij.wittymeadow-c2de3fh4.eastus2.azurecontainerapps.io/


SUCCESS: Your up workflow to provision and deploy to Azure completed in 5 minutes 31 seconds.
```

### Confirm successful deployment 

To verify that the `checkout` service is passing orders to the `order-processor` service, take the following steps.

1. In the terminal output, copy the `checkout` container app name.

1. Sign in to the [Azure portal](https://portal.azure.com), and then search for the container app resource by name.

1. On the container app **Overview** page, select **Monitoring** > **Log stream**.

   :::image type="content" source="media/microservices-dapr-azd/log-streams-menu.png" alt-text="Screenshot of the Azure portal side panel. Under Monitoring, Log stream is highlighted.":::

1. On the **Log stream** page, next to **Container**, select **checkout**.

   :::image type="content" source="media/microservices-dapr-azd/select-checkout-container-logs.png" alt-text="Screenshot of the Log stream page for the checkout container app. In the Container list, checkout is highlighted." lightbox="media/microservices-dapr-azd/select-checkout-container-logs.png":::

1. Confirm the `checkout` container is logging the same output as in the terminal earlier.

   ```
   ```
   
1. Take similar steps for the `order-processor` service.

   ```
   ```
   


## What happened?

Upon successful completion of the `azd up` command:

- Azure Developer CLI provisioned the Azure resources referenced in the [sample project's `./infra` directory](https://github.com/Azure-Samples/svc-invoke-dapr-nodejs/tree/main/infra) to the Azure subscription you specified. You can now view those Azure resources via the Azure portal.
- The app deployed to Azure Container Apps. From the portal, you can browse the fully functional app.


::: zone-end

::: zone pivot="python"

## Run the Python applications locally

Before you deploy the application to Container Apps, take the steps in the following sections to run the `order-processor` and `checkout` services locally with Dapr.

### Prepare the project

1. Clone the [sample applications](https://github.com/Azure-Samples/svc-invoke-dapr-python) to your local machine.

   ```bash
   git clone https://github.com/Azure-Samples/svc-invoke-dapr-python.git
   ```

1. Navigate into the sample's root directory.

   ```bash
   cd svc-invoke-dapr-python
   ```

### Run the applications by using the Dapr CLI

Run the `order-processor` service and the `checkout` service by taking the following steps.

1. From the sample root directory, go to the *order-processor* directory.

   ```bash
   cd order-processor
   ```
1. Install the dependencies.

   ```bash
   pip3 install -r requirements.txt
   ```

1. Run the `order-processor` service.

   ```bash
   dapr run --app-port 8001 --app-id order-processor --app-protocol http --dapr-http-port 3501 -- python3 app.py
   ```

1. In a new terminal window, go to the sample root directory, and then go to the *checkout* directory.

   ```bash
   cd checkout
   ```

1. Install the dependencies.

   ```bash
   pip3 install -r requirements.txt
   ```

1. Run the `checkout` service.

   ```bash
   dapr run  --app-id checkout --app-protocol http --dapr-http-port 3500 -- python3 app.py
   ```

#### Expected output

In the `checkout` terminal, the `checkout` service sends information about 19 orders to the `order-processor` service and then temporarily pauses.

```
== APP == Order passed: {"orderId": 1}
== APP == Order passed: {"orderId": 2}
== APP == Order passed: {"orderId": 3}
== APP == Order passed: {"orderId": 4}
== APP == Order passed: {"orderId": 5}
== APP == Order passed: {"orderId": 6}
== APP == Order passed: {"orderId": 7}
== APP == Order passed: {"orderId": 8}
== APP == Order passed: {"orderId": 9}
== APP == Order passed: {"orderId": 10}
== APP == Order passed: {"orderId": 11}
== APP == Order passed: {"orderId": 12}
== APP == Order passed: {"orderId": 13}
== APP == Order passed: {"orderId": 14}
== APP == Order passed: {"orderId": 15}
== APP == Order passed: {"orderId": 16}
== APP == Order passed: {"orderId": 17}
== APP == Order passed: {"orderId": 18}
== APP == Order passed: {"orderId": 19}
```

In the `order-processor` terminal, the `order-processor` service receives information about 19 orders and then temporarily pauses.

```
== APP == Order received : {"orderId": 1}
== APP == 127.0.0.1 - - [08/Dec/2025 16:42:08] "POST /orders HTTP/1.1" 200 -
== APP == Order received : {"orderId": 2}
== APP == 127.0.0.1 - - [08/Dec/2025 16:42:09] "POST /orders HTTP/1.1" 200 -
== APP == Order received : {"orderId": 3}
== APP == 127.0.0.1 - - [08/Dec/2025 16:42:10] "POST /orders HTTP/1.1" 200 -
== APP == Order received : {"orderId": 4}
== APP == 127.0.0.1 - - [08/Dec/2025 16:42:11] "POST /orders HTTP/1.1" 200 -
== APP == Order received : {"orderId": 5}
== APP == 127.0.0.1 - - [08/Dec/2025 16:42:12] "POST /orders HTTP/1.1" 200 -
== APP == Order received : {"orderId": 6}
== APP == 127.0.0.1 - - [08/Dec/2025 16:42:13] "POST /orders HTTP/1.1" 200 -
== APP == Order received : {"orderId": 7}
== APP == 127.0.0.1 - - [08/Dec/2025 16:42:14] "POST /orders HTTP/1.1" 200 -
== APP == Order received : {"orderId": 8}
== APP == 127.0.0.1 - - [08/Dec/2025 16:42:15] "POST /orders HTTP/1.1" 200 -
== APP == Order received : {"orderId": 9}
== APP == 127.0.0.1 - - [08/Dec/2025 16:42:16] "POST /orders HTTP/1.1" 200 -
== APP == Order received : {"orderId": 10}
== APP == 127.0.0.1 - - [08/Dec/2025 16:42:17] "POST /orders HTTP/1.1" 200 -
== APP == Order received : {"orderId": 11}
== APP == 127.0.0.1 - - [08/Dec/2025 16:42:18] "POST /orders HTTP/1.1" 200 -
== APP == Order received : {"orderId": 12}
== APP == 127.0.0.1 - - [08/Dec/2025 16:42:19] "POST /orders HTTP/1.1" 200 -
== APP == Order received : {"orderId": 13}
== APP == 127.0.0.1 - - [08/Dec/2025 16:42:20] "POST /orders HTTP/1.1" 200 -
== APP == Order received : {"orderId": 14}
== APP == 127.0.0.1 - - [08/Dec/2025 16:42:21] "POST /orders HTTP/1.1" 200 -
== APP == Order received : {"orderId": 15}
== APP == 127.0.0.1 - - [08/Dec/2025 16:42:22] "POST /orders HTTP/1.1" 200 -
== APP == Order received : {"orderId": 16}
== APP == 127.0.0.1 - - [08/Dec/2025 16:42:23] "POST /orders HTTP/1.1" 200 -
== APP == Order received : {"orderId": 17}
== APP == 127.0.0.1 - - [08/Dec/2025 16:42:24] "POST /orders HTTP/1.1" 200 -
== APP == Order received : {"orderId": 18}
== APP == 127.0.0.1 - - [08/Dec/2025 16:42:25] "POST /orders HTTP/1.1" 200 -
== APP == Order received : {"orderId": 19}
== APP == 127.0.0.1 - - [08/Dec/2025 16:42:26] "POST /orders HTTP/1.1" 200 -
```

### Stop the applications

Select **Cmd/Ctrl**+**C** in both terminals to stop the service-to-service invocation.

## Deploy the application template by using the Azure Developer CLI

To deploy the application to Container Apps by using [`azd`](/azure/developer/azure-developer-cli/overview) commands, take the steps in the following sections.

### Prepare the project

In a new terminal window, go to the [sample](https://github.com/Azure-Samples/svc-invoke-dapr-python) root directory.

```bash
cd svc-invoke-dapr-python
```

### Provision and deploy by using the Azure Developer CLI

1. Run `azd init` to initialize the project.

   ```azdeveloper
   azd init
   ```

   When prompted in the terminal, enter a unique environment name. The command uses this name as a prefix for the resource group that it creates to hold all Azure resources.

1. Run `azd up` to prepare the infrastructure and deploy the application to Container Apps in a single command.

   ```azdeveloper
   azd up
   ```

   When prompted in the terminal, provide the following parameters.

   | Parameter | Description |
   | --------- | ----------- |
   | Azure location  | The Azure location for your resources |
   | Azure subscription | The Azure subscription for your resources |

   This process may take some time to finish. While the `azd up` command runs, the output displays two Azure portal links that you can use to monitor the deployment progress. The output also demonstrates how `azd up`:

   - Creates and configures all necessary Azure resources via the Bicep files in the *./infra* directory by using `azd provision`. After the Azure Developer CLI deploys these resources, you can use the Azure portal to access them. The files that are used to configure the Azure resources include:
     - *main.parameters.json*.
     - *main.bicep*.
     - An *app* resources directory organized by functionality.
     - A *core* reference library that contains the Bicep modules used by the `azd` template.
   - Deploys the code using `azd deploy`.

#### Expected output

The `azd init` command displays output that's similar to the following lines:

```azdeveloper
Initializing an app to run on Azure (azd init)

? Enter a unique environment name: [? for help] <environment-name>

? Enter a unique environment name: <environment-name>

SUCCESS: Initialized environment <environment-name>.
```

The `azd up` command displays output that's similar to the following lines:

```azdeveloper

```

### Confirm successful deployment 

To verify that the `checkout` service is passing orders to the `order-processor` service, take the following steps.

1. In the terminal output, copy the `checkout` container app name.

1. Sign in to the [Azure portal](https://portal.azure.com), and then search for the container app resource by name.

1. On the container app **Overview** page, select **Monitoring** > **Log stream**.

   :::image type="content" source="media/microservices-dapr-azd/log-streams-menu.png" alt-text="Screenshot of the Azure portal side panel. Under Monitoring, Log stream is highlighted.":::

1. On the **Log stream** page, next to **Container**, select **checkout**.

   :::image type="content" source="media/microservices-dapr-azd/select-checkout-container-logs.png" alt-text="Screenshot of the Log stream page for the checkout container app. In the Container list, checkout is highlighted." lightbox="media/microservices-dapr-azd/select-checkout-container-logs.png":::

1. Confirm the `checkout` container is logging the same output as in the terminal earlier.

   ```
   Connecting to stream...
   2025-12-08T21:52:13.30188  Connecting to the container 'checkout'...
   2025-12-08T21:52:13.32059  Successfully Connected to container: 'checkout' [Revision: 'ca-checkout-fuugkyrbrvzpc--azd-1765230684', Replica: 'ca-checkout-fuugkyrbrvzpc--azd-1765230684-86db64496d-dfrgt']
   2025-12-08T21:51:50.336588427Z Order passed: {"orderId": 1}
   2025-12-08T21:51:51.344226554Z Order passed: {"orderId": 2}
   2025-12-08T21:51:52.352458279Z Order passed: {"orderId": 3}
   2025-12-08T21:51:53.359545509Z Order passed: {"orderId": 4}
   2025-12-08T21:51:54.367664737Z Order passed: {"orderId": 5}
   2025-12-08T21:51:55.375686968Z Order passed: {"orderId": 6}
   2025-12-08T21:51:56.384068096Z Order passed: {"orderId": 7}
   2025-12-08T21:51:57.392023627Z Order passed: {"orderId": 8}
   2025-12-08T21:51:58.400084856Z Order passed: {"orderId": 9}
   2025-12-08T21:51:59.407839688Z Order passed: {"orderId": 10}
   2025-12-08T21:52:00.415796718Z Order passed: {"orderId": 11}
   2025-12-08T21:52:01.423684349Z Order passed: {"orderId": 12}
   2025-12-08T21:52:02.431038891Z Order passed: {"orderId": 13}
   2025-12-08T21:52:03.438415598Z Order passed: {"orderId": 14}
   2025-12-08T21:52:04.445862305Z Order passed: {"orderId": 15}
   2025-12-08T21:52:05.454030709Z Order passed: {"orderId": 16}
   2025-12-08T21:52:06.462323213Z Order passed: {"orderId": 17}
   2025-12-08T21:52:07.469778904Z Order passed: {"orderId": 18}
   2025-12-08T21:52:08.478176259Z Order passed: {"orderId": 19}
   ```
   
1. Take similar steps for the `order-processor` service.

   ```
   Connecting to stream...
   2025-12-08T21:52:21.69283  Connecting to the container 'order-processor'...
   2025-12-08T21:52:21.71200  Successfully Connected to container: 'order-processor' [Revision: 'ca-order-processor-fuugkyrbrvzpc--azd-1765230657', Replica: 'ca-order-processor-fuugkyrbrvzpc--azd-1765230657-ccdd94f7dvw2h6']
   2025-12-08T21:52:08.466641579Z 127.0.0.1 - - [08/Dec/2025 21:52:08] "POST /orders HTTP/1.1" 200 -
   2025-12-08T21:52:19.484297503Z Order received : {"orderId": 1}
   2025-12-08T21:52:19.484712607Z 127.0.0.1 - - [08/Dec/2025 21:52:19] "POST /orders HTTP/1.1" 200 -
   2025-12-08T21:52:20.492919969Z Order received : {"orderId": 2}
   2025-12-08T21:52:20.493318072Z 127.0.0.1 - - [08/Dec/2025 21:52:20] "POST /orders HTTP/1.1" 200 -
   2025-12-08T21:52:21.501517134Z Order received : {"orderId": 3}
   2025-12-08T21:52:21.501881937Z 127.0.0.1 - - [08/Dec/2025 21:52:21] "POST /orders HTTP/1.1" 200 -
   2025-12-08T21:52:22.509507378Z Order received : {"orderId": 4}
   2025-12-08T21:52:22.510107685Z 127.0.0.1 - - [08/Dec/2025 21:52:22] "POST /orders HTTP/1.1" 200 -
   2025-12-08T21:52:23.518153270Z Order received : {"orderId": 5}
   2025-12-08T21:52:23.519026380Z 127.0.0.1 - - [08/Dec/2025 21:52:23] "POST /orders HTTP/1.1" 200 -
   2025-12-08T21:52:24.526933360Z Order received : {"orderId": 6}
   2025-12-08T21:52:24.528534270Z 127.0.0.1 - - [08/Dec/2025 21:52:24] "POST /orders HTTP/1.1" 200 -
   2025-12-08T21:52:25.536263633Z Order received : {"orderId": 7}
   2025-12-08T21:52:25.536895737Z 127.0.0.1 - - [08/Dec/2025 21:52:25] "POST /orders HTTP/1.1" 200 -
   2025-12-08T21:52:26.544453199Z Order received : {"orderId": 8}
   2025-12-08T21:52:26.545099303Z 127.0.0.1 - - [08/Dec/2025 21:52:26] "POST /orders HTTP/1.1" 200 -
   2025-12-08T21:52:27.552418814Z Order received : {"orderId": 9}
   2025-12-08T21:52:27.552886419Z 127.0.0.1 - - [08/Dec/2025 21:52:27] "POST /orders HTTP/1.1" 200 -
   2025-12-08T21:52:28.560536453Z Order received : {"orderId": 10}
   2025-12-08T21:52:28.560978457Z 127.0.0.1 - - [08/Dec/2025 21:52:28] "POST /orders HTTP/1.1" 200 -
   2025-12-08T21:52:29.569267098Z Order received : {"orderId": 11}
   2025-12-08T21:52:29.569883405Z 127.0.0.1 - - [08/Dec/2025 21:52:29] "POST /orders HTTP/1.1" 200 -
   2025-12-08T21:52:30.577652340Z Order received : {"orderId": 12}
   2025-12-08T21:52:30.578145945Z 127.0.0.1 - - [08/Dec/2025 21:52:30] "POST /orders HTTP/1.1" 200 -
   2025-12-08T21:52:31.585742379Z Order received : {"orderId": 13}
   2025-12-08T21:52:31.586148183Z 127.0.0.1 - - [08/Dec/2025 21:52:31] "POST /orders HTTP/1.1" 200 -
   2025-12-08T21:52:32.593496421Z Order received : {"orderId": 14}
   2025-12-08T21:52:32.594131028Z 127.0.0.1 - - [08/Dec/2025 21:52:32] "POST /orders HTTP/1.1" 200 -
   2025-12-08T21:52:33.602273111Z Order received : {"orderId": 15}
   2025-12-08T21:52:33.604202631Z 127.0.0.1 - - [08/Dec/2025 21:52:33] "POST /orders HTTP/1.1" 200 -
   2025-12-08T21:52:34.610559896Z Order received : {"orderId": 16}
   2025-12-08T21:52:34.610927600Z 127.0.0.1 - - [08/Dec/2025 21:52:34] "POST /orders HTTP/1.1" 200 -
   2025-12-08T21:52:35.618588379Z Order received : {"orderId": 17}
   2025-12-08T21:52:35.619991693Z 127.0.0.1 - - [08/Dec/2025 21:52:35] "POST /orders HTTP/1.1" 200 -
   2025-12-08T21:52:36.628053075Z Order received : {"orderId": 18}
   2025-12-08T21:52:36.628608981Z 127.0.0.1 - - [08/Dec/2025 21:52:36] "POST /orders HTTP/1.1" 200 -
   2025-12-08T21:52:37.638211579Z Order received : {"orderId": 19}
   2025-12-08T21:52:37.638144079Z 127.0.0.1 - - [08/Dec/2025 21:52:37] "POST /orders HTTP/1.1" 200 -
   ```


## What happened?

Upon successful completion of the `azd up` command:

- Azure Developer CLI provisioned the Azure resources referenced in the [sample project's `./infra` directory](https://github.com/Azure-Samples/svc-invoke-dapr-python/tree/main/infra) to the Azure subscription you specified. You can now view those Azure resources via the Azure portal.
- The app deployed to Azure Container Apps. From the portal, you can browse the fully functional app.

::: zone-end

::: zone pivot="csharp"

## Run the .NET applications locally

Before you deploy the application to Container Apps, take the steps in the following sections to run the `order-processor` and `checkout` services locally with Dapr.

### Prepare the project

1. Clone the [sample applications](https://github.com/Azure-Samples/svc-invoke-dapr-csharp) to your local machine.

   ```bash
   git clone https://github.com/Azure-Samples/svc-invoke-dapr-csharp.git
   ```

1. Navigate into the sample's root directory.

   ```bash
   cd svc-invoke-dapr-csharp
   ```

### Run the applications by using the Dapr CLI

Run the `order-processor` service and the `checkout` service by taking the following steps.

1. From the sample root directory, go to the *order-processor* directory.

   ```bash
   cd order-processor
   ```
1. Install the dependencies.

   ```bash
   dotnet build
   ```

1. Run the `order-processor` service.

   ```bash
   dapr run --app-port 7001 --app-id order-processor --app-protocol http --dapr-http-port 3501 -- dotnet run
   ```

1. In a new terminal window, go to the sample root directory, and then go to the *checkout* directory.

   ```bash
   cd checkout
   ```

1. Install the dependencies.

   ```bash
   dotnet build
   ```

1. Run the `checkout` service.

   ```bash
   dapr run  --app-id checkout --app-protocol http --dapr-http-port 3500 -- dotnet run
   ```

#### Expected output

In the `checkout` terminal, the `checkout` service sends information about 20 orders to the `order-processor` service and then temporarily pauses.

   ```
   == APP == Order passed: {"orderId":1}
   == APP == Order passed: {"orderId":2}
   == APP == Order passed: {"orderId":3}
   == APP == Order passed: {"orderId":4}
   == APP == Order passed: {"orderId":5}
   == APP == Order passed: {"orderId":6}
   == APP == Order passed: {"orderId":7}
   == APP == Order passed: {"orderId":8}
   == APP == Order passed: {"orderId":9}
   == APP == Order passed: {"orderId":10}
   == APP == Order passed: {"orderId":11}
   == APP == Order passed: {"orderId":12}
   == APP == Order passed: {"orderId":13}
   == APP == Order passed: {"orderId":14}
   == APP == Order passed: {"orderId":15}
   == APP == Order passed: {"orderId":16}
   == APP == Order passed: {"orderId":17}
   == APP == Order passed: {"orderId":18}
   == APP == Order passed: {"orderId":19}
   == APP == Order passed: {"orderId":20}
   ```

In the `order-processor` terminal, the `order-processor` service receives information about 20 orders and then temporarily pauses.

   ```
   == APP == Order received: { orderId: 1 }
   == APP == Order received: { orderId: 2 }
   == APP == Order received: { orderId: 3 }
   == APP == Order received: { orderId: 4 }
   == APP == Order received: { orderId: 5 }
   == APP == Order received: { orderId: 6 }
   == APP == Order received: { orderId: 7 }
   == APP == Order received: { orderId: 8 }
   == APP == Order received: { orderId: 9 }
   == APP == Order received: { orderId: 10 }
   == APP == Order received: { orderId: 11 }
   == APP == Order received: { orderId: 12 }
   == APP == Order received: { orderId: 13 }
   == APP == Order received: { orderId: 14 }
   == APP == Order received: { orderId: 15 }
   == APP == Order received: { orderId: 16 }
   == APP == Order received: { orderId: 17 }
   == APP == Order received: { orderId: 18 }
   == APP == Order received: { orderId: 19 }
   == APP == Order received: { orderId: 20 }
   ```

### Stop the applications

Select **Cmd/Ctrl**+**C** in both terminals to stop the service-to-service invocation.

## Deploy the application template by using the Azure Developer CLI

To deploy the application to Container Apps by using [`azd`](/azure/developer/azure-developer-cli/overview) commands, take the steps in the following sections.

### Prepare the project

In a new terminal window, go to the [sample](https://github.com/Azure-Samples/svc-invoke-dapr-csharp) root directory.

```bash
cd svc-invoke-dapr-csharp
```

### Provision and deploy by using the Azure Developer CLI

1. Run `azd init` to initialize the project.

   ```azdeveloper
   azd init
   ```

   When prompted in the terminal, enter a unique environment name. The command uses this name as a prefix for the resource group that it creates to hold all Azure resources.

1. Run `azd up` to prepare the infrastructure and deploy the application to Container Apps in a single command.

   ```azdeveloper
   azd up
   ```

   When prompted in the terminal, provide the following parameters.

   | Parameter | Description |
   | --------- | ----------- |
   | Azure location  | The Azure location for your resources |
   | Azure subscription | The Azure subscription for your resources |

   This process may take some time to finish. While the `azd up` command runs, the output displays two Azure portal links that you can use to monitor the deployment progress. The output also demonstrates how `azd up`:

   - Creates and configures all necessary Azure resources via the Bicep files in the *./infra* directory by using `azd provision`. After the Azure Developer CLI deploys these resources, you can use the Azure portal to access them. The files that are used to configure the Azure resources include:
     - *main.parameters.json*.
     - *main.bicep*.
     - An *app* resources directory organized by functionality.
     - A *core* reference library that contains the Bicep modules used by the `azd` template.
   - Deploys the code using `azd deploy`.

#### Expected output

The `azd init` command displays output that's similar to the following lines:

```azdeveloper
Initializing an app to run on Azure (azd init)

? Enter a unique environment name: [? for help] <environment-name>

? Enter a unique environment name: <environment-name>

SUCCESS: Initialized environment <environment-name>.
```

The `azd up` command displays output that's similar to the following lines:

```azdeveloper

```

### Confirm successful deployment

To verify that the `checkout` service is passing orders to the `order-processor` service, take the following steps.

1. In the terminal output, copy the `checkout` container app name.

1. Sign in to the [Azure portal](https://portal.azure.com), and then search for the container app resource by name.

1. On the container app **Overview** page, select **Monitoring** > **Log stream**.

   :::image type="content" source="media/microservices-dapr-azd/log-streams-menu.png" alt-text="Screenshot of the Azure portal side panel. Under Monitoring, Log stream is highlighted.":::

1. On the **Log stream** page, next to **Container**, select **checkout**.

   :::image type="content" source="media/microservices-dapr-azd/select-checkout-container-logs.png" alt-text="Screenshot of the Log stream page for the checkout container app. In the Container list, checkout is highlighted." lightbox="media/microservices-dapr-azd/select-checkout-container-logs.png":::

1. Confirm the `checkout` container is logging the same output as in the terminal earlier.

   ```
   ```
   
1. Take similar steps for the `order-processor` service.

   ```
   ```


## What happened?

Upon successful completion of the `azd up` command:

- Azure Developer CLI provisioned the Azure resources referenced in the [sample project's `./infra` directory](https://github.com/Azure-Samples/svc-invoke-dapr-csharp/tree/main/infra) to the Azure subscription you specified. You can now view those Azure resources via the Azure portal.
- The app deployed to Azure Container Apps. From the portal, you can browse the fully functional app.


::: zone-end

## Clean up resources

If you're not going to continue to use this application, delete the Azure resources you've provisioned with the following command:

```azdeveloper
azd down
```

## Next steps

- Learn more about [deploying Dapr applications to Azure Container Apps](./microservices-dapr.md).
- [Enable token authentication for Dapr requests.](./dapr-authentication-token.md)
- Learn more about [Azure Developer CLI](/azure/developer/azure-developer-cli/overview) and [making your applications compatible with `azd`](/azure/developer/azure-developer-cli/make-azd-compatible).
