---
title: Manage Local CSI driver placement
description: Configure node affinity in local NVMe storage class to manage local CSI driver placement.
author: fhryo-msft
ms.service: azure-container-storage
ms.topic: how-to
ms.date: 2/5/2025
ms.author: fryu
ms.custom: references_regions
## Customer Intent: As a Kubernetes administrator, I want to configure Azure Container Storage to use local NVMe for ephemeral volumes. Additionally, I want to ensure that these volumes are utilized only on nodes specifically designed to process data with local high-performance storage.
---

# Manage Local CSI driver placement with node affinity

In Kubernetes clusters, CSI drivers are typically deployed as DaemonSets, running on all nodes by default. However, in production environments, certain nodes may be equipped with specialized hardware (such as local NVMe disks), specific instance types, or designated roles that make them more suitable for particular storage workloads.

By configuring node affinity in local NVMe storage class, you can control the placement of Local CSI drivers to ensure they run only on nodes that meet the designed conditions. This approach helps optimize resource utilization and minimizes the impact on other nodes in the cluster.

## When to consider managing local CSI driver placement

Managing the placement of Local CSI drivers is essential in the following scenarios:

- Scenario 1: Mixed node pools with different capabilities. Clusters often contain multiple node pools with different instance types. Without node affinity, Local CSI driver pods may be scheduled onto nodes that don't have local NVMe disks and cannot successfully service storage requests.

- Scenario 2: Mixed node pools for distinct workloads. In large clusters, it is common to have multiple node pools, each tailored for specific types of workloads. Without node affinity, Local CSI driver pods might be scheduled onto node pools where local NVMe disks are not intended to be used, even if they are configured.

## Node affinity via StorageClass annotations

The Local CSI driver placement mechanism uses:

- Kubernetes (nodeAffinity)[https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity]. Note that **preferredDuringSchedulingIgnoredDuringExecution** is not supported.
- Storage class annotations to express placement requirements
- Only creation or modification of storage classes triggers nodeAffinity recomputation

You can define a nodeAffinity rule for a local NVMe StorageClass using the **storageoperator.acstor.io/nodeAffinity** annotation. These rules ensure that local CSI driver pods are scheduled only on nodes that meet the specified criteria. If no nodeAffinity rule is defined, the local CSI driver pods will be deployed across all nodes in the cluster by default.

## Ensure local CSI drivers are placed on nodes with local NVMe disks

To ensure that local CSI drivers are deployed only on nodes equipped with local NVMe disks, you can configure node affinity based on instance type. Below is an example of a StorageClass configuration:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-nvme
  annotations:
    storageoperator.acstor.io/nodeAffinity: |
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: node.kubernetes.io/instance-type
            operator: In
            values: [standard_l8s_v3, Standard_L16s_v3]
provisioner: localdisk.csi.acstor.io
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
EOF
```

> **Note**: Match expressions are case-sensitive. It is recommended to verify the actual instance type values on your nodes before configuring node affinity. You can use the following command to validate:

```bash
$ kubectl get nodes -o custom-columns="NAME:.metadata.name,INSTANCE-TYPE:.metadata.labels.node\.kubernetes\.io/instance-type"
NAME                            INSTANCE-TYPE
aks-mycpu-32605643-vmss000000   Standard_D4ds_v5
aks-mygpu-23116656-vmss000000   standard_l8s_v3
aks-mygpu2-37383660-vmss000000  Standard_L16s_v3
```

## Ensure local CSI drivers are placed in specific node pools

You can ensure that local CSI drivers are deployed only in selected node pools by configuring node affinity based on the `agentpool` label. Below is an example of a StorageClass configuration:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-nvme
  annotations:
    storageoperator.acstor.io/nodeAffinity: |
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.azure.com/agentpool
            operator: In
            values: [mygpu,mygpu2]
provisioner: localdisk.csi.acstor.io
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
EOF
```

> **Note**: Match expressions are case-sensitive. It is recommended to verify the actual node pool names on your nodes before configuring node affinity. You can use the following command to validate:

```bash
$ kubectl get nodes -o custom-columns="NAME:.metadata.name,AGENTPOOL:.metadata.labels.kubernetes\.azure\.com/agentpool"
NAME                            AGENTPOOL
aks-mycpu-32605643-vmss000000   mycpu
aks-mygpu-23116656-vmss000000   mygpu
aks-mygpu2-37383660-vmss000000  mygpu2
```

## Best Practices

- Always label nodes explicitly before using node affinity.
- Keep StorageClasses consistent and avoid mixing annotated and non‑annotated classes unless intentional.
- Use multiple nodeSelectorTerms to express OR‑style placement.
- Validate node labels before deploying StorageClasses.
- Learn more capabilities in (Kubernetes nodeAffinity)[https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/].

## See also

- [What is Azure Container Storage?](./container-storage-introduction)
- [Install Azure Container Storage with AKS](./install-container-storage-aks)
- [Use Azure Container Storage with local NVMe](./use-container-storage-with-local-disk)
- [Best practices for ephemeral NVMe data disks in Azure Kubernetes Service (AKS)](/azure/aks/best-practices-storage-nvme)
