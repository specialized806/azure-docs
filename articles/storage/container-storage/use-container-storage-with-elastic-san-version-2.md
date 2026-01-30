---
title: Use Azure Container Storage with Azure Elastic SAN
description: You can configure Azure Container Storage to use Azure Elastic SAN.
author: saurabh0501
ms.service: azure-container-storage
ms.topic: how-to
ms.date: 01/28/2026
ms.author: saurabsharma
ms.custom:
  - references_regions
    
# Customer intent: "As a Kubernetes administrator, I want to configure Azure Container Storage with Azure Elastic SAN so that I can efficiently manage persistent storage for my containerized applications."
---

# Use Azure Container Storage with Azure Elastic SAN

Azure Container Storage is a cloud-based volume management, deployment, and orchestration service built natively for containers. Azure Elastic SAN is a fully integrated solution that simplifies deploying, scaling, and managing a SAN, while also offering built-in cloud capabilities like high availability.

This article shows you how to configure Azure Container Storage to use Azure Elastic SAN. At the end of this article, you'll be able to use Elastic SAN as a storage option for your stateful workloads.

## Prerequisites

[!INCLUDE [container-storage-prerequisites](../../../includes/container-storage-prerequisites.md)]

## Limitations

The following features aren't currently supported when you use Azure Container Storage to deploy and orchestrate an Elastic SAN.

- Elastic SAN capacity expansion isn't supported via Azure Container Storage. However, you can [resize Elastic SAN](../elastic-san/elastic-san-expand.md) directly from the Azure portal or using Azure CLI.

## Regional availability

[!INCLUDE [container-storage-regions](../../../includes/container-storage-regions.md)]

## 1 Create a storage class for Elastic SAN

If you haven't already done so, [install Azure Container Storage.](install-container-storage-aks.md) You can skip creating a storage class if you enabled the Elastic SAN storage type during installation and plan to use the default storage class that the installation generates.

Azure Container Storage supports three ways to use Elastic SAN with AKS: 

- Dynamic provisioning: Azure Container Storage creates the SAN volume group(s) and volumes on demand.
- Pre‑provisioned Elastic SAN and volume group(s): You or your infrastructure team can create the Elastic SAN and/or volume group(s) up front; Azure Container Storage then consumes those existing Elastic SAN and volume group resources and dynamically provisions volumes within those resources.
- Static volume provisioning: You fully pre‑create the Elastic SAN, volume group, and volume, and surface the volume to Kubernetes as a statically defined persistent volume (PV).

The following sections show how to configure a storage class for each model.

## 1.1 Dynamic provisioning of Elastic SAN, volume group and volume

### 1.1.1 Create a default storage class
Create a YAML manifest file such as `storageclass.yaml`, then paste in the following specification.

  ```yaml
  apiVersion: storage.k8s.io/v1
  kind: StorageClass
  metadata:
    name: azuresan
  provisioner: san.csi.azure.com
  reclaimPolicy: Delete
  volumeBindingMode: Immediate
  allowVolumeExpansion: true 
  ```
The default Elastic SAN capacity provisioned with this storage class is 1 TiB.

### 1.1.2 Create a storage class by setting initial Elastic SAN capacity

If you need different initial capacity than the default 1 TiB, you can specify it by setting the 'initialStorageTiB' parameter in the storage class using the following specification.

   ```yaml
  apiVersion: storage.k8s.io/v1
  kind: StorageClass
  metadata:
    name: azuresan
  provisioner: san.csi.azure.com
  reclaimPolicy: Delete
  volumeBindingMode: Immediate
  allowVolumeExpansion: true
  parameters: 
    initialStorageTiB: "10" 
   ```
 ## 1.2 Pre‑provisioned Elastic SAN and Volume group(s)

 You can pre‑create an Elastic SAN or Elastic SAN + volume group, and reference those resources in the storage class.
 
 ### 1.2.1 Create a storage class when you want to use a pre-provisioned Elastic SAN (optional)

First, create a new Elastic SAN instance in the managed resource group of your AKS cluster. Then create a storage class that references the Elastic SAN you created.
  
Step 1: Identify the managed resource group of the AKS cluster.
   
  ```azurecli
  kubectl get node -o jsonpath={range .items[*]}{.spec.providerID}{"\n"}{end}
  ```
Node resource group appears after the /resourceGroup/ section of the provider ID 

Step 2: Now create an Elastic SAN via Azure CLI.

  ```azurecli
  az elastic-san create --resource-group <node-resource-group> --name <SAN name> --location <node-region> --sku Premium_ZRS --base-size-tib 1 --extended-capacity-size-tib 1
  ```
