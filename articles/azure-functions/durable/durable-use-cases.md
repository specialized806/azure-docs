---
title: When to use Azure Durable
description: Discover how organizations use Azure Durable to solve complex business problems.
author: hhunter-ms
ms.author: hannahhunter
ms.reviewer: azfuncdf
ms.date: 12/02/2025
ms.topic: concept-article
ms.service: azure-functions
ms.subservice: durable
---

# When to use Azure Durable

Discover how organizations use Azure Durable to solve complex business problems.

> [!TIP]
> Unsure if Azure Durable is right for your project? See [Choose the right Azure workflow solution](durable-comparison-alternatives.md) to compare alternatives.

## E-commerce: Order processing

### The challenge
Online retailers need to process orders reliably, coordinating inventory checks, payments, shipping, and notifications—all while handling failures gracefully.

### The solution

# [C#](#tab/csharp)

```csharp
[Function(nameof(ProcessOrder))]
public async Task<OrderResult> ProcessOrder(
    [OrchestrationTrigger] TaskOrchestrationContext context)
{
    var order = context.GetInput<Order>();
    
    try
    {
        // Step 1: Reserve inventory
        var inventoryReserved = await context.CallActivityAsync<bool>(
            nameof(ReserveInventory), order);
        
        if (!inventoryReserved)
        {
            await context.CallActivityAsync(nameof(NotifyOutOfStock), order);
            return new OrderResult { Status = "OutOfStock" };
        }
        
        // Step 2: Process payment (with retry)
        var paymentResult = await context.CallActivityAsync<PaymentResult>(
            nameof(ProcessPayment), 
            order,
            new TaskOptions { Retry = new RetryPolicy(3, TimeSpan.FromSeconds(5)) });
        
        if (!paymentResult.Success)
        {
            await context.CallActivityAsync(nameof(ReleaseInventory), order);
            return new OrderResult { Status = "PaymentFailed" };
        }
        
        // Step 3: Initiate shipping
        var trackingNumber = await context.CallActivityAsync<string>(
            nameof(CreateShipment), order);
        
        // Step 4: Send confirmation
        await context.CallActivityAsync(nameof(SendConfirmation), new {
            order.Email,
            order.OrderId,
            trackingNumber
        });
        
        return new OrderResult { 
            Status = "Completed", 
            TrackingNumber = trackingNumber 
        };
    }
    catch (TaskFailedException)
    {
        // Compensate on failure
        await context.CallActivityAsync(nameof(ReleaseInventory), order);
        await context.CallActivityAsync(nameof(RefundPayment), order);
        throw;
    }
}
```

# [Python](#tab/python)

```python
@app.orchestration_trigger(context_name="context")
def process_order(context):
    order = context.get_input()
    
    try:
        # Step 1: Reserve inventory
        inventory_reserved = yield context.call_activity("ReserveInventory", order)
        
        if not inventory_reserved:
            yield context.call_activity("NotifyOutOfStock", order)
            return {"status": "OutOfStock"}
        
        # Step 2: Process payment (with retry)
        payment_result = yield context.call_activity(
            "ProcessPayment",
            order,
            retry_policy=RetryPolicy(max_attempts=3, initial_interval=timedelta(seconds=5)))
        
        if not payment_result["success"]:
            yield context.call_activity("ReleaseInventory", order)
            return {"status": "PaymentFailed"}
        
        # Step 3: Initiate shipping
        tracking_number = yield context.call_activity("CreateShipment", order)
        
        # Step 4: Send confirmation
        yield context.call_activity("SendConfirmation", {
            "email": order["email"],
            "orderId": order["orderId"],
            "trackingNumber": tracking_number
        })
        
        return {
            "status": "Completed",
            "trackingNumber": tracking_number
        }
    except Exception:
        # Compensate on failure
        yield context.call_activity("ReleaseInventory", order)
        yield context.call_activity("RefundPayment", order)
        raise
```

# [JavaScript](#tab/javascript)

```javascript
const df = require("durable-functions");

module.exports = df.orchestrator(function* (context) {
    const order = context.df.getInput();
    
    try {
        // Step 1: Reserve inventory
        const inventoryReserved = yield context.df.callActivity("ReserveInventory", order);
        
        if (!inventoryReserved) {
            yield context.df.callActivity("NotifyOutOfStock", order);
            return { status: "OutOfStock" };
        }
        
        // Step 2: Process payment (with retry)
        const paymentResult = yield context.df.callActivityWithRetry(
            "ProcessPayment",
            { maxNumberOfAttempts: 3, firstRetryIntervalInMilliseconds: 5000 },
            order);
        
        if (!paymentResult.success) {
            yield context.df.callActivity("ReleaseInventory", order);
            return { status: "PaymentFailed" };
        }
        
        // Step 3: Initiate shipping
        const trackingNumber = yield context.df.callActivity("CreateShipment", order);
        
        // Step 4: Send confirmation
        yield context.df.callActivity("SendConfirmation", {
            email: order.email,
            orderId: order.orderId,
            trackingNumber: trackingNumber
        });
        
        return {
            status: "Completed",
            trackingNumber: trackingNumber
        };
    } catch (error) {
        // Compensate on failure
        yield context.df.callActivity("ReleaseInventory", order);
        yield context.df.callActivity("RefundPayment", order);
        throw error;
    }
});
```

# [PowerShell](#tab/powershell)

```powershell
param($Context)

$order = $Context.Input

try {
    # Step 1: Reserve inventory
    $inventoryReserved = Invoke-DurableActivity -FunctionName "ReserveInventory" -Input $order
    
    if (-not $inventoryReserved) {
        Invoke-DurableActivity -FunctionName "NotifyOutOfStock" -Input $order
        return @{ Status = "OutOfStock" }
    }
    
    # Step 2: Process payment (with retry)
    $retryOptions = New-DurableRetryOptions -MaxNumberOfAttempts 3 -FirstRetryInterval (New-TimeSpan -Seconds 5)
    $paymentResult = Invoke-DurableActivity -FunctionName "ProcessPayment" -Input $order -RetryOptions $retryOptions
    
    if (-not $paymentResult.Success) {
        Invoke-DurableActivity -FunctionName "ReleaseInventory" -Input $order
        return @{ Status = "PaymentFailed" }
    }
    
    # Step 3: Initiate shipping
    $trackingNumber = Invoke-DurableActivity -FunctionName "CreateShipment" -Input $order
    
    # Step 4: Send confirmation
    $confirmationData = @{
        Email = $order.Email
        OrderId = $order.OrderId
        TrackingNumber = $trackingNumber
    }
    Invoke-DurableActivity -FunctionName "SendConfirmation" -Input $confirmationData
    
    return @{
        Status = "Completed"
        TrackingNumber = $trackingNumber
    }
}
catch {
    # Compensate on failure
    Invoke-DurableActivity -FunctionName "ReleaseInventory" -Input $order
    Invoke-DurableActivity -FunctionName "RefundPayment" -Input $order
    throw
}
```

