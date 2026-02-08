# Microsoft Sentinel Documentation Customer Intent Analysis
# Script to analyze customer intent for each document based on title, description, and business context

$csvFile = "sentinel_docs_business_intent_analysis.csv"
$outputFile = "sentinel_customer_intent_analysis.csv"

# Function to determine customer intent based on document characteristics
function Get-CustomerIntent {
    param(
        [string]$title,
        [string]$businessIntent,
        [string]$contentType,
        [string]$targetAudience,
        [string]$fileName
    )
    
    $combinedText = "$title $fileName".ToLower()
    
    # Define customer intent patterns based on common security operations goals
    
    # Security Operations Efficiency
    if ($businessIntent -eq "Automation & Orchestration" -or $combinedText -like "*automat*" -or $combinedText -like "*orchestrat*" -or $combinedText -like "*playbook*") {
        return @{
            Intent = "Automate Security Operations and Response"
            Description = "Customers want to reduce manual effort, accelerate incident response, and ensure consistent security operations through automation."
            Goal = "operational efficiency and consistent response"
        }
    }
    
    # Threat Detection and Investigation
    if ($businessIntent -eq "Investigation & Hunting" -or $combinedText -like "*hunt*" -or $combinedText -like "*investigate*" -or $combinedText -like "*detect*" -or $combinedText -like "*threat*") {
        return @{
            Intent = "Proactively Detect and Investigate Security Threats"
            Description = "Customers want advanced threat detection capabilities and effective investigation workflows to identify and understand security incidents."
            Goal = "early threat detection and comprehensive incident understanding"
        }
    }
    
    # Analytics and Detection Rules
    if ($combinedText -like "*analytic*" -or $combinedText -like "*rule*" -or $combinedText -like "*detection*" -or $combinedText -like "*alert*") {
        return @{
            Intent = "Create Effective Security Detection Rules"
            Description = "Customers want to build accurate, low-noise detection rules that identify real threats without overwhelming analysts with false positives."
            Goal = "accurate threat detection with minimal false positives"
        }
    }
    
    # Data Integration and Connectivity
    if ($businessIntent -eq "Setup & Configuration" -and ($combinedText -like "*connect*" -or $combinedText -like "*data*" -or $combinedText -like "*connector*" -or $combinedText -like "*ingest*")) {
        return @{
            Intent = "Integrate and Centralize Security Data"
            Description = "Customers want to consolidate security data from multiple sources into a unified platform for comprehensive visibility and analysis."
            Goal = "comprehensive security data visibility and centralization"
        }
    }
    
    # Threat Intelligence
    if ($combinedText -like "*threat intelligence*" -or $combinedText -like "*indicator*" -or $combinedText -like "*ioc*" -or $combinedText -like "*stix*" -or $combinedText -like "*taxii*") {
        return @{
            Intent = "Enhance Detection with Threat Intelligence"
            Description = "Customers want to leverage external and internal threat intelligence to improve detection accuracy and provide context for security events."
            Goal = "intelligence-driven security operations and contextual awareness"
        }
    }
    
    # Incident Management
    if ($combinedText -like "*incident*" -or $combinedText -like "*case*" -or $combinedText -like "*triage*") {
        return @{
            Intent = "Streamline Security Incident Management"
            Description = "Customers want efficient incident management workflows that enable rapid triage, investigation, and resolution of security events."
            Goal = "efficient incident resolution and case management"
        }
    }
    
    # Monitoring and Observability
    if ($businessIntent -eq "Monitoring & Observability" -or $combinedText -like "*monitor*" -or $combinedText -like "*health*" -or $combinedText -like "*metrics*") {
        return @{
            Intent = "Monitor and Optimize Security Operations Performance"
            Description = "Customers want visibility into their security operations effectiveness and the ability to optimize performance and resource utilization."
            Goal = "operational visibility and continuous improvement"
        }
    }
    
    # Cost Management
    if ($combinedText -like "*cost*" -or $combinedText -like "*billing*" -or $combinedText -like "*pricing*") {
        return @{
            Intent = "Optimize Security Operations Costs"
            Description = "Customers want to understand, control, and optimize their security operations spending while maintaining effective protection."
            Goal = "cost-effective security operations"
        }
    }
    
    # Compliance and Reporting
    if ($combinedText -like "*compliance*" -or $combinedText -like "*audit*" -or $combinedText -like "*report*") {
        return @{
            Intent = "Ensure Security Compliance and Reporting"
            Description = "Customers want to meet regulatory requirements and provide stakeholders with comprehensive security posture reports."
            Goal = "regulatory compliance and stakeholder transparency"
        }
    }
    
    # User Behavior Analytics
    if ($combinedText -like "*ueba*" -or $combinedText -like "*behavior*" -or $combinedText -like "*entity*" -or $combinedText -like "*user*") {
        return @{
            Intent = "Detect Insider Threats and Anomalous Behavior"
            Description = "Customers want to identify suspicious user and entity behavior that may indicate insider threats or compromised accounts."
            Goal = "insider threat detection and behavioral analysis"
        }
    }
    
    # Migration and Deployment
    if ($combinedText -like "*migrat*" -or $combinedText -like "*deploy*" -or $combinedText -like "*onboard*") {
        return @{
            Intent = "Successfully Deploy and Migrate to Modern SIEM"
            Description = "Customers want smooth migration from legacy security tools and successful deployment of modern SIEM capabilities."
            Goal = "successful platform migration and deployment"
        }
    }
    
    # Workbooks and Visualization
    if ($combinedText -like "*workbook*" -or $combinedText -like "*visualiz*" -or $combinedText -like "*dashboard*") {
        return @{
            Intent = "Gain Security Insights Through Visualization"
            Description = "Customers want clear, actionable visualizations of their security data to support decision-making and stakeholder communication."
            Goal = "data-driven security insights and communication"
        }
    }
    
    # Advanced Analytics and ML
    if ($combinedText -like "*machine learning*" -or $combinedText -like "*ml*" -or $combinedText -like "*anomal*" -or $combinedText -like "*fusion*") {
        return @{
            Intent = "Leverage Advanced Analytics for Threat Detection"
            Description = "Customers want to use machine learning and advanced analytics to detect sophisticated threats and reduce false positives."
            Goal = "advanced threat detection and reduced noise"
        }
    }
    
    # Multi-workspace and Enterprise
    if ($combinedText -like "*workspace*" -or $combinedText -like "*tenant*" -or $combinedText -like "*enterprise*") {
        return @{
            Intent = "Scale Security Operations Across Enterprise"
            Description = "Customers want to manage security operations across multiple environments and organizational units effectively."
            Goal = "enterprise-scale security management"
        }
    }
    
    # Troubleshooting
    if ($businessIntent -eq "Troubleshooting & Support" -or $combinedText -like "*troubleshoot*" -or $combinedText -like "*debug*") {
        return @{
            Intent = "Resolve Security Operations Issues Quickly"
            Description = "Customers want rapid resolution of technical issues that impact their security operations and detection capabilities."
            Goal = "operational continuity and issue resolution"
        }
    }
    
    # Reference and Documentation
    if ($businessIntent -eq "Reference & Documentation" -or $contentType -eq "Reference") {
        return @{
            Intent = "Access Comprehensive Security Configuration Reference"
            Description = "Customers want detailed reference information to properly configure, customize, and optimize their security operations."
            Goal = "accurate configuration and customization"
        }
    }
    
    # Default fallback
    return @{
        Intent = "Improve Overall Security Operations Effectiveness"
        Description = "Customers want to enhance their overall security posture through better processes, tools, and practices."
        Goal = "comprehensive security improvement"
    }
}

