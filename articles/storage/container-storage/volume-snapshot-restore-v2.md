---
title: Use volume snapshots with Azure Container Storage (version 2.x.x)
description: Take snapshot of a persistent volume and restore it.
author: saurabh0501
ms.service: azure-container-storage
ms.topic: how-to
ms.date: 01/28/2026
ms.author: kendownie
# Customer intent: As a Kubernetes operator, I want to create and restore volume snapshots in Azure Container Storage, so that I can recover from potential data loss.
---

# Use volume snapshots with Azure Container Storage

Azure Container Storage is a cloud-based volume management, deployment, and orchestration service built natively for containers. This article shows you how to take a point-in-time snapshot of a persistent volume and restore it with a new persistent volume claim.

## Limitations
Volume snapshots aren't currently supported when you use ephemeral disk (local NVMe) as backing storage.

## Prerequisites

- This article requires the latest version of the Azure CLI. See [How to install the Azure CLI](/cli/azure/install-azure-cli). If you're using Azure Cloud Shell, the latest version is already installed. If you plan to run the commands locally instead of in Azure Cloud Shell, be sure to run them with administrative privileges.

- This article assumes you've already installed Azure Container Storage on your AKS cluster, and that you've created a persistent volume claim (PVC) using [Elastic SAN](use-container-storage-with-elastic-san-version-2.md).

## Create a volume snapshot class

First, create a volume snapshot class, which allows you to specify the attributes of the volume snapshot, by defining it in a YAML manifest file. Follow these steps to create a volume snapshot class for Elastic SAN.

1. Use your favorite text editor to create a YAML manifest file such as `code acstor-volumesnapshotclass.yaml`.

1. Paste in the following code. The volume snapshot class **name** value can be whatever you want.

   ```yml
   apiVersion: snapshot.storage.k8s.io/v1
   kind: VolumeSnapshotClass
   deletionPolicy: Delete
   metadata:
     name: elasticsan-snapshot-class
   driver: san.csi.azure.com
   ```

1. Apply the YAML manifest file to create the volume snapshot class.
   
   ```azurecli-interactive
   kubectl apply -f acstor-volumesnapshotclass.yaml
   ```
   
   When creation is complete, you'll see a message like:
   
   ```output
   volumesnapshotclass.snapshot.storage.k8s.io/elasticsan-snapshot-class created
   ```
   
   You can also run `kubectl get volumesnapshotclass` to check that the volume snapshot class has been created. You should see output such as:
   
   ```output
   NAME                        DRIVER                DELETIONPOLICY    AGE
   elasticsan-snapshot-class	 san.csi.azure.com	   Delete	           11s
   ```
   
## Create a volume snapshot

Next, you'll create a snapshot of an existing persistent volume claim and apply the volume snapshot class you created in the previous step.

1. Use your favorite text editor to create a YAML manifest file such as `code acstor-volumesnapshot.yaml`.

1. Paste in the following code. The `volumeSnapshotClassName` should be the name of the volume snapshot class that you created in the previous step. For `persistentVolumeClaimName`, use the name of the persistent volume claim that you want to take a snapshot of. The volume snapshot **name** value can be whatever you want.

   ```yml
   apiVersion: snapshot.storage.k8s.io/v1
   kind: VolumeSnapshot
   metadata:
     name: elasticsan-volume-snapshot
   spec:
     volumeSnapshotClassName: elasticsan-snapshot-class
     source:
       persistentVolumeClaimName: elasticsanpvc
   ```

1. Apply the YAML manifest file to create the volume snapshot.
   
   ```azurecli-interactive
   kubectl apply -f acstor-volumesnapshot.yaml
   ```
   
   When creation is complete, you'll see a message like:
   
   ```output
   volumesnapshot.snapshot.storage.k8s.io/elasticsan-volume-snapshot created
   ```
   
   You can also run `kubectl get volumesnapshot` to check that the volume snapshot has been created. If `READYTOUSE` indicates *true*, you can move on to the next step.