# [Java](#tab/java)

```java
@FunctionName("ProcessOrder")
public OrderResult processOrder(
        @DurableOrchestrationTrigger(name = "context") TaskOrchestrationContext context) {
    Order order = context.getInput(Order.class);
    
    try {
        // Step 1: Reserve inventory
        boolean inventoryReserved = context.callActivity(
            "ReserveInventory", order, Boolean.class).await();
        
        if (!inventoryReserved) {
            context.callActivity("NotifyOutOfStock", order).await();
            return new OrderResult("OutOfStock");
        }
        
        // Step 2: Process payment (with retry)
        RetryPolicy retryPolicy = new RetryPolicy(3, Duration.ofSeconds(5));
        PaymentResult paymentResult = context.callActivity(
            "ProcessPayment",
            order,
            new TaskOptions(retryPolicy),
            PaymentResult.class).await();
        
        if (!paymentResult.isSuccess()) {
            context.callActivity("ReleaseInventory", order).await();
            return new OrderResult("PaymentFailed");
        }
        
        // Step 3: Initiate shipping
        String trackingNumber = context.callActivity(
            "CreateShipment", order, String.class).await();
        
        // Step 4: Send confirmation
        Map<String, Object> confirmationData = Map.of(
            "email", order.getEmail(),
            "orderId", order.getOrderId(),
            "trackingNumber", trackingNumber
        );
        context.callActivity("SendConfirmation", confirmationData).await();
        
        return new OrderResult("Completed", trackingNumber);
    } catch (TaskFailedException e) {
        // Compensate on failure
        context.callActivity("ReleaseInventory", order).await();
        context.callActivity("RefundPayment", order).await();
        throw e;
    }
}
```

---

### Benefits
- **Reliability**: Orders complete even if services temporarily fail
- **Consistency**: Automatic compensation prevents orphaned reservations
- **Visibility**: Dashboard shows order status and processing history
- **Scalability**: Handles Black Friday traffic spikes automatically

## Healthcare: Patient onboarding

### The challenge
Healthcare providers must onboard patients through a multi-step process involving identity verification, insurance validation, consent collection, and appointment scheduling—often requiring human approval steps.

### The solution

# [C#](#tab/csharp)

```csharp
[Function(nameof(PatientOnboarding))]
public async Task<OnboardingResult> PatientOnboarding(
    [OrchestrationTrigger] TaskOrchestrationContext context)
{
    var patient = context.GetInput<PatientInfo>();
    
    // Step 1: Verify identity
    var identityVerified = await context.CallActivityAsync<bool>(
        nameof(VerifyIdentity), patient);
    
    if (!identityVerified)
    {
        await context.CallActivityAsync(nameof(RequestManualReview), patient);
        var approval = await context.WaitForExternalEvent<ApprovalResult>(
            "ManualApproval", TimeSpan.FromHours(48));
        
        if (!approval.Approved)
            return new OnboardingResult { Status = "Rejected" };
    }
    
    // Step 2: Validate insurance (fan-out)
    var insuranceTask = context.CallActivityAsync<InsuranceResult>(
        nameof(ValidateInsurance), patient);
    var eligibilityTask = context.CallActivityAsync<EligibilityResult>(
        nameof(CheckEligibility), patient);
    
    await Task.WhenAll(insuranceTask, eligibilityTask);
    
    // Step 3: Collect consent
    await context.CallActivityAsync(nameof(SendConsentRequest), patient);
    var consent = await context.WaitForExternalEvent<ConsentResult>(
        "ConsentReceived", TimeSpan.FromDays(7));
    
    if (!consent.Granted)
        return new OnboardingResult { Status = "ConsentNotProvided" };
    
    // Step 4: Schedule appointment
    var appointment = await context.CallActivityAsync<Appointment>(
        nameof(ScheduleAppointment), patient);
    
    return new OnboardingResult { 
        Status = "Completed",
        AppointmentId = appointment.Id
    };
}
```

# [Python](#tab/python)

```python
@app.orchestration_trigger(context_name="context")
def patient_onboarding(context):
    patient = context.get_input()
    
    # Step 1: Verify identity
    identity_verified = yield context.call_activity("VerifyIdentity", patient)
    
    if not identity_verified:
        yield context.call_activity("RequestManualReview", patient)
        approval = yield context.wait_for_external_event(
            "ManualApproval", timedelta(hours=48))
        
        if not approval["approved"]:
            return {"status": "Rejected"}
    
    # Step 2: Validate insurance (fan-out)
    insurance_task = context.call_activity("ValidateInsurance", patient)
    eligibility_task = context.call_activity("CheckEligibility", patient)
    
    yield context.task_all([insurance_task, eligibility_task])
    
    # Step 3: Collect consent
    yield context.call_activity("SendConsentRequest", patient)
    consent = yield context.wait_for_external_event(
        "ConsentReceived", timedelta(days=7))
    
    if not consent["granted"]:
        return {"status": "ConsentNotProvided"}
    
    # Step 4: Schedule appointment
    appointment = yield context.call_activity("ScheduleAppointment", patient)
    
    return {
        "status": "Completed",
        "appointmentId": appointment["id"]
    }
```

# [JavaScript](#tab/javascript)

