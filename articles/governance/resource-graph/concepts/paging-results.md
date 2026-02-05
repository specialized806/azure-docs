# Paging results

When it's necessary to break a result set into smaller sets of records for processing or because a result set would exceed the maximum allowed value of _1000_ returned records, use paging. The [REST API](/rest/api/azureresourcegraph/resourcegraph(2021-03-01)/resources/resources) `QueryResponse` provides values that indicate a results set was broken up: `resultTruncated` and `$skipToken`. `resultTruncated` is a Boolean value that informs the consumer if there are more records not returned in the response. This condition can also be identified when the `count` property is less than the `totalRecords` property. `totalRecords` defines how many records that match the query.

`resultTruncated` is `true` when there are less resources available than a query is requesting or when paging is disabled or when paging isn't possible because:

- The query contains a `limit` or `sample`/`take` operator.
- All output columns are either `dynamic` or `null` type.

When `resultTruncated` is `true`, the `$skipToken` property isn't set.

The following examples show how to skip the first 3,000 records and return the `first` 1,000 records after those records skipped with Azure CLI and Azure PowerShell:

```azurecli
az graph query -q "Resources | project id, name | order by id asc" --first 1000 --skip 3000
```

```azurepowershell
Search-AzGraph -Query "Resources | project id, name | order by id asc" -First 1000 -Skip 3000
```

> [!IMPORTANT]
> The response won't include the `$skipToken` if:
> - The query contains a `limit` or `sample`/`take` operator.
> - All output columns are either `dynamic` or `null` type.

