# RealtyForYou Infrastructure Architecture

> This document summarizes the main infrastructure components and best practices for the RealtyForYou platform, as described in the system-design.md and README.md files.

## Table of Contents
- [Overview](#overview)
- [Core AWS Services](#core-aws-services)
- [Network & Security](#network--security)
- [Scalability & High Availability](#scalability--high-availability)
- [Monitoring & Observability](#monitoring--observability)
- [Deployment & CI/CD](#deployment--cicd)
- [Disaster Recovery & Backups](#disaster-recovery--backups)
- [Diagram](#diagram)
- [Best Practices Summary](#best-practices-summary)

---

<details>
<summary>Overview</summary>

The RealtyForYou platform leverages AWS cloud infrastructure for scalability, reliability, and security. The architecture is designed to support high availability, low latency, and secure handling of sensitive real estate data and video streams.

</details>

<details>
<summary>Core AWS Services</summary>

| Service         | Purpose                                                      |
|-----------------|-------------------------------------------------------------|
| **EC2**         | Compute for custom workloads, legacy jobs, or admin tasks   |
| **ECS/Fargate** | Container orchestration for Rails API and background jobs   |
| **RDS (Postgres)** | Managed relational database for transactional data      |
| **ElastiCache (Redis)** | Caching, session storage, pub/sub for real-time   |
| **S3**          | Storage for images, video recordings, and static assets     |
| **CloudFront**  | CDN for global, low-latency delivery of static content      |
| **VPC**         | Isolated, secure network for all resources                  |
| **IAM**         | Fine-grained access control and secrets management          |
| **CloudWatch**  | Monitoring, logging, and alerting                          |
| **ALB**         | Application Load Balancer for routing and health checks     |
| **Secrets Manager/SSM** | Secure storage for DB, API, and JWT secrets        |

</details>

<details>
<summary>Network & Security</summary>

- **VPC** with public/private subnets for isolation
- **Security Groups** restrict traffic to only necessary ports/services
- **IAM Roles/Policies** for least-privilege access
- **TLS/HTTPS** enforced for all endpoints
- **S3 Buckets** encrypted with SSE-KMS
- **RDS** in private subnets, Multi-AZ enabled
- **API Rate Limiting** and WAF for DDoS protection
- **Audit Logging** via CloudTrail

</details>

<details>
<summary>Scalability & High Availability</summary>

- **ECS/Fargate** auto-scales based on ALB request count and custom metrics
- **RDS** Multi-AZ deployment with automated failover
- **Read Replicas** for scaling read-heavy workloads
- **Redis** for caching and pub/sub, with Multi-AZ support
- **S3** with cross-region replication for durability
- **ALB** distributes traffic and performs health checks
- **Stateless containers** for easy scaling and blue/green deployments

</details>

<details>
<summary>Monitoring & Observability</summary>

- **CloudWatch** for metrics, logs, and alarms
- **DataDog** for APM and business KPIs
- **Sentry** for error tracking
- **PagerDuty** for alerting and incident response
- **Fluent Bit** for log aggregation
- **Grafana** dashboards for real-time and historical metrics

</details>

<details>
<summary>Deployment & CI/CD</summary>

- **GitHub Actions** for automated testing and deployment
- **Docker** for containerization
- **Terraform** for Infrastructure as Code (IaC)
- **Blue-Green Deployments** for zero-downtime releases
- **Feature Flags** for safe rollout of risky features
- **Secrets managed** via AWS Secrets Manager and SSM

</details>

<details>
<summary>Disaster Recovery & Backups</summary>

- **Daily RDS snapshots** (7-day retention)
- **S3 cross-region replication**
- **Automated ECS task restarts**
- **RTO < 60 min, RPO < 15 min**
- **Immutable logs** stored in Glacier

</details>

<details>
<summary>Diagram</summary>

![Infrastructure Diagram](./imgs/system-design-diagram.png)

> _Placeholder: See system-design-diagram.png for a high-level view of the infrastructure._

</details>

<details>
<summary>Best Practices Summary</summary>

- Use **private subnets** for all sensitive resources
- Enforce **encryption at rest and in transit**
- Apply **least-privilege IAM** everywhere
- Use **auto-scaling** and **multi-AZ** for all critical services
- Monitor with **CloudWatch**, **DataDog**, and **Sentry**
- Automate deployments and rollbacks with **CI/CD** and **IaC**
- Regularly test **disaster recovery** and **backup** procedures

</details> 