```javascript
const df = require("durable-functions");

module.exports = df.orchestrator(function* (context) {
    const patient = context.df.getInput();
    
    // Step 1: Verify identity
    const identityVerified = yield context.df.callActivity("VerifyIdentity", patient);
    
    if (!identityVerified) {
        yield context.df.callActivity("RequestManualReview", patient);
        const approval = yield context.df.waitForExternalEvent(
            "ManualApproval", 48 * 60 * 60 * 1000);
        
        if (!approval.approved)
            return { status: "Rejected" };
    }
    
    // Step 2: Validate insurance (fan-out)
    const insuranceTask = context.df.callActivity("ValidateInsurance", patient);
    const eligibilityTask = context.df.callActivity("CheckEligibility", patient);
    
    yield context.df.Task.all([insuranceTask, eligibilityTask]);
    
    // Step 3: Collect consent
    yield context.df.callActivity("SendConsentRequest", patient);
    const consent = yield context.df.waitForExternalEvent(
        "ConsentReceived", 7 * 24 * 60 * 60 * 1000);
    
    if (!consent.granted)
        return { status: "ConsentNotProvided" };
    
    // Step 4: Schedule appointment
    const appointment = yield context.df.callActivity("ScheduleAppointment", patient);
    
    return {
        status: "Completed",
        appointmentId: appointment.id
    };
});
```

# [PowerShell](#tab/powershell)

```powershell
param($Context)

$patient = $Context.Input

# Step 1: Verify identity
$identityVerified = Invoke-DurableActivity -FunctionName "VerifyIdentity" -Input $patient

if (-not $identityVerified) {
    Invoke-DurableActivity -FunctionName "RequestManualReview" -Input $patient
    $approval = Wait-DurableExternalEvent -EventName "ManualApproval" -Timeout (New-TimeSpan -Hours 48)
    
    if (-not $approval.Approved) {
        return @{ Status = "Rejected" }
    }
}

# Step 2: Validate insurance (fan-out)
$insuranceTask = Start-DurableActivity -FunctionName "ValidateInsurance" -Input $patient -NoWait
$eligibilityTask = Start-DurableActivity -FunctionName "CheckEligibility" -Input $patient -NoWait

Wait-DurableTask -Task @($insuranceTask, $eligibilityTask)

# Step 3: Collect consent
Invoke-DurableActivity -FunctionName "SendConsentRequest" -Input $patient
$consent = Wait-DurableExternalEvent -EventName "ConsentReceived" -Timeout (New-TimeSpan -Days 7)

if (-not $consent.Granted) {
    return @{ Status = "ConsentNotProvided" }
}

# Step 4: Schedule appointment
$appointment = Invoke-DurableActivity -FunctionName "ScheduleAppointment" -Input $patient

return @{
    Status = "Completed"
    AppointmentId = $appointment.Id
}
```

# [Java](#tab/java)

```java
@FunctionName("PatientOnboarding")
public OnboardingResult patientOnboarding(
        @DurableOrchestrationTrigger(name = "context") TaskOrchestrationContext context) {
    PatientInfo patient = context.getInput(PatientInfo.class);
    
    // Step 1: Verify identity
    boolean identityVerified = context.callActivity(
        "VerifyIdentity", patient, Boolean.class).await();
    
    if (!identityVerified) {
        context.callActivity("RequestManualReview", patient).await();
        ApprovalResult approval = context.waitForExternalEvent(
            "ManualApproval", Duration.ofHours(48), ApprovalResult.class).await();
        
        if (!approval.isApproved())
            return new OnboardingResult("Rejected");
    }
    
    // Step 2: Validate insurance (fan-out)
    Task<InsuranceResult> insuranceTask = context.callActivity(
        "ValidateInsurance", patient, InsuranceResult.class);
    Task<EligibilityResult> eligibilityTask = context.callActivity(
        "CheckEligibility", patient, EligibilityResult.class);
    
    context.allOf(List.of(insuranceTask, eligibilityTask)).await();
    
    // Step 3: Collect consent
    context.callActivity("SendConsentRequest", patient).await();
    ConsentResult consent = context.waitForExternalEvent(
        "ConsentReceived", Duration.ofDays(7), ConsentResult.class).await();
    
    if (!consent.isGranted())
        return new OnboardingResult("ConsentNotProvided");
    
    // Step 4: Schedule appointment
    Appointment appointment = context.callActivity(
        "ScheduleAppointment", patient, Appointment.class).await();
    
    return new OnboardingResult("Completed", appointment.getId());
}
```

---

### Benefits
- **Compliance**: Full audit trail of each onboarding step
- **Human-in-the-loop**: Natural support for approval workflows
- **Long-running**: Workflow can span days or weeks
- **Resilience**: Patient progress is never lost

## Financial services: Loan processing

### The challenge
Banks need to process loan applications through credit checks, risk assessment, document verification, and compliance validation—with strict SLAs and audit requirements.

### The solution

# [C#](#tab/csharp)

```csharp
[Function(nameof(ProcessLoanApplication))]
public async Task<LoanDecision> ProcessLoanApplication(
    [OrchestrationTrigger] TaskOrchestrationContext context)
{
    var application = context.GetInput<LoanApplication>();
    var logger = context.CreateReplaySafeLogger<ProcessLoanApplication>();
    
    logger.LogInformation("Processing loan {LoanId}", application.Id);
    
    // Parallel initial checks
    var creditTask = context.CallActivityAsync<CreditScore>(
        nameof(CheckCredit), application);
    var fraudTask = context.CallActivityAsync<FraudResult>(
        nameof(FraudDetection), application);
    var employmentTask = context.CallActivityAsync<EmploymentResult>(
        nameof(VerifyEmployment), application);
    
    await Task.WhenAll(creditTask, fraudTask, employmentTask);
    
    // Evaluate results
    if (fraudTask.Result.RiskLevel == "High")
        return new LoanDecision { Approved = false, Reason = "Failed fraud check" };
    
    // Risk-based routing
    var riskScore = await context.CallActivityAsync<int>(
        nameof(CalculateRiskScore), new {
            Credit = creditTask.Result,
            Fraud = fraudTask.Result,
            Employment = employmentTask.Result
        });
    
    if (riskScore > 70)
        return await AutoApprove(context, application);
    else if (riskScore > 40)
        return await RequestAdditionalDocuments(context, application);
    else
        return await ManualUnderwriting(context, application);
}
```