Step 3: Create the storage class and specify the Elastic SAN name created in the step 2.

  ```yaml
  apiVersion: storage.k8s.io/v1
  kind: StorageClass
  metadata:
    name: azuresan
  provisioner: san.csi.azure.com
  reclaimPolicy: Delete
  volumeBindingMode: Immediate
  allowVolumeExpansion: true
  parameters: 
    san: <esan-name>  # replace with the name of your pre-created Elastic SAN
   ```

### 1.2.2 Create a storage class when you want to use a pre-provisioned Elastic SAN and a volume group

Step 1: Repeat the steps 1 and 2 for creating an Elastic SAN in the managed resource group.

Step 2: Now use the following steps to create a volume group.

Step 2.1: Get VNet and Subnet info, then update service endpoint.

Get the VNet information using the following command.
 
  ```azurecli
  az network vnet list -g <node resource group> --query [].name -o tsv 
  ```
Step 2.2: Get the subnet information using the below command.

  ```azurecli
  az network vnet subnet list -g <node resource group> --vnet-name <VNet name> --query [].name -o tsv  
  ```

Step 2.3: Update the service endpoint using the following command.
 
   ```azurecli
   az network vnet subnet update -g <node resource group> --vnet-name <VNet name> --name <Subnet name> --service-endpoints "Microsoft.Storage"
   ```
Step 2.4: Create a volume group.

  ```azurecli
  az elastic-san volume-group create --resource-group <node resource group> --elastic-san-name <SAN name> --name <Volume Group name> --network-acls '{"virtual-network-rules":[{"id":"<Subnet ID>","action":"Allow"}]}'
  ```
Step 3: Create the storage class and specify the elastic SAN and volume group name created in the steps above.

  ```yaml
      apiVersion: storage.k8s.io/v1
      kind: StorageClass
      metadata:
        name: azuresan
      provisioner: san.csi.azure.com
      reclaimPolicy: Delete
      volumeBindingMode: Immediate
      allowVolumeExpansion: true
      parameters: 
        san: <ESAN Name>  # replace with the name of your pre-created Elastic SAN
        volumegroup: <volume group name> # replace with the name of your pre-created volume group
   ```

## 1.3 Apply the manifest and verify the storage class creation. 

 Apply the manifest using the following command:
 
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

A persistent volume claim (PVC) is used to automatically provision storage based on a storage class. Follow these steps to create a PVC using the new storage class.

Step 1: Create a YAML manifest file such as `acstor-pvc.yaml`. Paste in the following code and save the file. The PVC `name` value can be whatever you want.

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
  storageClassName: azuresan
   ```

Step 2: Apply the YAML manifest file to create the PVC.

  ```azurecli
  kubectl apply -f acstor-pvc.yaml
  ```
   
  You should see output similar to:
   
  ```output
  persistentvolumeclaim/managedpvc created
  ```
   
You can verify the status of the PVC by running the following command:

 ```azurecli
  kubectl describe pvc managedpvc
  ```
Once the PVC is created, it's ready for use by a pod.

## 3 Deploy a pod and attach a persistent volume

Create a pod using [fio](https://github.com/axboe/fio) (Flexible I/O Tester) for benchmarking and workload simulation, and specify a mount path for the persistent volume. For **claimName**, use the **name** value that you used when creating the persistent volume claim.

Step 1:  Use your favorite text editor to create a YAML manifest file such as `code acstor-pod.yaml`. Paste in the following code and save the file.

  ```yml
apiVersion: v1 
kind: Pod 
metadata: 
  name: fiopod 
spec: 
  containers: 
    - image: nixery.dev/shell/fio 
      name: fio 
      ports: 
        - containerPort: 80 
          protocol: TCP 
      volumeMounts: 
        - mountPath: /volume 
          name: iscsi-volume 
  volumes: 
    - name: iscsi-volume 
      persistentVolumeClaim: 
        claimName: managedpvc 
     ```

Step 2: Apply the YAML manifest file to deploy the pod.
   
     ```azurecli-interactive
     kubectl apply -f acstor-pod.yaml
     ```
   
   You should see output similar to the following:
   
     ```output
     pod/fiopod created
     ```

Step 3: Check that the pod is running and that the persistent volume claim has been bound successfully to the pod:

     ```azurecli-interactive
     kubectl describe pod fiopod
     kubectl describe pvc managedpvc
     ```

Step 4: Check fio testing to see its current status:

  ```azurecli-interactive