For an example, go to [Next page query](/rest/api/azureresourcegraph/resourcegraph(2021-03-01)/resources/resources#next-page-query) in the REST API docs.

## Pagination limitations

Azure Resource Graph provides powerful capabilities for querying resources across your Azure environment. When working with large result sets that require pagination, understanding how pagination behaves in different scenarios helps you retrieve consistent and complete results. 

This article explains pagination considerations and provides strategies for scenarios where you might observe duplicate or missing records in your paginated results. 

### Client-side strategies for dynamic environments

If your scenario requires a more consistent retrieval of resources, consider one of the following approaches. These strategies partition your data in a way that's resilient to changes and can also improve performance through parallel execution. 

Note: These client-side strategies move the pagination logic to your application, which helps avoid skip-token limitations. However, they don't guarantee complete consistency across calls. Resources might be added or deleted between your initial query (for counting or retrieving IDs) and subsequent data fetches. This can result in discrepancies such as a mismatch between expected count and total resources fetched, or missing results if a resource was deleted during the operation. For scenarios requiring strict consistency, consider whether point-in-time accuracy is critical for your use case. 

#### Option 1: Hash-based data partitioning 

This approach partitions your data using a hash function to ensure consistent and non-overlapping results across multiple queries. Each resource belongs to exactly one partition based on its unique identifier. 

##### Step 1: Get the total record count

First, determine how many records match your query: 

Resources 
| where type =~ 'microsoft.compute/virtualmachines' 
| count 
  

Use the count to determine the number of partitions needed. For example, if your count returns 7,712 records and since ARG size limit dictates that each partition can contain at most 1000 records, you would need at least 8 partitions. 

##### Step 2: Query each position

Use the hash() function to partition data based on the resource ID. Query each partition separately: 

// Partition 0 
Resources 
| where type =~ 'microsoft.compute/virtualmachines' 
| where hash(tolower(id)) % 8 == 0 
  

// Partition 1 
Resources 
| where type =~ 'microsoft.compute/virtualmachines' 
| where hash(tolower(id)) % 8 == 1 
  

Continue for each partition through partition 7: 

// Partition 7 
Resources 
| where type =~ 'microsoft.compute/virtualmachines' 
| where hash(tolower(id)) % 8 == 7

###### Pseudo code

// Step 1: Get total count and calculate partitions 

totalCount = executeQuery("Resources | where type =~ 'microsoft.compute/virtualmachines' | count") 

numPartitions = ceiling(totalCount / 1000) 

  

// Step 2: Build queries for each partition 

queries = [] 

for i = 0 to numPartitions - 1: 

    queries.append("Resources 

                    | where type =~ 'microsoft.compute/virtualmachines' 

                    | where hash(tolower(id)) % {numPartitions} == {i}") 

  

// Step 3: Execute all queries in parallel and combine results 

allResults = executeInParallel(queries) 

##### Benefits

- **No duplicates or missed records:** Each resource ID hashes to exactly one partition. 
- **Parallel execution:** All partition queries can run simultaneously, reducing total query time. 

#### Option 2: Batch processing with resource IDs

This approach retrieves all resource IDs first, then queries for complete records in smaller batches. This ensures you have a consistent set of identifiers before retrieving the full resource data. 

##### Step 1: Retrieve all resource IDs

Use summarize with make_set() to retrieve all resource IDs: 

Resources 
| where type =~ 'microsoft.compute/virtualmachines' 
| summarize make_set(id)

##### Step 2: Query in batches

Once you have the list of resource IDs, query for full records in batches of 1,000 or fewer: 

// Batch 1 
Resources 
| where type =~ 'microsoft.compute/virtualmachines' 
| where id in~ ('id1', 'id2', ... , 'id1000') 
// Batch 2 
Resources 
| where type =~ 'microsoft.compute/virtualmachines' 
| where id in~ ('id1001', 'id1002', ... , 'id2000') 
  

Continue until all IDs are covered. 

##### Benefits

- **Guaranteed completeness:** You have a fixed set of IDs before querying for details. 
- **Parallel execution:** Batch queries can run simultaneously.

> [!NOTE]
> If the response of the below query is huge (> 16MB) and doesn’t fit in a single call, it is suggested to use the previously mentioned partitioning technique to fetch all the data in multiple calls. 

> Might exceed response size limit of 16MB 
>
> Resources 
> | where type =~ 'microsoft.compute/virtualmachines' 
> | summarize make_set(id) 
>
> Use partioning in that case
>
> Partition 0
> Resources 
> | where type =~ 'microsoft.compute/virtualmachines' 
> | where hash(tolower(id))%10 == 0 
> | summarize make_set(id) 
>
> partition 1 
>
> Resources 
> | where type =~ 'microsoft.compute/virtualmachines' 
> | where hash(tolower(id))%10 == 1 
> | summarize make_set(id) 
>
> Partition 9 
>
> Resources 
> | where type =~ 'microsoft.compute/virtualmachines' 
> | where hash(tolower(id))%10 == 9 
> | summarize make_set(id) 

### Scenario 1: Sorting by non-unique columns

When paginating results sorted by a non-unique column, you might encounter duplicate or missing records even in static environments where resources aren't changing. This occurs because records with identical sort values have no guaranteed order, and their positions can shift between pagination calls. 

> [!NOTE]
> When using `skip or first`, it's recommended to order results by at least one column with asc or `desc`. Without sorting, results are random and not repeatable. 

#### Why this happens:

Consider a query that retrieves virtual machines sorted by location: 

Resources 
| where type =~ 'microsoft.compute/virtualmachines' 
| order by location asc 
| project name, location, resourceGroup 
  

If multiple VMs share the same location value (for example, eastus), their relative order isn't deterministic. When paginating: 

**Page 1 request:** Retrieve the first 5 virtual machines. 

| Position | Name| Location|
|----|-----|-----|
|1|vm-web-01 | eastus|
|2|vm-db-01 | eastus |
|3|vm-app-01 | eastus |
|4| vm-cache-01 | eastus | 
|5| vm-api-01 | eastus | 

**Page 2 request:** Skip 5 records and retrieve the next 5.

Because all these VMs have the same location value (eastus), the query engine has no deterministic way to order them. On the second call, the engine might return: 

| Position | Name| Location|
|----|-----|-----|
|1|vm-app-01 | eastus|
|2|vm-queue-01 | eastus |
|3|vm-monitor-01 | westus |
|4| vm-backup-01 | westus | 
|5| vm-test-01 | westus | 

Notice that *vm-app-01* appears in both pages (duplicate). Due to the same reordering when there is lack of sorting , a record for e.g *vm-db-01* might never appear in any subsequent page (missing). 

### Summary

From this article you were able to learn:

- How sorting by non-unique columns can cause duplicate or missing records during pagination 
- How dynamic environments with changing resources can affect paginated results 
- Client-side strategies including hash-based partitioning and batch processing with resource IDs 