# [Python](#tab/python)

```python
@app.orchestration_trigger(context_name="context")
def process_loan_application(context):
    application = context.get_input()
    logging.info(f"Processing loan {application['id']}")
    
    # Parallel initial checks
    credit_task = context.call_activity("CheckCredit", application)
    fraud_task = context.call_activity("FraudDetection", application)
    employment_task = context.call_activity("VerifyEmployment", application)
    
    results = yield context.task_all([credit_task, fraud_task, employment_task])
    credit_result, fraud_result, employment_result = results
    
    # Evaluate results
    if fraud_result["riskLevel"] == "High":
        return {"approved": False, "reason": "Failed fraud check"}
    
    # Risk-based routing
    risk_score = yield context.call_activity("CalculateRiskScore", {
        "credit": credit_result,
        "fraud": fraud_result,
        "employment": employment_result
    })
    
    if risk_score > 70:
        return (yield context.call_sub_orchestrator("AutoApprove", application))
    elif risk_score > 40:
        return (yield context.call_sub_orchestrator("RequestAdditionalDocuments", application))
    else:
        return (yield context.call_sub_orchestrator("ManualUnderwriting", application))
```

# [JavaScript](#tab/javascript)

```javascript
const df = require("durable-functions");

module.exports = df.orchestrator(function* (context) {
    const application = context.df.getInput();
    context.log.info(`Processing loan ${application.id}`);
    
    // Parallel initial checks
    const creditTask = context.df.callActivity("CheckCredit", application);
    const fraudTask = context.df.callActivity("FraudDetection", application);
    const employmentTask = context.df.callActivity("VerifyEmployment", application);
    
    const [creditResult, fraudResult, employmentResult] = 
        yield context.df.Task.all([creditTask, fraudTask, employmentTask]);
    
    // Evaluate results
    if (fraudResult.riskLevel === "High")
        return { approved: false, reason: "Failed fraud check" };
    
    // Risk-based routing
    const riskScore = yield context.df.callActivity("CalculateRiskScore", {
        credit: creditResult,
        fraud: fraudResult,
        employment: employmentResult
    });
    
    if (riskScore > 70)
        return yield context.df.callSubOrchestrator("AutoApprove", application);
    else if (riskScore > 40)
        return yield context.df.callSubOrchestrator("RequestAdditionalDocuments", application);
    else
        return yield context.df.callSubOrchestrator("ManualUnderwriting", application);
});
```

# [PowerShell](#tab/powershell)

```powershell
param($Context)

$application = $Context.Input
Write-Host "Processing loan $($application.Id)"

# Parallel initial checks
$creditTask = Start-DurableActivity -FunctionName "CheckCredit" -Input $application -NoWait
$fraudTask = Start-DurableActivity -FunctionName "FraudDetection" -Input $application -NoWait
$employmentTask = Start-DurableActivity -FunctionName "VerifyEmployment" -Input $application -NoWait

$results = Wait-DurableTask -Task @($creditTask, $fraudTask, $employmentTask)
$creditResult = $results[0]
$fraudResult = $results[1]
$employmentResult = $results[2]

# Evaluate results
if ($fraudResult.RiskLevel -eq "High") {
    return @{ Approved = $false; Reason = "Failed fraud check" }
}

# Risk-based routing
$riskScore = Invoke-DurableActivity -FunctionName "CalculateRiskScore" -Input @{
    Credit = $creditResult
    Fraud = $fraudResult
    Employment = $employmentResult
}

if ($riskScore -gt 70) {
    return Invoke-DurableSubOrchestrator -FunctionName "AutoApprove" -Input $application
}
elseif ($riskScore -gt 40) {
    return Invoke-DurableSubOrchestrator -FunctionName "RequestAdditionalDocuments" -Input $application
}
else {
    return Invoke-DurableSubOrchestrator -FunctionName "ManualUnderwriting" -Input $application
}
```

# [Java](#tab/java)

```java
@FunctionName("ProcessLoanApplication")
public LoanDecision processLoanApplication(
        @DurableOrchestrationTrigger(name = "context") TaskOrchestrationContext context) {
    LoanApplication application = context.getInput(LoanApplication.class);
    context.getLogger().info("Processing loan " + application.getId());
    
    // Parallel initial checks
    Task<CreditScore> creditTask = context.callActivity(
        "CheckCredit", application, CreditScore.class);
    Task<FraudResult> fraudTask = context.callActivity(
        "FraudDetection", application, FraudResult.class);
    Task<EmploymentResult> employmentTask = context.callActivity(
        "VerifyEmployment", application, EmploymentResult.class);
    
    context.allOf(List.of(creditTask, fraudTask, employmentTask)).await();
    
    // Evaluate results
    if ("High".equals(fraudTask.await().getRiskLevel()))
        return new LoanDecision(false, "Failed fraud check");
    
    // Risk-based routing
    Map<String, Object> riskData = Map.of(
        "credit", creditTask.await(),
        "fraud", fraudTask.await(),
        "employment", employmentTask.await()
    );
    int riskScore = context.callActivity("CalculateRiskScore", riskData, Integer.class).await();
    
    if (riskScore > 70)
        return context.callSubOrchestrator("AutoApprove", application, LoanDecision.class).await();
    else if (riskScore > 40)
        return context.callSubOrchestrator("RequestAdditionalDocuments", application, LoanDecision.class).await();
    else
        return context.callSubOrchestrator("ManualUnderwriting", application, LoanDecision.class).await();
}
```

---

### Benefits
- **Speed**: Parallel checks reduce processing time
- **Accuracy**: Consistent rule application
- **Audit**: Complete history for regulatory compliance
- **Flexibility**: Easy to modify decision rules

## Manufacturing: IoT device provisioning

### The challenge
Manufacturing companies need to provision thousands of IoT devices with certificates, firmware, and configuration—coordinating across multiple systems.

### The solution

# [C#](#tab/csharp)

