
## Prerequisites

- Access to Azure Logic Apps
- Existing Standard logic app

## Create MCP Server

1. Navigate to the Logic Apps Standard instance.
1. Locate the "Agents" section in the table of contents.
1. Select "MCP servers" to access the configuration experience.

:::image type="content" source="media/create-model-context-server/image1.png" alt-text="MCP Server Configuration Interface":::

1. Choose to create a new MCP server or use existing workflows.

### Create New Workflows

1. Provide the MCP Server Name and Description.
1. Select a connector (e.g., Salesforce).
1. Choose actions such as Create record, Update record, and Get Opportunity records.

:::image type="content" source="media/create-model-context-server/image2.png" alt-text="MCP Server Name and Description Input":::

1. Configure the connection to Salesforce.
1. Specify object types and fields for actions.

:::image type="content" source="media/create-model-context-server/image3.png" alt-text="Salesforce Connector Selection":::

1. Select the Register button to create workflows.

:::image type="content" source="media/create-model-context-server/image4.png" alt-text="Registration Process Notification":::

## Use Existing Workflows

1. Select the "Use existing workflows" option.
1. Provide the MCP Server Name and Description.
1. Choose eligible workflows that meet the criteria (HTTP Trigger and HTTP Response Action).

:::image type="content" source="media/create-model-context-server/image5.png" alt-text="Existing Workflows Selection":::

1. Select the Create button to finalize the MCP server setup.

## Authentication Methods

### API Key-based Authentication

1. Select Key-based from the method dropdown.
1. Generate keys and store them securely.

:::image type="content" source="media/create-model-context-server/image6.png" alt-text="API Key Generation":::

### OAuth Authentication

1. Select Manage authentication.
1. Add Microsoft as the identity provider.
1. Complete the App Registration process in Azure Portal.

:::image type="content" source="media/create-model-context-server/image7.png" alt-text="OAuth Authentication Setup":::

1. Provide necessary information from the App Registration.

## Conclusion

After completing these steps, your Logic Apps MCP Server will be configured and ready for use. You can manage workflows and authentication settings as needed.
