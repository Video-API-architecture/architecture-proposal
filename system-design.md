# RealtyForYou System Design

This document provides a high-level overview of the RealtyForYou platform architecture, focusing on system context, main components, data flow, and integration points. For detailed technology, implementation, and code, see the dedicated architecture documents for each subsystem.

---

<details>
<summary>🗺️ System Context & Overview</summary>

RealtyForYou is a cloud-native platform for virtual real estate tours, enabling realtors and buyers to connect via live video, manage properties, and schedule appointments. The system is designed for high availability, scalability, and security, leveraging AWS-managed services and a modular architecture.

- **Users:** Realtors, buyers, and admins
- **Core Use Cases:** Property listing/search, appointment scheduling, real-time video tours, analytics
- **Deployment:** Multi-AZ, containerized, CI/CD-driven

</details>

<details>
<summary>🏗️ Main Components</summary>

| Component         | Description                                                      | Details/Docs                                      |
|-------------------|------------------------------------------------------------------|---------------------------------------------------|
| **Frontend (Web)**| React SPA for user interaction, property browsing, and tours     | [FRONTEND_ARCHITECTURE.md](architecture/FRONTEND_ARCHITECTURE.md) |
| **Mobile App**    | React Native app for mobile tour participation                   | [MOBILE_ARCHITECTURE.md](architecture/MOBILE_ARCHITECTURE.md)     |
| **Backend API**   | Ruby on Rails API for business logic, data, and integrations     | [BACKEND_ARCHITECTURE.md](architecture/BACKEND_ARCHITECTURE.md)   |
| **Infrastructure**| AWS-based, containerized, secure, and scalable cloud infra       | [INFRA_ARCHITECTURE.md](architecture/INFRA_ARCHITECTURE.md)       |

</details>

<details>
<summary>🔗 Data Flow & Integration</summary>

1. **User requests** (web/mobile) are routed via AWS ALB to the Rails API.
2. **API** handles authentication, business logic, and data access (Postgres, Redis).
3. **Video tours** are powered by AWS Chime SDK, orchestrated by the backend, and joined by clients via SDKs.
4. **Media (images, recordings)** are stored in S3 and delivered via CloudFront.
5. **Notifications, analytics, and background jobs** are managed by backend services and AWS integrations.

![System Data Model Diagram](./imgs/data-model.png)

</details>

<details>
<summary>🛡️ Cross-Cutting Concerns</summary>

- **Security & Compliance:**
  - JWT authentication, RBAC, encrypted data at rest/in transit, audit logging
  - GDPR, SOC 2, and real estate industry compliance
- **Scalability & Availability:**
  - Auto-scaling containers, multi-AZ RDS, stateless services, CDN
- **Observability:**
  - CloudWatch, DataDog, Sentry, Grafana dashboards, alerting
- **DevOps & CI/CD:**
  - Automated testing, blue-green deployments, IaC with Terraform

</details>

<details>
<summary>📚 Where to Find More</summary>

- **Frontend Architecture:** [FRONTEND_ARCHITECTURE.md](architecture/FRONTEND_ARCHITECTURE.md)
- **Backend Architecture:** [BACKEND_ARCHITECTURE.md](architecture/BACKEND_ARCHITECTURE.md)
- **Infrastructure Architecture:** [INFRA_ARCHITECTURE.md](architecture/INFRA_ARCHITECTURE.md)
- **Mobile Architecture:** [MOBILE_ARCHITECTURE.md](architecture/MOBILE_ARCHITECTURE.md)

For detailed API endpoints, data models, technology choices, and integration patterns, please refer to the above documents.

</details>