```csharp
[Function(nameof(ProvisionDevice))]
public async Task<ProvisioningResult> ProvisionDevice(
    [OrchestrationTrigger] TaskOrchestrationContext context)
{
    var device = context.GetInput<DeviceInfo>();
    
    // Step 1: Generate certificates
    var cert = await context.CallActivityAsync<Certificate>(
        nameof(GenerateCertificate), device);
    
    // Step 2: Register in IoT Hub
    var registration = await context.CallActivityAsync<DeviceRegistration>(
        nameof(RegisterInIoTHub), new { device, cert });
    
    // Step 3: Push firmware (with retry for network issues)
    await context.CallActivityAsync(
        nameof(DeployFirmware), 
        new { device.Id, registration.ConnectionString },
        new TaskOptions { 
            Retry = new RetryPolicy(5, TimeSpan.FromMinutes(1)) 
        });
    
    // Step 4: Configure device settings
    await context.CallActivityAsync(nameof(ApplyConfiguration), device);
    
    // Step 5: Validate connectivity
    var connected = await context.CallActivityAsync<bool>(
        nameof(ValidateConnectivity), device.Id);
    
    if (!connected)
    {
        // Create support ticket for manual intervention
        await context.CallActivityAsync(nameof(CreateSupportTicket), device);
        
        // Wait for resolution (up to 24 hours)
        var resolved = await context.WaitForExternalEvent<bool>(
            "ConnectivityResolved",
            TimeSpan.FromHours(24));
        
        if (!resolved)
            return new ProvisioningResult { 
                Status = "Failed", 
                Error = "Connectivity timeout" 
            };
    }
    
    return new ProvisioningResult { 
        Status = "Completed",
        DeviceId = device.Id,
        ConnectionString = registration.ConnectionString
    };
}

// Bulk provisioning with fan-out
[Function(nameof(BulkProvision))]
public async Task<BulkResult> BulkProvision(
    [OrchestrationTrigger] TaskOrchestrationContext context)
{
    var devices = context.GetInput<List<DeviceInfo>>();
    
    // Fan-out: Provision all devices in parallel
    var tasks = devices.Select(device => 
        context.CallSubOrchestratorAsync<ProvisioningResult>(
            nameof(ProvisionDevice), device));
    
    var results = await Task.WhenAll(tasks);
    
    return new BulkResult {
        Total = devices.Count,
        Succeeded = results.Count(r => r.Status == "Completed"),
        Failed = results.Count(r => r.Status == "Failed")
    };
}
```

# [Python](#tab/python)

```python
@app.orchestration_trigger(context_name="context")
def provision_device(context):
    device = context.get_input()
    
    # Step 1: Generate certificates
    cert = yield context.call_activity("GenerateCertificate", device)
    
    # Step 2: Register in IoT Hub
    registration = yield context.call_activity("RegisterInIoTHub", {
        "device": device,
        "cert": cert
    })
    
    # Step 3: Push firmware (with retry for network issues)
    retry_options = df.RetryOptions(
        first_retry_interval_in_milliseconds=60000,
        max_number_of_attempts=5
    )
    yield context.call_activity_with_retry(
        "DeployFirmware",
        retry_options,
        {"id": device["id"], "connectionString": registration["connectionString"]}
    )
    
    # Step 4: Configure device settings
    yield context.call_activity("ApplyConfiguration", device)
    
    # Step 5: Validate connectivity
    connected = yield context.call_activity("ValidateConnectivity", device["id"])
    
    if not connected:
        # Create support ticket for manual intervention
        yield context.call_activity("CreateSupportTicket", device)
        
        # Wait for resolution (up to 24 hours)
        resolved = yield context.wait_for_external_event_with_timeout(
            "ConnectivityResolved", 
            timedelta(hours=24)
        )
        
        if not resolved:
            return {
                "status": "Failed",
                "error": "Connectivity timeout"
            }
    
    return {
        "status": "Completed",
        "deviceId": device["id"],
        "connectionString": registration["connectionString"]
    }

# Bulk provisioning with fan-out
@app.orchestration_trigger(context_name="context")
def bulk_provision(context):
    devices = context.get_input()
    
    # Fan-out: Provision all devices in parallel
    tasks = [context.call_sub_orchestrator("ProvisionDevice", device) 
             for device in devices]
    
    results = yield context.task_all(tasks)
    
    succeeded = sum(1 for r in results if r["status"] == "Completed")
    
    return {
        "total": len(devices),
        "succeeded": succeeded,
        "failed": len(devices) - succeeded
    }
```

# [JavaScript](#tab/javascript)

```javascript
const df = require("durable-functions");

module.exports = df.orchestrator(function* (context) {
    const device = context.df.getInput();
    
    // Step 1: Generate certificates
    const cert = yield context.df.callActivity("GenerateCertificate", device);
    
    // Step 2: Register in IoT Hub
    const registration = yield context.df.callActivity("RegisterInIoTHub", {
        device: device,
        cert: cert
    });
    
    // Step 3: Push firmware (with retry for network issues)
    const retryOptions = new df.RetryOptions(60000, 5);
    yield context.df.callActivityWithRetry(
        "DeployFirmware",
        retryOptions,
        { id: device.id, connectionString: registration.connectionString }
    );
    
    // Step 4: Configure device settings
    yield context.df.callActivity("ApplyConfiguration", device);
    
    // Step 5: Validate connectivity
    const connected = yield context.df.callActivity("ValidateConnectivity", device.id);
    
    if (!connected) {
        // Create support ticket for manual intervention
        yield context.df.callActivity("CreateSupportTicket", device);
        
        // Wait for resolution (up to 24 hours)
        const timeout = df.DateTime.fromDate(
            new Date(Date.now() + 24 * 60 * 60 * 1000)
        );
        const resolved = yield context.df.waitForExternalEvent("ConnectivityResolved", timeout);
        
        if (!resolved)
            return {
                status: "Failed",
                error: "Connectivity timeout"
            };
    }
    
    return {
        status: "Completed",
        deviceId: device.id,
        connectionString: registration.connectionString
    };
});

// Bulk provisioning with fan-out (separate orchestrator)
module.exports = df.orchestrator(function* (context) {
    const devices = context.df.getInput();
    
    // Fan-out: Provision all devices in parallel
    const tasks = devices.map(device => 
        context.df.callSubOrchestrator("ProvisionDevice", device));
    
    const results = yield context.df.Task.all(tasks);
    
    const succeeded = results.filter(r => r.status === "Completed").length;
    
    return {
        total: devices.length,
        succeeded: succeeded,
        failed: devices.length - succeeded
    };
});
```