# Function to categorize intent into high-level themes
function Get-IntentCategory {
    param([string]$intent)
    
    switch -Wildcard ($intent) {
        "*Automate*" { return "Operational Efficiency" }
        "*Detect*" { return "Threat Detection" }
        "*Investigation*" { return "Threat Detection" }
        "*Hunting*" { return "Threat Detection" }
        "*Analytics*" { return "Threat Detection" }
        "*Detection Rules*" { return "Threat Detection" }
        "*Integrate*" { return "Data Management" }
        "*Centralize*" { return "Data Management" }
        "*Intelligence*" { return "Threat Intelligence" }
        "*Incident*" { return "Incident Response" }
        "*Monitor*" { return "Operational Visibility" }
        "*Optimize*" { return "Operational Efficiency" }
        "*Cost*" { return "Cost Management" }
        "*Compliance*" { return "Governance & Compliance" }
        "*Behavior*" { return "Advanced Analytics" }
        "*Deploy*" { return "Platform Management" }
        "*Migrate*" { return "Platform Management" }
        "*Visualization*" { return "Operational Visibility" }
        "*Advanced Analytics*" { return "Advanced Analytics" }
        "*Scale*" { return "Platform Management" }
        "*Troubleshoot*" { return "Support & Maintenance" }
        "*Reference*" { return "Knowledge & Reference" }
        default { return "General Security Operations" }
    }
}

# Read existing CSV
Write-Host "Reading existing analysis..."
$existingData = Import-Csv -Path $csvFile

$results = @()
$count = 0

Write-Host "Analyzing customer intent for $($existingData.Count) documents..."

foreach ($row in $existingData) {
    $count++
    Write-Progress -Activity "Analyzing customer intent" -Status $row.Title -PercentComplete (($count / $existingData.Count) * 100)
    
    try {
        $intentData = Get-CustomerIntent -title $row.Title -businessIntent $row.BusinessIntent -contentType $row.ContentType -targetAudience $row.TargetAudience -fileName $row.FilePath
        $category = Get-IntentCategory -intent $intentData.Intent
        
        $results += [PSCustomObject]@{
            FilePath = $row.FilePath
            Title = $row.Title
            Author = $row.Author
            BusinessIntent = $row.BusinessIntent
            ContentType = $row.ContentType
            TargetAudience = $row.TargetAudience
            CustomerIntent = $intentData.Intent
            CustomerDescription = $intentData.Description
            CustomerGoal = $intentData.Goal
            IntentCategory = $category
            RelatedToPhishingAutomation = $row.RelatedToPhishingAutomation
            PriorityForImprovement = $row.PriorityForImprovement
            LastUpdated = $row.LastUpdated
        }
    }
    catch {
        Write-Warning "Error processing $($row.Title): $($_.Exception.Message)"
    }
}

# Export results
Write-Host "Exporting customer intent analysis to $outputFile..."
$results | Export-Csv -Path $outputFile -NoTypeInformation

# Generate summary statistics
$intentStats = $results | Group-Object CustomerIntent | Select-Object Name, Count | Sort-Object Count -Descending
$categoryStats = $results | Group-Object IntentCategory | Select-Object Name, Count | Sort-Object Count -Descending

Write-Host "`nCustomer Intent Distribution (Top 10):"
$intentStats | Select-Object -First 10 | Format-Table -AutoSize

Write-Host "`nIntent Category Distribution:"
$categoryStats | Format-Table -AutoSize

Write-Host "Analysis complete! Results saved to: $outputFile"
Write-Host "Processed $count documents with customer intent analysis."