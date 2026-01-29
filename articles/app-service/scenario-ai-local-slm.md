---
title: Use local small language models (SLMs) in Azure App Service
description: Deploy a web app with a local small language model (SLM) as a sidecar container to run AI models entirely within your App Service environment. No outbound calls or external AI service dependencies required.
author: cephalin
ms.author: cephalin
ms.service: azure-app-service
ms.topic: how-to
ms.date: 01/29/2026
ms.custom:
  - build-2025
ms.collection: ce-skilling-ai-copilot
ms.update-cycle: 180-days
---

# Use a local SLM (sidecar container)

Deploy a web app with a local small language model (SLM) as a sidecar container to run AI models entirely within your App Service environment. No outbound calls or external AI service dependencies required. This approach is ideal if you have strict data privacy or compliance requirements, as all AI processing and data remain local to your app. App Service offers high-performance, memory-optimized pricing tiers needed for running SLMs in sidecars.

## [.NET](#tab/dotnet)
- [Run a chatbot with a local SLM sidecar extension](tutorial-ai-slm-dotnet.md)

## [Java](#tab/java)
- [Run a chatbot with a local SLM (Spring Boot)](tutorial-ai-slm-spring-boot.md)

## [Node.js](#tab/nodejs)
- [Run a chatbot with a local SLM (Express.js)](tutorial-ai-slm-expressjs.md)

## [Python](#tab/python)
- [Run a chatbot with a local SLM (FastAPI)](tutorial-ai-slm-fastapi.md)
-----

## Related content

- [Integrate AI into your Azure App Service applications](overview-ai-integration.md)
