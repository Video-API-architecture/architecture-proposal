# RealtyForYou Infrastructure Architecture

> This document summarizes the main infrastructure components and best practices for the RealtyForYou platform, as described in the system-design.md and README.md files.

---

<details>
<summary><strong>Overview</strong></summary>

The RealtyForYou platform leverages AWS cloud infrastructure for scalability, reliability, and security. The architecture is designed to support high availability, low latency, and secure handling of sensitive real estate data and video streams.

</details>

<details>
<summary><strong>Core AWS Services</strong></summary>

| Service                 | Purpose                                                     |
|-------------------------|-------------------------------------------------------------|
| **EC2**                 | Compute for custom workloads, legacy jobs, or admin tasks   |
| **ECS/Fargate**         | Container orchestration for Rails API and background jobs   |
| **RDS (Postgres)**      | Managed relational database for transactional data          |
| **ElastiCache (Redis)** | Caching, session storage, pub/sub for real-time             |
| **S3**                  | Storage for images, video recordings, and static assets     |
| **CloudFront**          | CDN for global, low-latency delivery of static content      |
| **VPC**                 | Isolated, secure network for all resources                  |
| **IAM**                 | Fine-grained access control and secrets management          |
| **CloudWatch**          | Monitoring, logging, and alerting                           |
| **ALB**                 | Application Load Balancer for routing and health checks     |
| **Secrets Manager/SSM** | Secure storage for DB, API, and JWT secrets                 |
| **AWS Chime SDK**       | Real-time video, audio, and screen sharing for virtual tours|

</details>

<details>
<summary><strong>Network & Security</strong></summary>

| Component | Description |
|-----------|-------------|
| **VPC** | Public/private subnets for isolation |
| **Security Groups** | Restrict traffic to only necessary ports/services |
| **IAM Roles/Policies** | Least-privilege access, including permissions for Chime SDK actions (e.g., `chime:CreateMeeting`, `chime:CreateAttendee`, `chime:CreateMediaCapturePipeline`) |
| **TLS/HTTPS** | Enforced for all endpoints |
| **S3 Buckets** | Encrypted with SSE-KMS, including those used for Chime media pipeline outputs (recordings, transcriptions) |
| **RDS** | In private subnets, Multi-AZ enabled |
| **API Rate Limiting** | WAF for DDoS protection |
| **Audit Logging** | Via CloudTrail |

</details>

<details>
<summary><strong>Scalability & High Availability</strong></summary>

| Component | Description |
|-----------|-------------|
| **ECS/Fargate** | Auto-scales based on ALB request count and custom metrics |
| **RDS** | Multi-AZ deployment with automated failover |
| **Read Replicas** | For scaling read-heavy workloads |
| **Redis** | Caching and pub/sub, with Multi-AZ support |
| **S3** | Cross-region replication for durability |
| **ALB** | Distributes traffic and performs health checks |
| **Stateless containers** | Easy scaling and blue/green deployments |
| **AWS Chime SDK** | Serverless and scales automatically; backend must handle meeting management at scale |

</details>

<details>
<summary><strong>Monitoring & Observability</strong></summary>

| Component | Purpose |
|-----------|---------|
| **CloudWatch** | Metrics, logs, and alarms |
| **DataDog** | APM and business KPIs |
| **Sentry** | Error tracking |
| **PagerDuty** | Alerting and incident response |
| **Grafana** | Dashboards for real-time and historical metrics |
| **AWS Chime SDK** | Usage and media pipeline status can be monitored via CloudWatch |

</details>

<details>
<summary><strong>Deployment & CI/CD</strong></summary>

| Component | Purpose |
|-----------|---------|
| **GitHub Actions** | Automated testing and deployment |
| **Docker** | Containerization |
| **Terraform** | Infrastructure as Code (IaC) |
| **Blue-Green Deployments** | Zero-downtime releases |
| **Feature Flags** | Safe rollout of risky features |
| **Secrets managed** | Via AWS Secrets Manager and SSM |

</details>

<details>
<summary><strong>Disaster Recovery & Backups</strong></summary>

| Component | Description |
|-----------|-------------|
| **Daily RDS snapshots** | 7-day retention |
| **S3 cross-region replication** | For data durability |
| **Automated ECS task restarts** | For service recovery |

</details>

<details>
<summary><strong>Best Practices Summary</strong></summary>

| Practice | Description |
|----------|-------------|
| **Private subnets** | Use for all sensitive resources |
| **Encryption** | Enforce at rest and in transit |
| **Least-privilege IAM** | Apply everywhere |
| **Auto-scaling & Multi-AZ** | Use for all critical services |
| **Monitoring** | CloudWatch, DataDog, and Sentry |
| **CI/CD & IaC** | Automate deployments and rollbacks |
| **Disaster recovery** | Test procedures quarterly |

</details>

<details>
<summary><strong>AWS Chime SDK Infrastructure Notes</strong></summary>

| Aspect | Description |
|--------|-------------|
| **Service** | AWS Chime SDK is used for real-time video, audio, and screen sharing |
| **Integration** | Backend (ECS/Fargate) communicates with Chime SDK via AWS SDK/REST API |
| **IAM** | ECS/EC2 roles require permissions for Chime SDK actions (e.g., `chime:CreateMeeting`, `chime:CreateAttendee`, `chime:CreateMediaCapturePipeline`) |
| **Media Pipelines** | Recordings and transcriptions are stored in encrypted S3 buckets |
| **Scaling** | Chime SDK is serverless and scales automatically; backend must handle meeting management at scale |
| **Monitoring** | Use CloudWatch for logging and monitoring Chime SDK API usage and media pipeline status |
| **Quotas** | Be aware of Chime SDK quotas for meetings and attendees ([see docs](https://docs.aws.amazon.com/chime-sdk/latest/dg/quotas.html)) |
| **References** | [Chime SDK API Reference](https://docs.aws.amazon.com/chime-sdk/latest/APIReference/welcome.html)<br>[Chime SDK Developer Guide](https://docs.aws.amazon.com/chime-sdk/latest/dg/what-is-chime-sdk.html) |

</details>