# [PowerShell](#tab/powershell)

```powershell
param($Context)

$device = $Context.Input

# Step 1: Generate certificates
$cert = Invoke-DurableActivity -FunctionName "GenerateCertificate" -Input $device

# Step 2: Register in IoT Hub
$registration = Invoke-DurableActivity -FunctionName "RegisterInIoTHub" -Input @{
    Device = $device
    Cert = $cert
}

# Step 3: Push firmware (with retry for network issues)
$retryOptions = New-DurableRetryOptions `
    -FirstRetryInterval (New-TimeSpan -Minutes 1) `
    -MaxNumberOfAttempts 5

Invoke-DurableActivity -FunctionName "DeployFirmware" `
    -Input @{ Id = $device.Id; ConnectionString = $registration.ConnectionString } `
    -RetryOptions $retryOptions

# Step 4: Configure device settings
Invoke-DurableActivity -FunctionName "ApplyConfiguration" -Input $device

# Step 5: Validate connectivity
$connected = Invoke-DurableActivity -FunctionName "ValidateConnectivity" -Input $device.Id

if (-not $connected) {
    # Create support ticket for manual intervention
    Invoke-DurableActivity -FunctionName "CreateSupportTicket" -Input $device
    
    # Wait for resolution (up to 24 hours)
    $resolved = Wait-DurableExternalEvent -EventName "ConnectivityResolved" `
        -Timeout (New-TimeSpan -Hours 24)
    
    if (-not $resolved) {
        return @{
            Status = "Failed"
            Error = "Connectivity timeout"
        }
    }
}

return @{
    Status = "Completed"
    DeviceId = $device.Id
    ConnectionString = $registration.ConnectionString
}

# Bulk provisioning (separate function)
# param($Context)
# $devices = $Context.Input
# 
# # Fan-out: Provision all devices in parallel
# $tasks = $devices | ForEach-Object {
#     Invoke-DurableSubOrchestrator -FunctionName "ProvisionDevice" -Input $_ -NoWait
# }
# 
# $results = Wait-DurableTask -Task $tasks
# $succeeded = ($results | Where-Object { $_.Status -eq "Completed" }).Count
# 
# return @{
#     Total = $devices.Count
#     Succeeded = $succeeded
#     Failed = $devices.Count - $succeeded
# }
```

# [Java](#tab/java)

```java
@FunctionName("ProvisionDevice")
public ProvisioningResult provisionDevice(
        @DurableOrchestrationTrigger(name = "context") TaskOrchestrationContext context) {
    DeviceInfo device = context.getInput(DeviceInfo.class);
    
    // Step 1: Generate certificates
    Certificate cert = context.callActivity(
        "GenerateCertificate", device, Certificate.class).await();
    
    // Step 2: Register in IoT Hub
    Map<String, Object> registrationInput = Map.of("device", device, "cert", cert);
    DeviceRegistration registration = context.callActivity(
        "RegisterInIoTHub", registrationInput, DeviceRegistration.class).await();
    
    // Step 3: Push firmware (with retry for network issues)
    RetryPolicy retryPolicy = new RetryPolicy(5, Duration.ofMinutes(1));
    TaskOptions retryOptions = TaskOptions.fromRetryPolicy(retryPolicy);
    
    Map<String, Object> firmwareInput = Map.of(
        "id", device.getId(),
        "connectionString", registration.getConnectionString()
    );
    context.callActivity("DeployFirmware", firmwareInput, retryOptions).await();
    
    // Step 4: Configure device settings
    context.callActivity("ApplyConfiguration", device).await();
    
    // Step 5: Validate connectivity
    boolean connected = context.callActivity(
        "ValidateConnectivity", device.getId(), Boolean.class).await();
    
    if (!connected) {
        // Create support ticket for manual intervention
        context.callActivity("CreateSupportTicket", device).await();
        
        // Wait for resolution (up to 24 hours)
        boolean resolved = context.waitForExternalEvent(
            "ConnectivityResolved", Duration.ofHours(24), Boolean.class).await();
        
        if (!resolved)
            return new ProvisioningResult("Failed", null, "Connectivity timeout");
    }
    
    return new ProvisioningResult(
        "Completed", 
        device.getId(), 
        registration.getConnectionString()
    );
}

