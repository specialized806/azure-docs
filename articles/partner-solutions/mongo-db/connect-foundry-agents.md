---
title: Connect Microsoft Foundry Agents to MongoDB Atlas
description: Learn how to connect Microsoft Foundry Agents to MongoDB Atlas
ms.topic: how-to
ms.date: 03/20/20256
---

# Connect Microsoft Foundry Agents to MongoDB Atlas

This article shows how to connect Microsoft Foundry agents that can query and retrieve data from MongoDB Atlas using the MongoDB MCP Server.

## Pre-requistes

Before you begin, ensure you have:

- An Azure subscription with access to Microsoft Foundry Project
- A MongoDB Atlas account with a project and cluster
- A vector index created in MongoDB Atlas (for RAG scenarios)
- Permission to deploy services to Azure (for MCP Server hosting)

## Pre-requisites for RAG

In retrieval-augmented generation (RAG) scenarios, Foundry agents often need to generate embeddings for user queries at runtime before invoking MongoDB Atlas Vector Search. This integration supports that pattern by exposing an embedding generation function as an OpenAPI (Swagger)–based tool that the agent can call during reasoning.

- Define the embedding function like below

```yaml
openapi: 3.0.1
info:
  title: Embedding Service API
  version: "1.0"
paths:
  /embeddings:
    post:
      summary: Generate embeddings for input text
      operationId: generateEmbeddings
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                input:
                  type: string
                  description: Text to embed
      responses:
        '200':
          description: Embedding vector
          content:
            application/json:
              schema:
                type: object
                properties:
                  embedding:
                    type: array
                    items:
                      type: number
```
The implementation behind this API typically calls a Foundry-hosted embedding model (for example, text-embedding-3-large) and returns the vector as JSON.

## Connect Microsoft Foundry agents to MongoDB Atlas

### Step 1: Prepare MongoDB Atlas

- Create or select a MongoDB Atlas cluster.
- Load your dataset (for example, sample Airbnb or domain-specific data).
- Create a vector search index on the target collection.

Microsoft Foundry connects to Atlas data in-place. The data remains in MongoDB Atlas, and Foundry agents retrieve it at query time. 

### Step 2: Deploy the MongoDB MCP Server

The [MongoDB MCP Server](https://github.com/mongodb-js/mongodb-mcp-server) acts as a bridge between Foundry agents and MongoDB Atlas.

- Deploy the MCP Server to Azure Container Apps or another Azure-hosted environment. For details on hosting, [visit] (https://github.com/mongodb-js/mongodb-mcp-server/blob/main/deploy/azure/README.md)
- Configure it with:MongoDB Atlas connection details
- Enabled tools (vector search, aggregation)
- Expose a remote HTTPS endpoint

### Step 3: Create an Agent in Microsoft Foundry

- Open the Microsoft Foundry portal
- Create a new agent and provide system instructions and choose a deployed Foundry model
- Go to Tools > MongoDB MCP Server > Connect
- Paste the MCP Server remote URL
- Save the agent configuration

Once added, the agent can invoke MongoDB operations through the MCP tool during reasoning.

### Step 4: Configure Agent for vector search

With the previous steps, users can perform database operations but cannot perform vector search since it requires embedding the user queries.
To configure the agent for vector search, follow these steps -

- In the Agent tools, add a new OpenAPI tool
- Paste the Swagger definition generated in Pre-requistes
- In the agent instructions, guide the agent to invoke this function in case of a vector search use-case.
- Save the agent

Once registered, the agent can invoke generateEmbeddings as part of its reasoning chain.

### Step 5: Test retrieval and responses

Run prompts that require:
- Semantic search over MongoDB data
- Aggregation queries
- Context-aware responses grounded in Atlas data

Successful responses confirm end-to-end connectivity between Foundry, MCP Server, and MongoDB Atlas.

## Architecture overview

At a high level, the integration includes:

- Microsoft Foundry Agent – Orchestrates reasoning and tool usage
- MongoDB MCP Server – Exposes MongoDB Atlas operations (vector search, aggregation) as an agent tool
- MongoDB Atlas – Stores operational and vectorized data
- Azure hosting – Hosts the MCP server in Azure Container App

For broader Foundry concepts, see the official Foundry documentation.
