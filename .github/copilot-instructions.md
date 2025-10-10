# Azure Documentation Repository - AI Coding Agent Instructions

## Repository Overview

This is the `azure-docs-pr` repository, Microsoft's primary documentation source for Azure services. It contains comprehensive technical documentation for 100+ Azure services and is built using DocFX v3 with the OpenPublishing platform.

### Repository Structure
- **`articles/`** - Main documentation content organized by service (e.g., `azure-functions/`, `app-service/`, `storage/`)
- **`includes/`** - Reusable content snippets shared across articles
- **`bread/`** - Breadcrumb navigation configuration
- **`.openpublishing.publish.config.json`** - Publishing configuration with 100+ dependent repositories
- **`docfx.json`** - DocFX build configuration with service-specific groupings

## Content Guidelines

### File Organization
- **Service-based structure**: Each Azure service has its own folder under `articles/`
- **Includes pattern**: Shared content goes in `includes/` and service-specific includes in `articles/{service}/includes/`
- **Media organization**: Images and media files are co-located with their articles

### Content Types and Naming
- **Concepts**: `{topic}.md` (e.g., `overview.md`, `concepts.md`)
- **Quickstarts**: `quickstart-{scenario}.md` or `qs-{scenario}.md`
- **Tutorials**: `tutorial-{scenario}.md`
- **How-to guides**: `how-to-{task}.md`
- **Reference**: `reference-{type}.md`
- **Troubleshooting**: `troubleshoot-{issue}.md`

### Metadata Requirements
All articles must include standardized YAML frontmatter:
```yaml
---
title: # Clear, descriptive title
description: # SEO-optimized description (150-160 chars)
author: {github-username}
ms.author: {microsoft-alias}
ms.service: {azure-service-name}
ms.subservice: {subservice-name} # if applicable
ms.topic: {article-type} # conceptual, how-to, tutorial, quickstart, reference
ms.date: {yyyy-mm-dd}
ms.reviewer: {reviewer-alias}
---
```

### Writing Standards
- **Customer intent focus**: Lead with clear customer scenarios and outcomes
- **Consistent formatting**: Use standard Markdown with Azure-specific extensions
- **Code blocks**: Include proper language identifiers and use realistic examples
- **Links**: Use relative links for internal content, full URLs for external
- **Images**: Alt text required, stored with descriptive filenames

## DocFX and Publishing Configuration

### Build System
- **Platform**: DocFX v3 with Markdig markdown engine
- **Groups**: Special handling for `iot-edge`, `migrate`, and `cyclecloud` content
- **Templates**: Uses `docs.html` template with PlantUML plugin support
- **Exclusions**: Themes, includes, and object files are excluded from builds

### Content Processing
- **Metadata inheritance**: Service-level metadata applied via `fileMetadata` in `docfx.json`
- **Conditional content**: Moniker ranges for versioned content (especially migrate service)
- **Global settings**: Brand, breadcrumb, feedback, and search scope configurations

### External Dependencies
The repository depends on 100+ external repositories for includes and shared content. Major dependencies include:
- Shared includes for cross-service scenarios
- Service-specific external repositories
- Common templates and snippets

## Contribution Workflow

### Content Creation
1. **Research phase**: Understand service architecture and customer scenarios
2. **Content planning**: Follow established information architecture patterns
3. **Draft creation**: Use appropriate templates and follow metadata requirements
4. **Technical review**: Ensure accuracy and completeness
5. **Editorial review**: Check for clarity, consistency, and style

### File Management
- **New articles**: Create in appropriate service folder with proper naming
- **Shared content**: Use includes for content used across multiple articles
- **Media files**: Store images close to consuming articles
- **Redirects**: Handle URL changes through redirect configuration

### Quality Standards
- **Technical accuracy**: All code samples must be tested and functional
- **SEO optimization**: Proper titles, descriptions, and header structure
- **Accessibility**: Alt text for images, proper heading hierarchy
- **Cross-references**: Maintain internal link consistency

## Service-Specific Patterns

### High-Volume Services
Services like `azure-functions`, `app-service`, `azure-monitor` have extensive content with specialized organization:
- Dedicated reviewers and authors
- Service-specific metadata inheritance
- Custom feedback channels
- Specialized build groups when needed

### Migrated Services
Some services have been migrated to dedicated repositories:
- AKS, Cosmos DB, Virtual Machines, Key Vault, and others
- Automated PR closure for migrated paths
- Redirect handling for moved content

### Special Content Areas
- **Reliability folder**: Requires special review workflow with designated owners
- **Governance content**: Policy and blueprint documentation with specific formatting
- **Partner solutions**: Third-party integration documentation

## Automation and Policies

### PR Management
- **Stale PR handling**: 14-day inactive period, 90-day auto-closure
- **Path-based restrictions**: Automated closure for migrated service paths
- **Review requirements**: Specialized workflows for sensitive content areas

### Content Protection
- **Breadcrumb modifications**: Special warnings for repository-wide navigation changes
- **Reliability content**: Restricted sign-off workflow
- **Quality gates**: Automated checks for metadata completeness and link validity

## Best Practices for AI Agents

### Content Generation
1. **Understand service context**: Research the Azure service before creating content
2. **Follow established patterns**: Use existing articles as templates for structure and style
3. **Validate technical details**: Ensure code samples and procedures are accurate
4. **Check dependencies**: Verify all includes and cross-references exist
5. **Test build impact**: Consider how changes affect DocFX build and publishing

### File Operations
1. **Respect folder structure**: Place content in appropriate service directories
2. **Use proper naming**: Follow established naming conventions
3. **Update metadata**: Ensure all required YAML frontmatter is present and accurate
4. **Handle redirects**: Plan for URL changes when moving or restructuring content
5. **Consider includes**: Use shared content patterns to avoid duplication

### Quality Assurance
1. **Technical validation**: Test all code samples and procedures
2. **Link verification**: Ensure all internal and external links are valid
3. **Metadata completeness**: Verify all required fields are populated
4. **Content freshness**: Include appropriate review dates and update cycles
5. **SEO optimization**: Craft effective titles and descriptions

This repository serves millions of Azure users worldwide. Maintain high standards for technical accuracy, clarity, and user experience in all contributions.

## Reliability Guide Creation

When creating reliability guides for Azure services in the `articles/reliability/` folder, use the comprehensive reliability instructions template. The template includes:

- 25+ structured sections with specific requirements
- Conditional logic for different service types (single-region vs multi-region)
- Reusable frameworks for failover scenarios, content organization, and quality standards
- Critical verification steps and technical accuracy requirements
- Sources and URL validation requirements

For reliability guide creation requests, reference the reliability-instructions.yml template that provides detailed guidance for each section, shared frameworks, and quality requirements.