kubectl exec -it fiopod -- fio --name=benchtest --size=800m --filename=/volume/test --direct=1 --rw=randrw --ioengine=libaio --bs=4k --iodepth=16 --numjobs=8 --time_based --runtime=60
  ```

You've now deployed a pod that's using an Elastic SAN as its storage, and you can use it for your Kubernetes workloads.

## 4 Static provisioning of Elastic SAN volume

You can fully pre‑create the volume in Elastic SAN and then surface it to Kubernetes as a static persistent volume. Refer to the steps above in pre-provisioned Elastic SAN and volume group section for creating an Elastic SAN and a volume group. These steps can also be performed in the Azure portal by using [Elastic SAN service blade](../elastic-san/elastic-san-create.md).

### 4.1 Create a default Elastic SAN storage class

Use the following YAML manifest file to create a default Elastic SAN storage class

   ```yaml
  apiVersion: storage.k8s.io/v1
  kind: StorageClass
  metadata:
    name: azuresan
  provisioner: san.csi.azure.com
  reclaimPolicy: Delete
  volumeBindingMode: Immediate
  allowVolumeExpansion: true 
    ```
Apply the manifest to create the storage class.
  
   ```azurecli
  kubectl apply -f storageclass.yaml
   ```
Verify the storage class

Run the following command to verify that the storage class is created:

  ```azurecli
  kubectl get storageclass azuresan
  ```

### 4.2 Create an Elastic SAN volume

  ```azurecli-interactive
  az elastic-san volume create -g <node resource group> -e <SAN name> -v <Volume Group name> -n <Volume name> --size-gib 5
  ```
Note the ARM ID of the Elastic SAN volume and use it for volumeHandle parameter in the persistent volume creation yaml. 

After creating an Elastic SAN and a volume group, you can statically provision a volume by creating a PersistentVolume (PV) that directly references the pre-provisioned Elastic SAN volume. Retrieve IQN (iSCSI Qualified Name) and targetPortal values for your Elastic SAN volume using the following command to use it in the persistent volume creation yaml. 

  ```azurecli-interactive
  az elastic-san volume show --name <volume-name> --resource-group <rg-name> --elastic-san-name <esan-name>
  ```

### 4.3 Create a persistent volume

Create a YAML manifest file such as 'pv_static.yaml'.

   ```yaml
  apiVersion: v1 
  kind: PersistentVolume 
  metadata: 
    annotations: 
      pv.kubernetes.io/provisioned-by: san.csi.azure.com 
    name: pv-san 
  spec: 
    capacity: 
      storage: 5Gi 
    accessModes: 
      - ReadWriteOnce 
    persistentVolumeReclaimPolicy: Retain 
    storageClassName: azuresan 
    csi: 
      driver: san.csi.azure.com 
      volumeHandle: #{rg}#{san}#{vg}#{vol} 
      volumeAttributes: 
        # iqn: "<retrieved from pre-provisioned volume>" 
        # targetPortal: "<retrieved from pre-provisioned volume>" 
       numsessions: "8"  
    ```

Apply the manifest to create the persistent volume.

   ```azurecli
  kubectl apply -f pv_static.yaml
   ```
### 4.4 Create a static persistent volume claim

Create a YAML manifest file such as'pvc_static.yaml'.

   ```yaml
  kind: PersistentVolumeClaim 
  apiVersion: v1 
  metadata: 
    name: pvc-san 
  spec: 
    volumeMode: Filesystem 
    accessModes: 
      - ReadWriteOnce 
    resources: 
      requests: 
        storage: 5Gi 
    volumeName: pv-san 
    storageClassName: azuresan
    ```

  Apply the manifest to create the persistent volume claim.

  ```azurecli
  kubectl apply -f pvc_static.yaml
   ```

 ### 4.5 Create a pod persistent volume

Create a YAML manifest file such as'pod.yaml'.

   ```yaml
  apiVersion: v1 
  kind: Pod 
  metadata: 
    name: pod-san-static 
  spec: 
    nodeSelector: 
      kubernetes.io/os: linux 
    containers: 
      - image: mcr.microsoft.com/oss/nginx/nginx:1.19.5 
        name: nginx 
        ports: 
          - containerPort: 80 
            protocol: TCP 
        volumeMounts: 
          - mountPath: /var/www 
            name: iscsi-volume 
    volumes: 
      - name: iscsi-volume 
        persistentVolumeClaim: 
          claimName: pvc-san 
    ```

Apply the manifest to create the pod.

  ```azurecli
  kubectl apply -f pod.yaml
   ```

 
## See also

- [What is Azure Elastic SAN?](../elastic-san/elastic-san-introduction.md)