// Bulk provisioning with fan-out
@FunctionName("BulkProvision")
public BulkResult bulkProvision(
        @DurableOrchestrationTrigger(name = "context") TaskOrchestrationContext context) {
    List<DeviceInfo> devices = context.getInput(
        new TypeReference<List<DeviceInfo>>() {});
    
    // Fan-out: Provision all devices in parallel
    List<Task<ProvisioningResult>> tasks = devices.stream()
        .map(device -> context.callSubOrchestrator(
            "ProvisionDevice", device, ProvisioningResult.class))
        .collect(Collectors.toList());
    
    context.allOf(tasks).await();
    
    long succeeded = tasks.stream()
        .map(Task::await)
        .filter(r -> "Completed".equals(r.getStatus()))
        .count();
    
    return new BulkResult(
        devices.size(),
        (int) succeeded,
        devices.size() - (int) succeeded
    );
}
```

---

### Benefits
- **Scale**: Provision thousands of devices in parallel
- **Reliability**: Retries handle transient network failures
- **Tracking**: Know exactly which devices succeeded or failed
- **Automation**: Minimal manual intervention required

## Media: Video processing pipeline

### The challenge
Media companies need to process uploaded videos through transcoding, thumbnail generation, content moderation, and metadata extraction—handling large files and long processing times.

### The solution

# [C#](#tab/csharp)

```csharp
[Function(nameof(ProcessVideo))]
public async Task<VideoResult> ProcessVideo(
    [OrchestrationTrigger] TaskOrchestrationContext context)
{
    var video = context.GetInput<VideoUpload>();
    
    // Step 1: Validate video file
    var validation = await context.CallActivityAsync<ValidationResult>(
        nameof(ValidateVideo), video);
    
    if (!validation.IsValid)
        return new VideoResult { Status = "Invalid", Errors = validation.Errors };
    
    // Step 2: Start parallel processing
    var transcodeTask = context.CallActivityAsync<TranscodeResult>(
        nameof(TranscodeVideo), new { video, Formats = new[] { "1080p", "720p", "480p" } });
    
    var thumbnailTask = context.CallActivityAsync<ThumbnailResult>(
        nameof(GenerateThumbnails), video);
    
    var moderationTask = context.CallActivityAsync<ModerationResult>(
        nameof(ContentModeration), video);
    
    var metadataTask = context.CallActivityAsync<VideoMetadata>(
        nameof(ExtractMetadata), video);
    
    await Task.WhenAll(transcodeTask, thumbnailTask, moderationTask, metadataTask);
    
    // Step 3: Check moderation results
    if (moderationTask.Result.Flagged)
    {
        await context.CallActivityAsync(nameof(NotifyModerationTeam), new {
            video.Id,
            moderationTask.Result.Reasons
        });
        
        // Wait for human review
        var review = await context.WaitForExternalEvent<ReviewResult>(
            "ModerationReview",
            TimeSpan.FromHours(24));
        
        if (!review.Approved)
        {
            await context.CallActivityAsync(nameof(DeleteVideo), video.Id);
            return new VideoResult { Status = "Rejected" };
        }
    }
    
    // Step 4: Publish to CDN
    var cdnUrls = await context.CallActivityAsync<Dictionary<string, string>>(
        nameof(PublishToCdn), new {
            video.Id,
            transcodeTask.Result.OutputFiles,
            thumbnailTask.Result.Thumbnails
        });
    
    // Step 5: Update database
    await context.CallActivityAsync(nameof(UpdateVideoRecord), new {
        video.Id,
        cdnUrls,
        metadataTask.Result
    });
    
    return new VideoResult {
        Status = "Published",
        StreamingUrls = cdnUrls,
        Metadata = metadataTask.Result
    };
}
```

# [Python](#tab/python)

```python
@app.orchestration_trigger(context_name="context")
def process_video(context):
    video = context.get_input()
    
    # Step 1: Validate video file
    validation = yield context.call_activity("ValidateVideo", video)
    
    if not validation["isValid"]:
        return {"status": "Invalid", "errors": validation["errors"]}
    
    # Step 2: Start parallel processing
    transcode_task = context.call_activity("TranscodeVideo", {
        "video": video,
        "formats": ["1080p", "720p", "480p"]
    })
    
    thumbnail_task = context.call_activity("GenerateThumbnails", video)
    moderation_task = context.call_activity("ContentModeration", video)
    metadata_task = context.call_activity("ExtractMetadata", video)
    
    results = yield context.task_all([
        transcode_task, thumbnail_task, moderation_task, metadata_task
    ])
    transcode_result, thumbnail_result, moderation_result, metadata_result = results
    
    # Step 3: Check moderation results
    if moderation_result["flagged"]:
        yield context.call_activity("NotifyModerationTeam", {
            "id": video["id"],
            "reasons": moderation_result["reasons"]
        })
        
        # Wait for human review
        review = yield context.wait_for_external_event_with_timeout(
            "ModerationReview",
            timedelta(hours=24)
        )
        
        if not review["approved"]:
            yield context.call_activity("DeleteVideo", video["id"])
            return {"status": "Rejected"}
    
    # Step 4: Publish to CDN
    cdn_urls = yield context.call_activity("PublishToCdn", {
        "id": video["id"],
        "outputFiles": transcode_result["outputFiles"],
        "thumbnails": thumbnail_result["thumbnails"]
    })
    
    # Step 5: Update database
    yield context.call_activity("UpdateVideoRecord", {
        "id": video["id"],
        "cdnUrls": cdn_urls,
        "metadata": metadata_result
    })
    
    return {
        "status": "Published",
        "streamingUrls": cdn_urls,
        "metadata": metadata_result
    }
```

# [JavaScript](#tab/javascript)

```javascript
const df = require("durable-functions");

module.exports = df.orchestrator(function* (context) {
    const video = context.df.getInput();
    
    // Step 1: Validate video file
    const validation = yield context.df.callActivity("ValidateVideo", video);
    
    if (!validation.isValid)
        return { status: "Invalid", errors: validation.errors };
    
    // Step 2: Start parallel processing
    const transcodeTask = context.df.callActivity("TranscodeVideo", {
        video: video,
        formats: ["1080p", "720p", "480p"]
    });
    
    const thumbnailTask = context.df.callActivity("GenerateThumbnails", video);
    const moderationTask = context.df.callActivity("ContentModeration", video);
    const metadataTask = context.df.callActivity("ExtractMetadata", video);
    
    const [transcodeResult, thumbnailResult, moderationResult, metadataResult] = 
        yield context.df.Task.all([transcodeTask, thumbnailTask, moderationTask, metadataTask]);
    
    // Step 3: Check moderation results
    if (moderationResult.flagged) {
        yield context.df.callActivity("NotifyModerationTeam", {
            id: video.id,
            reasons: moderationResult.reasons
        });
        
        // Wait for human review
        const timeout = df.DateTime.fromDate(
            new Date(Date.now() + 24 * 60 * 60 * 1000)
        );
        const review = yield context.df.waitForExternalEvent("ModerationReview", timeout);
        
        if (!review.approved) {
            yield context.df.callActivity("DeleteVideo", video.id);
            return { status: "Rejected" };
        }
    }
    
    // Step 4: Publish to CDN
    const cdnUrls = yield context.df.callActivity("PublishToCdn", {
        id: video.id,
        outputFiles: transcodeResult.outputFiles,
        thumbnails: thumbnailResult.thumbnails
    });
    
    // Step 5: Update database
    yield context.df.callActivity("UpdateVideoRecord", {
        id: video.id,
        cdnUrls: cdnUrls,
        metadata: metadataResult
    });
    
    return {
        status: "Published",
        streamingUrls: cdnUrls,
        metadata: metadataResult
    };
});
```

# [PowerShell](#tab/powershell)

```powershell
param($Context)

$video = $Context.Input

# Step 1: Validate video file
$validation = Invoke-DurableActivity -FunctionName "ValidateVideo" -Input $video

if (-not $validation.IsValid) {
    return @{
        Status = "Invalid"
        Errors = $validation.Errors
    }
}

