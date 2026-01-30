---
title: Enable multi-zone redundancy in Azure Container Storage (version 2.x.x)
description: Enable storage redundancy across multiple availability zones in Azure Container Storage to improve stateful application availability. Use Locally Redundant Storage or Zone-redundant storage (ZRS) ESAN.
author: saurabh0501
ms.service: azure-container-storage
ms.topic: how-to
ms.date: 01/29/2026
ms.author: saurabsharma
# Customer intent: As a cloud engineer, I want to enable multi-zone storage redundancy in Azure Container Storage (version 2.x.x), so that I can enhance the availability of my stateful applications running in a multi-zone Kubernetes environment.
---

# Enable multi-zone storage redundancy in Azure Container Storage

With Azure Container Storage you can improve your stateful application's availability by using Zone-redundant storage (ZRS) or Locally redundant storage (LRS) depending on the requirements of your workload. You can select Locally redundant storage (LRS) with explicit zonal placement or zone redundant storage (ZRS) for synchronous replication across three availability zones, depending on your resiliency and performance needs. 

## Choose a redundancy model 

**Locally redundant storage (LRS)**: With LRS, every SAN is stored three times within an Azure storage cluster. This redundancy protects against loss of data due to hardware faults, such as a bad disk drive. However, if a disaster such as fire or flooding occurs within the data center, all replicas of an Elastic SAN using LRS could be lost or unrecoverable.

**Zone-redundant storage (ZRS)**: With ZRS, three copies of each SAN are stored in three distinct and physically isolated storage clusters in different Azure availability zones. Availability zones are unique physical locations within an Azure region. Each zone is made up of one or more data centers equipped with independent power, cooling, and networking. A write request to storage that is using ZRS happens synchronously. The write operation only returns successfully after the data is written to all replicas across the three availability zones.

## Prerequisites

[!INCLUDE [container-storage-prerequisites](../../../includes/container-storage-prerequisites.md)]

- If you're using Elastic SAN for the first time in the subscription, run the following one-time registration command per subscription:

```azurecli
az provider register --namespace Microsoft.ElasticSan 
```
- When ZRS has just been enabled in a region, you may need to register a subscription‑level feature flag so ACStor can deploy SAN targets"

```azurecli
Register-AzProviderFeature -FeatureName EnableElasticSANTargetDeployment -ProviderNamespace Microsoft.ElasticSan 
```
- Verify that the region supports your chosen redundancy option. See the current [Elastic SAN region availability](../elastic-san/elastic-san-create.md#)

## Create a storage class with Local redundant storage

###  Using an LRS sku without specifying a zone

If a region supports zones and a zone is not specified in the StorgeClass, then Azure Container Storage defaults to zone "1".

Create a YAML manifest file such as `storageclass.yaml`, then paste in the following specification.

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: esan-lrs-default
provisioner: san.csi.azure.com
parameters:
  skuName: Premium_LRS
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

###  Using an LRS sku and specifying a zone

Use a single zone when creating an LRS Elastic SAN in regions that support availability zones. In regions without zones, omit the zone parameter entirely to avoid validation failures. For LRS with zone pinning, the scheduler places the pod on a node in the specified zone, and the PersistentVolume (PV) binds to the corresponding zone’s SAN. Since LRS volumes are accessible from any zone, Azure Container Storage does not restrict cross‑zone attachment. The allowedTopologies section in the StorageClass ensures that the PV binds to a node in the same zone as the LRS SAN. 

Create a YAML manifest file such as `storageclass.yaml`, then paste in the following specification.

```yaml
# LRS with a zone (2)
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: esan-lrs-zone2
provisioner: san.csi.azure.com
parameters:
  skuName: Premium_LRS
  zones: "2"
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
# Optional:
allowedTopologies:
  - matchLabelExpressions:
    - key: topology.kubernetes.io/zone
      values:
        - canadacentral-2
 ```

## Create a storage class with Zone-redundant storage

Specifying a zone isn’t required because Azure Container Storage defaults to using all the three zones. However, if you choose to provide the zones field, you must list all the three zones as "1, 2, 3".

Create a YAML manifest file such as `storageclass.yaml`, then paste in the following specification.

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: esan-zrs-zones
provisioner: san.csi.azure.com
parameters:
  skuName: Premium_ZRS
  zones: "1,2,3" #optional
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
 ```

## Create StorageClass
```azurecli
kubectl apply -f storageclass.yaml
```
Run the following command to verify that the storage class is created:

```azurecli
kubectl get storageclass azuresan
```

You should see output similar to:

```output
NAME    PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
azuresan   san.csi.azure.com    Delete          Immediate              true                   10s
```

## 2 Create a persistent volume claim

Create a YAML manifest file such as `acstor-pvc.yaml`. Paste in the following code and save the file. The PVC `name` value can be whatever you want. Use the exact same StorageClass name that you created in the previous steps.

```yaml
      apiVersion: v1 
kind: PersistentVolumeClaim 
metadata: 
  name: managedpvc 
spec: 
  accessModes: 
    - ReadWriteOnce 
  resources: 
    requests: 
      storage: 1Gi 
  storageClassName: esan-zrs-zones # or esan-lrs-zone2,  esan-lrs-default
   ```

Apply the YAML manifest file to create the PVC.

```azurecli
kubectl apply -f acstor-pvc.yaml
```

You should see output similar to:
   
```output
persistentvolumeclaim/managedpvc created
```

## Deploy a pod and attach a persistent volume

Create a YAML manifest file such as `acstor-pod.yaml`. Paste in the following code and save the file. The PVC `name` value can be whatever you want.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: esan-app
spec:
  containers:
    - name: app
      image: mcr.microsoft.com/oss/nginx/nginx:1.25.2
      volumeMounts:
        - name: data
          mountPath: /data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: managedpvc
```

Apply the YAML manifest file to create the pod.

```azurecli
kubectl apply -f acstor-pod.yaml
```
 You should see output similar to the following:

```output
pod/esan-app created
```

Verify the PV and StorageClass:

```azurecli
kubectl get pv
kubectl describe sc esan-zrs 
kubectl describe sc esan-lrs-z1 
```
Confirm regional support and redundancy model for the volumes with the [Elastic SAN region list](../elastic-san/elastic-san-create.md#).

## See also

- [What is Azure Elastic SAN?](../elastic-san/elastic-san-introduction.md)
