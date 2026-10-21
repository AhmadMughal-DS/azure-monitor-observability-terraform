# Azure Monitor Observability (Terraform)

> Centralized monitoring on Azure: Log Analytics + Application Insights with a log-based alert and email action group — provisioned with Terraform.
> **Author:** Muhammad Ahmad · **IaC:** Terraform · **Cloud:** Azure

![Terraform CI](https://github.com/AhmadMughal-DS/azure-monitor-observability-terraform/actions/workflows/terraform.yml/badge.svg)
![Terraform](https://img.shields.io/badge/Terraform-1.6%2B-7B42BC?logo=terraform&logoColor=white)
![Security](https://img.shields.io/badge/scanned-tfsec%20%7C%20checkov-success)
![Azure](https://img.shields.io/badge/Azure-Monitor%20%7C%20Log%20Analytics%20%7C%20App%20Insights-0078D4?logo=microsoftazure&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📌 Overview

- A **Log Analytics workspace** is the central log/metric store.
- **Application Insights** (workspace-based) collects app telemetry you wire into your services.
- A **scheduled query alert** runs a KQL query (exception count) every 5 minutes.
- When it fires, an **action group** emails the on-call address.

Drop the App Insights connection string into any app to start shipping telemetry here.

## 🏗️ Architecture

> 🎨 **Interactive diagram (industry-standard icons):** [open in Lucid — page 20](https://lucid.app/lucidchart/3da75ce3-ea66-4296-81b3-00d20a60435b/edit)

```mermaid
flowchart LR
    App([Your Apps])
    AI[Application Insights]
    LAW[Log Analytics Workspace]
    Alert[Scheduled Query Alert]
    AG[Action Group]
    Email([On-call Email])

    App --> AI
    AI --> LAW
    LAW --> Alert
    Alert -->|fires| AG
    AG --> Email
```

## 🚀 Deploy

```bash
cd terraform
az login
terraform init
terraform apply -var="alert_email=you@example.com"
```

## 🧹 Clean up

```bash
terraform destroy
```

## 💰 Cost note

Log Analytics bills per GB ingested; a small workspace with short retention is inexpensive.

## 🔐 Production hardening (next steps)

- Add **workbooks** and a shared dashboard.
- Add **metric alerts** (availability, latency) and **SLO** tracking.
- Route critical alerts to **PagerDuty / Teams** via the action group.

---

*Built and maintained by **Muhammad Ahmad**.*