## Create a restored persistent volume claim

Now you can create a new persistent volume claim that uses the volume snapshot as a data source.

1. Use your favorite text editor to create a YAML manifest file such as `code acstor-pvc-restored.yaml`.

1. Paste in the following code. The `storageClassName` must match the storage class that you used when creating the original persistent volume. For the data source **name** value, use the name of the volume snapshot that you created in the previous step. The metadata **name** value for the persistent volume claim can be whatever you want.

   ```yml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: pvc-elasticsan-snapshot-restored
   spec:
     accessModes:
       - ReadWriteOnce
     storageClassName: azuresan
     resources:
       requests:
         storage: 100Gi
     dataSource:
       name: elasticsan-volume-snapshot
       kind: VolumeSnapshot
       apiGroup: snapshot.storage.k8s.io
   ```

1. Apply the YAML manifest file to create the PVC.
   
   ```azurecli-interactive
   kubectl apply -f acstor-pvc-restored.yaml
   ```
   
   When creation is complete, you'll see a message like:
   
   ```output
   persistentvolumeclaim/pvc-elasticsan-snapshot-restored created
   ```
   
   You can also run `kubectl describe pvc pvc-elasticsan-snapshot-restored` to check that the persistent volume has been created. You should see the status as **Pending** and the message **waiting for first consumer to be created before binding**.

> [!TIP]
> If you already created a restored persistent volume claim and want to apply the yaml file again to correct an error or make a change, you'll need to first delete the old persistent volume claim before applying the yaml file again: `kubectl delete pvc <pvc-name>`.

## Delete the original pod (optional)

Before you create a new pod, you might want to delete the original pod that you created the snapshot from.

1. Run `kubectl get pods` to list the pods. Make sure you're deleting the right pod.
1. To delete the pod, run `kubectl delete pod <pod-name>`.

## Create a new pod using the restored snapshot

Next, create a new pod using the restored persistent volume claim. Create the pod using [Fio](https://github.com/axboe/fio) (Flexible I/O Tester) for benchmarking and workload simulation, and specify a mount path for the persistent volume.

1. Use your favorite text editor to create a YAML manifest file such as `fio-pod-restore.yaml`.

1. Paste in the following code. The persistent volume claim `claimName` should be the name of the restored snapshot persistent volume claim that you created. The metadata **name** value for the pod can be whatever you want.

   ```yml
   kind: Pod
   apiVersion: v1
   metadata:
     name: fio-restore
   spec:
     volumes:
       - name: iscsi-volume
         persistentVolumeClaim:
           claimName: pvc-elasticsan-snapshot-restored
     containers:
       - name: fio
         image: nixery.dev/shell/fio
         volumeMounts:
           - mountPath: "/volume"
             name: iscsi-volume
   ```

1. Apply the YAML manifest file to deploy the pod.
   
   ```azurecli-interactive
   kubectl apply -f fio-pod-restore.yaml
   ```
   
   You should see output similar to the following:
   
   ```output
   pod/fio-restore created
   ```

1. Check that the pod is running and that the persistent volume claim has been bound successfully to the pod:

   ```azurecli-interactive
   kubectl describe pod fio-restore
   kubectl describe pvc pvc-elasticsan-snapshot-restored
   ```

1. Check fio testing to see its current status:

   ```azurecli-interactive
   kubectl exec -it fio-restore -- fio --name=benchtest --size=800m --filename=/volume/test --direct=1 --rw=randrw --ioengine=libaio --bs=4k --iodepth=16 --numjobs=8 --time_based --runtime=60
   ```

You've now deployed a new pod from the restored persistent volume claim, and you can use it for your Kubernetes workloads.

## See also

- [What is Azure Container Storage?](container-storage-introduction.md)
- [Use Azure Container Storage with local NVMe](use-container-storage-with-local-disk.md)