# Step 2: Start parallel processing
$transcodeTask = Start-DurableActivity -FunctionName "TranscodeVideo" `
    -Input @{ Video = $video; Formats = @("1080p", "720p", "480p") } -NoWait

$thumbnailTask = Start-DurableActivity -FunctionName "GenerateThumbnails" -Input $video -NoWait
$moderationTask = Start-DurableActivity -FunctionName "ContentModeration" -Input $video -NoWait
$metadataTask = Start-DurableActivity -FunctionName "ExtractMetadata" -Input $video -NoWait

$results = Wait-DurableTask -Task @($transcodeTask, $thumbnailTask, $moderationTask, $metadataTask)
$transcodeResult = $results[0]
$thumbnailResult = $results[1]
$moderationResult = $results[2]
$metadataResult = $results[3]

# Step 3: Check moderation results
if ($moderationResult.Flagged) {
    Invoke-DurableActivity -FunctionName "NotifyModerationTeam" -Input @{
        Id = $video.Id
        Reasons = $moderationResult.Reasons
    }
    
    # Wait for human review
    $review = Wait-DurableExternalEvent -EventName "ModerationReview" `
        -Timeout (New-TimeSpan -Hours 24)
    
    if (-not $review.Approved) {
        Invoke-DurableActivity -FunctionName "DeleteVideo" -Input $video.Id
        return @{ Status = "Rejected" }
    }
}

# Step 4: Publish to CDN
$cdnUrls = Invoke-DurableActivity -FunctionName "PublishToCdn" -Input @{
    Id = $video.Id
    OutputFiles = $transcodeResult.OutputFiles
    Thumbnails = $thumbnailResult.Thumbnails
}

# Step 5: Update database
Invoke-DurableActivity -FunctionName "UpdateVideoRecord" -Input @{
    Id = $video.Id
    CdnUrls = $cdnUrls
    Metadata = $metadataResult
}

return @{
    Status = "Published"
    StreamingUrls = $cdnUrls
    Metadata = $metadataResult
}
```

# [Java](#tab/java)

```java
@FunctionName("ProcessVideo")
public VideoResult processVideo(
        @DurableOrchestrationTrigger(name = "context") TaskOrchestrationContext context) {
    VideoUpload video = context.getInput(VideoUpload.class);
    
    // Step 1: Validate video file
    ValidationResult validation = context.callActivity(
        "ValidateVideo", video, ValidationResult.class).await();
    
    if (!validation.isValid())
        return new VideoResult("Invalid", validation.getErrors(), null, null);
    
    // Step 2: Start parallel processing
    Task<TranscodeResult> transcodeTask = context.callActivity(
        "TranscodeVideo",
        Map.of("video", video, "formats", List.of("1080p", "720p", "480p")),
        TranscodeResult.class
    );
    
    Task<ThumbnailResult> thumbnailTask = context.callActivity(
        "GenerateThumbnails", video, ThumbnailResult.class);
    
    Task<ModerationResult> moderationTask = context.callActivity(
        "ContentModeration", video, ModerationResult.class);
    
    Task<VideoMetadata> metadataTask = context.callActivity(
        "ExtractMetadata", video, VideoMetadata.class);
    
    context.allOf(List.of(transcodeTask, thumbnailTask, moderationTask, metadataTask)).await();
    
    // Step 3: Check moderation results
    ModerationResult moderationResult = moderationTask.await();
    if (moderationResult.isFlagged()) {
        context.callActivity("NotifyModerationTeam", Map.of(
            "id", video.getId(),
            "reasons", moderationResult.getReasons()
        )).await();
        
        // Wait for human review
        ReviewResult review = context.waitForExternalEvent(
            "ModerationReview", Duration.ofHours(24), ReviewResult.class).await();
        
        if (!review.isApproved()) {
            context.callActivity("DeleteVideo", video.getId()).await();
            return new VideoResult("Rejected", null, null, null);
        }
    }
    
    // Step 4: Publish to CDN
    TranscodeResult transcodeResult = transcodeTask.await();
    ThumbnailResult thumbnailResult = thumbnailTask.await();
    
    Map<String, String> cdnUrls = context.callActivity("PublishToCdn", Map.of(
        "id", video.getId(),
        "outputFiles", transcodeResult.getOutputFiles(),
        "thumbnails", thumbnailResult.getThumbnails()
    ), new TypeReference<Map<String, String>>() {}).await();
    
    // Step 5: Update database
    VideoMetadata metadata = metadataTask.await();
    context.callActivity("UpdateVideoRecord", Map.of(
        "id", video.getId(),
        "cdnUrls", cdnUrls,
        "metadata", metadata
    )).await();
    
    return new VideoResult("Published", null, cdnUrls, metadata);
}
```

---

### Benefits
- **Parallel processing**: Transcoding, thumbnails, and moderation run simultaneously
- **Content safety**: Built-in moderation workflow
- **Cost efficiency**: Only pay for actual processing time
- **Resumability**: Large file processing survives interruptions

## Common patterns across use cases

| Pattern | Description | Example Use Cases |
|---------|-------------|-------------------|
| **Sequential Steps** | Execute activities in order | Order processing, loan approval |
| **Parallel Fan-out** | Run multiple activities simultaneously | Device provisioning, video processing |
| **Human Approval** | Wait for external events | Patient onboarding, content moderation |
| **Saga/Compensation** | Undo steps on failure | E-commerce orders, financial transactions |
| **Sub-orchestrations** | Compose complex workflows | Bulk operations, multi-tenant processing |
| **Timers** | Schedule future work | Reminder systems, SLA monitoring |

## Getting started with your use case

1. **Identify the workflow steps** - What activities need to happen?
1. **Determine parallelism** - Which steps can run simultaneously?
1. **Plan for failures** - What compensation logic is needed?
1. **Consider human interaction** - Are there approval steps?
1. **Choose deployment model** - Serverless (Durable Functions) or containers (SDK)?

## Next steps

- [About Azure Durable](durable-functions-overview.md)
- [Orchestrator functions overview](durable-functions-orchestrations.md)
- [Activity functions](durable-functions-activities.md)
- [Error handling](durable-functions-error-handling.md)