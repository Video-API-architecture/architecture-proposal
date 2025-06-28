# RealtyForYou Infrastructure Architecture

> This document summarizes the main infrastructure components and best practices for the RealtyForYou platform, as described in the system-design.md and README.md files.

---

<details>
<summary><strong>🌍 Overview</strong></summary>

The RealtyForYou platform leverages AWS cloud infrastructure for scalability, reliability, and security. The architecture is designed to support high availability, low latency, and secure handling of sensitive real estate data and video streams.

</details>

<details>
<summary><strong>🏗️ Core AWS Services</strong></summary>

| Service           | Purpose                                                      |
|-------------------|-------------------------------------------------------------|
| **EC2**           | Compute for custom workloads, legacy jobs, or admin tasks   |
| **ECS/Fargate**   | Container orchestration for Rails API and background jobs   |
| **RDS (Postgres)**| Managed relational database for transactional data          |
| **ElastiCache (Redis)** | Caching, session storage, pub/sub for real-time       |
| **S3**            | Storage for images, video recordings, and static assets     |
| **CloudFront**    | CDN for global, low-latency delivery of static content      |
| **VPC**           | Isolated, secure network for all resources                  |
| **IAM**           | Fine-grained access control and secrets management          |
| **CloudWatch**    | Monitoring, logging, and alerting                          |
| **ALB**           | Application Load Balancer for routing and health checks     |
| **Secrets Manager/SSM** | Secure storage for DB, API, and JWT secrets          |
| **AWS Chime SDK** | Real-time video, audio, and screen sharing for virtual tours|

</details>

<details>
<summary><strong>🔒 Network & Security</strong></summary>

- **VPC** with public/private subnets for isolation
- **Security Groups** restrict traffic to only necessary ports/services
- **IAM Roles/Policies** for least-privilege access, including permissions for Chime SDK actions (e.g., `chime:CreateMeeting`, `chime:CreateAttendee`, `chime:CreateMediaCapturePipeline`)
- **TLS/HTTPS** enforced for all endpoints
- **S3 Buckets** encrypted with SSE-KMS, including those used for Chime media pipeline outputs (recordings, transcriptions)
- **RDS** in private subnets, Multi-AZ enabled
- **API Rate Limiting** and WAF for DDoS protection
- **Audit Logging** via CloudTrail

</details>

<details>
<summary><strong>📈 Scalability & High Availability</strong></summary>

- **ECS/Fargate** auto-scales based on ALB request count and custom metrics
- **RDS** Multi-AZ deployment with automated failover
- **Read Replicas** for scaling read-heavy workloads
- **Redis** for caching and pub/sub, with Multi-AZ support
- **S3** with cross-region replication for durability
- **ALB** distributes traffic and performs health checks
- **Stateless containers** for easy scaling and blue/green deployments
- **AWS Chime SDK** is serverless and scales automatically; backend must handle meeting management at scale

</details>

<details>
<summary><strong>📊 Monitoring & Observability</strong></summary>

- **CloudWatch** for metrics, logs, and alarms
- **DataDog** for APM and business KPIs
- **Sentry** for error tracking
- **PagerDuty** for alerting and incident response
- **Fluent Bit** for log aggregation
- **Grafana** dashboards for real-time and historical metrics
- **AWS Chime SDK** usage and media pipeline status can be monitored via CloudWatch

</details>

<details>
<summary><strong>🚀 Deployment & CI/CD</strong></summary>

- **GitHub Actions** for automated testing and deployment
- **Docker** for containerization
- **Terraform** for Infrastructure as Code (IaC)
- **Blue-Green Deployments** for zero-downtime releases
- **Feature Flags** for safe rollout of risky features
- **Secrets managed** via AWS Secrets Manager and SSM

</details>

<details>
<summary><strong>💾 Disaster Recovery & Backups</strong></summary>

- **Daily RDS snapshots** (7-day retention)
- **S3 cross-region replication**
- **Automated ECS task restarts**
- **RTO < 60 min, RPO < 15 min**
- **Immutable logs** stored in Glacier

</details>

<details>
<summary><strong>🖼️ Diagram</strong></summary>

![Infrastructure Diagram](./imgs/system-design-diagram.png)

> _Placeholder: See system-design-diagram.png for a high-level view of the infrastructure._

</details>

<details>
<summary><strong>✅ Best Practices Summary</strong></summary>

- Use **private subnets** for all sensitive resources
- Enforce **encryption at rest and in transit**
- Apply **least-privilege IAM** everywhere
- Use **auto-scaling** and **multi-AZ** for all critical services
- Monitor with **CloudWatch**, **DataDog**, and **Sentry**
- Automate deployments and rollbacks with **CI/CD** and **IaC**
- Regularly test **disaster recovery** and **backup** procedures

</details>

<details>
<summary><strong>🎥 AWS Chime SDK Infrastructure Notes</strong></summary>

- **Service:** AWS Chime SDK is used for real-time video, audio, and screen sharing.
- **Integration:** Backend (ECS/Fargate) communicates with Chime SDK via AWS SDK/REST API.
- **IAM:** ECS/EC2 roles require permissions for Chime SDK actions (e.g., `chime:CreateMeeting`, `chime:CreateAttendee`, `chime:CreateMediaCapturePipeline`).
- **Media Pipelines:** Recordings and transcriptions are stored in encrypted S3 buckets.
- **Scaling:** Chime SDK is serverless and scales automatically; backend must handle meeting management at scale.
- **Monitoring:** Use CloudWatch for logging and monitoring Chime SDK API usage and media pipeline status.
- **Quotas:** Be aware of Chime SDK quotas for meetings and attendees ([see docs](https://docs.aws.amazon.com/chime-sdk/latest/dg/quotas.html)).
- **References:**
  - [Chime SDK API Reference](https://docs.aws.amazon.com/chime-sdk/latest/APIReference/welcome.html)
  - [Chime SDK Developer Guide](https://docs.aws.amazon.com/chime-sdk/latest/dg/what-is-chime-sdk.html)

</details> 