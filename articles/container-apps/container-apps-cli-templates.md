---
title: Azure Developer CLI (azd) templates for Azure Container Apps
description: Find Microsoft and community-authored Azure Developer CLI (AZD) templates for Azure Container Apps
services: container-apps
author: craigshoemaker
ms.service: azure-container-apps
ms.topic: conceptual
ms.date: 03/20/2026
ms.author: cshoe
ai-usage: ai-generated
---

# Azure Developer CLI (azd) templates for Azure Container Apps

The [Azure Developer CLI (azd)](/azure/developer/azure-developer-cli/overview) streamlines the process of building, deploying, and managing applications on Azure. The following templates help you get started with [Azure Container Apps](./overview.md) across a variety of languages, frameworks, and architectural patterns.

Each template is a complete, deployable project you can initialize with a single command:

```bash
azd init -t <REPO_URL>
```

> Templates marked with **✓** after the author name are Microsoft-authored. All other templates are community-authored.

## Overview

| Category | Microsoft | Community | Total |
|----------|-----------|-----------|-------|
| [MCP servers and AI agents](#mcp-servers-and-ai-agents) | 5 | 5 | 10 |
| [AI and intelligent apps](#ai-and-intelligent-apps) | 23 | 7 | 30 |
| [Microservices (Dapr)](#microservices-dapr) | 9 | 0 | 9 |
| [Quickstarts and samples](#quickstarts-and-samples) | 13 | 0 | 13 |
| [Web Applications](#web-applications) | 5 | 13 | 18 |
| [General](#general) | 2 | 8 | 10 |
| **Total** | **57** | **33** | **90** |

## MCP servers and AI agents

Templates for building [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) servers and AI agent orchestration on Azure Container Apps.

| Template | Author | Source | Language | Azure Services | IaC |
|----------|--------|--------|----------|----------------|-----|
| .NET OpenAI MCP Agent | Justin Yoo ✓ | [Repo](https://github.com/Azure-Samples/openai-mcp-agent-dotnet) | .NET/C# | Azure AI Service, Azure OpenAI Service, Azure Log Analytics, Azure Managed Identity, Azure Application Insights, Azure Diagnostic Settings | Bicep |
| Agentic Azure Architecture Document and Diagram Generator with MCP Validation | Konstantinos Passadis | [Repo](https://github.com/passadis/ai-architect-webapp) | Python, JavaScript, Node.js | Azure AI Service, Azure OpenAI Service, Azure Cosmos DB, Azure Log Analytics, Azure Managed Identity, Azure Key Vault, Azure AI Foundry | Terraform |
| AI Travel Agents - Multi-Agent MCP Orchestration with LangChain.js, LlamaIndex.TS, and Microsoft Agent Framework | Microsoft DevRel ✓ | [Repo](https://github.com/Azure-Samples/azure-ai-travel-agents) | Node.js, JavaScript, TypeScript, Python, Java, .NET/C# | Azure AI Service, Azure AI Foundry, Azure OpenAI Service, Azure Monitor, Azure Managed Identity | Bicep |
| Azure Cosmos DB MCP Toolkit | Azure Cosmos DB | [Repo](https://github.com/AzureCosmosDB/MCPToolKit) | .NET/C# | Azure AI Foundry, Azure Cosmos DB, Azure Service Principal | Bicep |
| MCP Container TS - Model Context Protocol in TypeScript | Microsoft DevRel ✓ | [Repo](https://github.com/Azure-Samples/mcp-container-ts) | Node.js, TypeScript, JavaScript | Azure AI Service, Azure AI Foundry, Azure OpenAI Service, Azure Monitor, Azure Managed Identity | Bicep |
| MCP Server with OAuth 2.1 and On-Behalf-Of Flow | jsburckhardt | [Repo](https://github.com/jsburckhardt/mcp-obo-aca) | Python | Azure Key Vault, Azure Log Analytics, Azure Managed Identity | Bicep |
| MCP Server written in C# running in Azure Container Apps | Powergentic | [Repo](https://github.com/powergentic/azd-mcp-csharp) | .NET/C# | — | Bicep |
| MCP Server written in TypeScript running in Azure Container Apps | Powergentic | [Repo](https://github.com/powergentic/azd-mcp-ts) | Node.js, TypeScript | — | Bicep |
| Remote self-hosted Azure MCP Server with managed identity for Copilot Studio integration | Chunan Ye ✓ | [Repo](https://github.com/Azure-Samples/azmcp-copilot-studio-aca-mi) | — | Azure Managed Identity | Bicep |
| Remote self-hosted Azure MCP Server with managed identity for Microsoft Foundry integration | Anu Thomas ✓ | [Repo](https://github.com/Azure-Samples/azmcp-foundry-aca-mi) | — | Azure Managed Identity | Bicep |

## AI and intelligent apps

Templates for AI-powered applications including RAG, ChatGPT-style experiences, and intelligent agents using Azure OpenAI and other AI services.

| Template | Author | Source | Language | Azure Services | IaC |
|----------|--------|--------|----------|----------------|-----|
| .NET Redis OutputCache with Azure OpenAI | Catherine Wang | [Repo](https://github.com/CawaMS/OutputCacheOpenAI) | .NET/C# | Azure Cache for Redis, Azure OpenAI Service | — |
| Advanced multi agent application based on Autogen and Azure Open AI | Yaniv Vaknin ✓ | [Repo](https://github.com/Azure-Samples/dream-team) | Python | Azure Managed Identity, Azure OpenAI Service, Azure Key Vault, Azure Log Analytics, Azure Application Insights | Bicep |
| Agentic Voice Assistant based on Azure Container Apps, Azure OpenAI and Azure Logic Apps | Evgeny Minkevich | [Repo](https://github.com/Azure-Samples/agentic-voice-assistant) | Python | Azure Cosmos DB, Azure Application Insights, Azure Storage | Bicep |
| Azure Container Apps dynamic sessions with a custom container and Microsoft Agent Framework | Jeff Martinez ✓ | [Repo](https://github.com/Azure-Samples/dynamic-sessions-custom-container) | Python | Azure Managed Identity, Azure OpenAI Service | Bicep |
| Azure Container Apps dynamic sessions with a Python code interpreter | Jeff Martinez ✓ | [Repo](https://github.com/Azure-Samples/aca-python-code-interpreter-session) | Python | Azure Managed Identity, Azure OpenAI Service | Bicep |
| Azure OpenAI priority-based load balancer with Azure Container Apps | Andre Dewes ✓ | [Repo](https://github.com/Azure-Samples/openai-aca-lb) | .NET/C# | Azure OpenAI Service | Bicep |
| Azure OpenAI RAG with Java, LangChain4j and Quarkus | Sandra Ahlgrimm ✓ | [Repo](https://github.com/Azure-Samples/azure-openai-rag-workshop-java) | Java | Azure Managed Identity, Azure OpenAI Service, Azure Monitor | Bicep |
| Building a Multi-Agent Support Triage System with AZD and Azure AI Foundry | Dave Rendon | [Repo](https://github.com/daverendon/azd-multiagent) | — | Azure AI Service, Azure AI Foundry, Azure OpenAI Service | — |
| Chat + Vision using Azure OpenAI | Azure Content Team ✓ | [Repo](https://github.com/Azure-Samples/openai-chat-vision-quickstart) | Python | Azure Managed Identity, Azure AI Service | — |
| ChatGPT + Enterprise Data with Azure OpenAI and AI Search | Azure Content Team ✓ | [Repo](https://github.com/Azure-Samples/azure-search-openai-demo-csharp) | .NET/C# | Azure Kubernetes Service, Azure AI Search, Azure OpenAI Service, Azure Cache for Redis | Bicep |
| Containerized A2A Translation Service with Azure AI Translator | Konstantinos Passadis | [Repo](https://github.com/passadis/azure-a2a-translation) | Python, JavaScript | Azure AI Foundry, Azure OpenAI Service, Azure AI Service, Azure Storage, Azure Blob Storage, Azure Log Analytics, Azure Managed Identity | Terraform |
| Copilot SDK Service — Chat API with React UI on Azure Container Apps | Jon Gallant ✓ | [Repo](https://github.com/Azure-Samples/copilot-sdk-service) | TypeScript, JavaScript, Node.js | Azure Key Vault, Azure Monitor, Azure OpenAI Service | Bicep |
| Deploy Phoenix to Azure | Arize AI Team | [Repo](https://github.com/Arize-ai/phoenix-on-azure) | Python | — | Bicep |
| Getting Started with AI Agents Using Azure AI Foundry | Azure Content Team ✓ | [Repo](https://github.com/Azure-Samples/get-started-with-ai-agents) | Python | Azure AI Foundry, Azure AI Search, Azure Application Insights, Azure Blob Storage | Bicep |
| Java - ChatGPT + Enterprise data with Azure OpenAI and AI Search | Davide Antelmo ✓ | [Repo](https://github.com/Azure-Samples/azure-search-openai-demo-java) | Java | Azure OpenAI Service, Azure App Service, Azure AI Search | Bicep |
| Java Spring Apps with Azure OpenAI | Pierre Malarme ✓ | [Repo](https://github.com/Azure-Samples/app-templates-java-openai-springapps) | Java | Azure OpenAI Service, Azure Spring Apps, Azure PostgreSQL, Azure Monitor | Bicep |
| LiteLLM in Azure Container Apps with PostgreSQL database | Build5Nines | [Repo](https://github.com/Build5Nines/azd-litellm) | Python | Azure OpenAI Service, Azure PostgreSQL | Bicep |
| LlamaIndex RAG chat app with Azure OpenAI and Azure AI Search (JavaScript) | Wassim Chegham ✓ | [Repo](https://github.com/Azure-Samples/llama-index-vector-search-javascript) | JavaScript, TypeScript, Node.js | Azure AI Service, Azure Managed Identity, Azure OpenAI Service | Bicep |
| Pinecone RAG Demo | Pinecone Team | [Repo](https://github.com/pinecone-io/pinecone-rag-demo-azd) | TypeScript | — | Bicep |
| Process Automation: Speech to Text and Summarization with AI Studio | Azure Content Team ✓ | [Repo](https://github.com/Azure-Samples/summarization-openai-python-promptflow) | Python | Azure OpenAI Service, Azure Speech Services | Bicep |
| RAG on PostgreSQL | Azure Content Team ✓ | [Repo](https://github.com/Azure-Samples/rag-postgres-openai-python) | Python | Azure OpenAI Service, Azure PostgreSQL | Bicep |
| RAG using Kernel Memory on Azure | Kernel Memory Team ✓ | [Repo](https://github.com/microsoft/kernel-memory) | .NET/C# | Azure OpenAI Service, Azure AI Search, Azure AI Service, Azure Managed Identity, Azure Blob Storage, Azure Application Gateway, Azure Storage, Azure Application Insights, Azure Virtual Networks | Bicep |
| Semantic image search | Azure Content Team ✓ | [Repo](https://github.com/Azure-Samples/image-search-aisearch) | Python, TypeScript, Node.js | Azure OpenAI Service, Azure AI Search, Azure Blob Storage | Bicep |
| Serverless Azure OpenAI Quick Start with LlamaIndex (JavaScript) | Wassim Chegham ✓ | [Repo](https://github.com/Azure-Samples/llama-index-javascript) | JavaScript, Node.js | Azure OpenAI Service | Bicep |
| Serverless Azure OpenAI Quick Start with LlamaIndex (Python) | Marlene Mhangami ✓ | [Repo](https://github.com/Azure-Samples/llama-index-python) | Python | Azure OpenAI Service, Azure Managed Identity | Bicep |
| Simple Chat Application using Azure OpenAI | Azure Content Team ✓ | [Repo](https://github.com/Azure-Samples/chatgpt-quickstart) | Python | Azure OpenAI Service | Bicep |
| Simple Chat Application using Azure OpenAI (Python) | Azure Content Team ✓ | [Repo](https://github.com/Azure-Samples/openai-chat-app-quickstart) | Python | Azure OpenAI Service | Bicep |
| Spring Petclinic Microservices with AI on Azure Container Apps | Songbo Wang ✓ | [Repo](https://github.com/Azure-Samples/java-on-aca) | Java | Azure MySQL, Azure Monitor, Azure Managed Identity, Azure Key Vault, Azure Application Insights, Azure OpenAI Service | Bicep |
| Sprint Petclinic AI application on Azure Container Apps | Songbo Wang ✓ | [Repo](https://github.com/Azure-Samples/spring-petclinic-ai) | Java | Azure Managed Identity, Azure OpenAI Service | Bicep |
| VoiceRAG: RAG + Voice Using Azure AI Search and GPT-4o Realtime API | Azure Content Team ✓ | [Repo](https://github.com/Azure-Samples/aisearch-openai-rag-audio) | Python, TypeScript, JavaScript | Azure OpenAI Service, Azure AI Search | Bicep |

## Microservices (Dapr)

Templates demonstrating microservice patterns with [Dapr](https://dapr.io/) on Azure Container Apps, including pub/sub, service invocation, and bindings.

| Template | Author | Source | Language | Azure Services | IaC |
|----------|--------|--------|----------|----------------|-----|
| Microservices App - Dapr Bindings Cron C# ACA PostgreSQL | Azure Content Team ✓ | [Repo](https://github.com/Azure-Samples/bindings-dapr-csharp-cron-postgres) | .NET/C# | Azure PostgreSQL | — |
| Microservices App - Dapr Bindings Cron Node.js ACA PostgreSQL | Azure Content Team ✓ | [Repo](https://github.com/Azure-Samples/bindings-dapr-nodejs-cron-postgres) | Node.js, JavaScript | Azure PostgreSQL | — |
| Microservices App - Dapr Bindings Cron Python ACA PostgreSQL | Azure Content Team ✓ | [Repo](https://github.com/Azure-Samples/bindings-dapr-python-cron-postgres) | Python | Azure PostgreSQL | — |
| Microservices App - Dapr PubSub C# ACA ServiceBus | Azure Content Team ✓ | [Repo](https://github.com/Azure-Samples/pubsub-dapr-csharp-servicebus) | .NET/C# | Azure Service Bus | Bicep |
| Microservices App - Dapr PubSub Node.js ACA ServiceBus | Azure Content Team ✓ | [Repo](https://github.com/Azure-Samples/pubsub-dapr-nodejs-servicebus) | JavaScript, Node.js | Azure Service Bus | Bicep |
| Microservices App - Dapr PubSub Python ACA ServiceBus | Azure Content Team ✓ | [Repo](https://github.com/Azure-Samples/pubsub-dapr-python-servicebus) | Python | Azure Service Bus | Bicep |
| Microservices App - Dapr Service Invoke C# ACA | Azure Content Team ✓ | [Repo](https://github.com/Azure-Samples/svc-invoke-dapr-csharp) | .NET/C# | — | — |
| Microservices App - Dapr Service Invoke Node.js ACA | Azure Content Team ✓ | [Repo](https://github.com/Azure-Samples/svc-invoke-dapr-nodejs) | Node.js | — | — |
| Microservices App - Dapr Service Invoke Python ACA | Azure Content Team ✓ | [Repo](https://github.com/Azure-Samples/svc-invoke-dapr-python) | Python | — | — |

## Quickstarts and samples

Starter templates and quickstart samples to help you get up and running with Azure Container Apps.

| Template | Author | Source | Language | Azure Services | IaC |
|----------|--------|--------|----------|----------------|-----|
| Azure Cosmos DB for NoSQL Quickstart - .NET | Azure Cosmos DB Content Team ✓ | [Repo](https://github.com/azure-samples/cosmos-db-nosql-dotnet-quickstart) | .NET/C# | Azure Cosmos DB, Azure Managed Identity | Bicep |
| Azure Cosmos DB for NoSQL Quickstart - Go | Azure Cosmos DB Content Team ✓ | [Repo](https://github.com/azure-samples/cosmos-db-nosql-go-quickstart) | Go | Azure Cosmos DB, Azure Managed Identity | Bicep |
| Azure Cosmos DB for NoSQL Quickstart - Java | Azure Cosmos DB Content Team ✓ | [Repo](https://github.com/azure-samples/cosmos-db-nosql-java-quickstart) | Java | Azure Cosmos DB, Azure Managed Identity | Bicep |
| Azure Cosmos DB for NoSQL Quickstart - Node.js | Azure Cosmos DB Content Team ✓ | [Repo](https://github.com/azure-samples/cosmos-db-nosql-nodejs-quickstart) | Node.js | Azure Cosmos DB, Azure Managed Identity | Bicep |
| Azure Cosmos DB for NoSQL Quickstart - Python | Azure Cosmos DB Content Team ✓ | [Repo](https://github.com/azure-samples/cosmos-db-nosql-python-quickstart) | Python | Azure Cosmos DB, Azure Managed Identity | Bicep |
| Azure Cosmos DB for Table Quickstart - .NET | Azure Cosmos DB Content Team ✓ | [Repo](https://github.com/azure-samples/cosmos-db-table-dotnet-quickstart) | .NET/C# | Azure Cosmos DB, Azure Managed Identity | Bicep |
| Azure Cosmos DB for Table Quickstart - Go | Azure Cosmos DB Content Team ✓ | [Repo](https://github.com/azure-samples/cosmos-db-table-go-quickstart) | Go | Azure Cosmos DB, Azure Managed Identity | Bicep |
| Azure Cosmos DB for Table Quickstart - Java | Azure Cosmos DB Content Team ✓ | [Repo](https://github.com/azure-samples/cosmos-db-table-java-quickstart) | Java | Azure Cosmos DB, Azure Managed Identity | Bicep |
| Azure Cosmos DB for Table Quickstart - Node.js | Azure Cosmos DB Content Team ✓ | [Repo](https://github.com/azure-samples/cosmos-db-table-nodejs-quickstart) | Node.js | Azure Cosmos DB, Azure Managed Identity | Bicep |
| Azure Cosmos DB for Table Quickstart - Python | Azure Cosmos DB Content Team ✓ | [Repo](https://github.com/azure-samples/cosmos-db-table-python-quickstart) | Python | Azure Cosmos DB, Azure Managed Identity | Bicep |
| Data API builder Quickstart - Azure Cosmos DB for NoSQL | Azure Cosmos DB Content Team ✓ | [Repo](https://github.com/azure-samples/dab-azure-cosmos-db-nosql-quickstart) | .NET/C# | Azure Cosmos DB, Azure Managed Identity | Bicep |
| Data API builder Quickstart - Azure SQL | Azure SQL Content Team ✓ | [Repo](https://github.com/azure-samples/dab-azure-sql-quickstart) | .NET/C# | Azure SQL, Azure Managed Identity | Bicep |
| Hello AZD | Azure Content Team ✓ | [Repo](https://github.com/Azure-Samples/hello-azd) | .NET/C# | Azure Blob Storage, Azure Cosmos DB, Azure Managed Identity | Bicep |

## Web Applications

Full-stack and server-side web application templates running on Azure Container Apps.

| Template | Author | Source | Language | Azure Services | IaC |
|----------|--------|--------|----------|----------------|-----|
| Aspire with Key Vault + App Config + Service Bus/RabbitMQ | Fabio Marini | [Repo](https://github.com/fabio-marini/azd-aspire-basic) | .NET/C# | Azure Key Vault, Azure App Configuration, Azure Service Bus, Azure Service Principal, Azure Log Analytics, Azure Managed Identity | Bicep |
| Containerized React Web App with Java API and MongoDB | Azure Dev ✓ | [Repo](https://github.com/Azure-Samples/todo-java-mongo-aca) | Java, TypeScript | Azure Cosmos DB, Azure Key Vault, Azure Monitor | Bicep |
| Containerized React Web App with Node.js API and MongoDB | Azure Dev ✓ | [Repo](https://github.com/Azure-Samples/todo-nodejs-mongo-aca) | Node.js, TypeScript, JavaScript | Azure App Service, Azure Cosmos DB, Azure Monitor, Azure Key Vault | Bicep |
| Containerized React Web App with Python API and MongoDB | Azure Dev ✓ | [Repo](https://github.com/Azure-Samples/todo-python-mongo-aca) | Python, TypeScript, JavaScript | Azure Cosmos DB, Azure Monitor, Azure Key Vault | Bicep |
| FastAPI Membership API Template for Azure Container Apps | Mark Anthony Estopace | [Repo](https://github.com/EstopaceMA/fastapi-postgres-aca) | Python | Azure PostgreSQL, Azure Key Vault, Azure Virtual Networks | Terraform |
| FastAPI on Azure Container Apps | Pamela Fox | [Repo](https://github.com/pamelafox/simple-fastapi-container) | Python | — | Bicep |
| Flask API on Azure Container Apps | Pamela Fox | [Repo](https://github.com/pamelafox/simple-flask-api-container) | Python | — | Bicep |
| Flask Chart API on ACA and CDN | Pamela Fox | [Repo](https://github.com/pamelafox/flask-charts-api-container-app) | Python | Azure CDN | — |
| Flask Container with CDN | Pamela Fox | [Repo](https://github.com/pamelafox/flask-gallery-container-app) | Python | Azure CDN | — |
| Flask Surveys Container App | Pamela Fox | [Repo](https://github.com/pamelafox/flask-surveys-container-app) | Python | Azure Key Vault, Azure PostgreSQL | — |
| Intelligent App on Azure Container Apps and GitHub Models | Hao Xu | [Repo](https://github.com/xuhaoruins/marketingwriter) | Python | — | Bicep |
| Java Quarkus Apps on Azure Container Apps | Jianguo Ma ✓ | [Repo](https://github.com/Azure-Samples/java-on-aca-quarkus) | Java | Azure PostgreSQL, Azure MySQL, Azure Monitor, Azure Managed Identity | Bicep |
| Jupyter Notebooks Web App on Azure Container Apps | Savannah Ostrowski | [Repo](https://github.com/savannahostrowski/jupyter-mercury-aca) | Python | — | Bicep |
| Next.js on Container Apps | Chris Meagher | [Repo](https://github.com/CMeeg/nextjs-aca) | TypeScript, Node.js | Azure CDN, Azure Application Insights | Bicep |
| Python (Django) Web App with PostgreSQL via Azure Container Apps | Azure Content Team ✓ | [Repo](https://github.com/Azure-Samples/azure-django-postgres-aca) | Python | Azure PostgreSQL | Bicep |
| Quarkus Todo API Template for Azure Container Apps | Mark Anthony Estopace | [Repo](https://github.com/EstopaceMA/quarkus-postgres-aca) | Java | Azure PostgreSQL | Terraform |
| Remix on Container Apps | Chris Meagher | [Repo](https://github.com/CMeeg/remix-aca) | TypeScript, Node.js | Azure CDN, Azure Application Insights | Bicep |
| Sample Ruby on Rails app deployed (Bicep) on Azure Container App with PostgreSQL | Dominique Broeglin | [Repo](https://github.com/dbroeglin/azure-rails-starter) | Ruby | Azure PostgreSQL, Azure Monitor | Bicep |

## General

Additional Azure Container Apps templates covering infrastructure, DevOps, and other patterns.

| Template | Author | Source | Language | Azure Services | IaC |
|----------|--------|--------|----------|----------------|-----|
| .NET Aspire Azure Storage Demo | Frank Boucher | [Repo](https://github.com/FBoucher/AspireAzStorage) | .NET/C# | — | Bicep |
| Deploy DeepSeek-R1 on Azure Container Apps with Serverless GPUs. | Dave Rendon | [Repo](https://github.com/daverendon/azd-deepseek-r1-on-azure-container-apps) | — | Azure Log Analytics | — |
| Deploy Label Studio directly from Docker Hub on Azure Container Apps | Bill DeRusha | [Repo](https://github.com/bderusha/azd-label-studio) | — | Azure Blob Storage, Azure Application Insights, Azure Log Analytics, Azure Managed Identity | Bicep |
| Docusaurus with Azure Container Apps | Juan Burckhardt | [Repo](https://github.com/jsburckhardt/docusaurus-aca) | JavaScript | — | Bicep |
| Emulated Firewall sending Syslog to linux VM | Koenraad Haedens | [Repo](https://github.com/koenraadhaedens/azd-firewall-send-syslog-messages) | — | Azure Sentinel | — |
| EShopOnWeb ACAPPS Architecture | Maarten van Diemen | [Repo](https://github.com/maartenvandiemen/AZD-ACA-Demo) | — | Azure Managed Identity | — |
| Real time game leaderboard with Azure Container Apps and Redis Cache | Catherine Wang | [Repo](https://github.com/CawaMS/GameLeaderboard) | .NET/C# | Azure Cache for Redis | — |
| Rock, Paper, Orleans (RPO) - Distributed .NET | Brady Gaster | [Repo](https://github.com/bradygaster/RockPaperOrleans) | .NET/C# | Azure Cosmos DB | Bicep |
| URL Shortener using Microsoft Orleans and Azure for hosting and data | Azure Cosmos DB Content Team ✓ | [Repo](https://github.com/azure-samples/orleans-url-shortener) | .NET/C# | Azure Cosmos DB | Bicep |
| WordPress with Azure Container Apps | Konstantinos Pantos ✓ | [Repo](https://github.com/Azure-Samples/apptemplate-wordpress-on-ACA) | PHP, JavaScript | Azure Application Gateway, Azure Cache for Redis, Azure Monitor, Azure Key Vault | Bicep |
