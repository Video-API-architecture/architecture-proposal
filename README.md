# RealtyForYou Architecture Proposal

This document presents a comprehensive System Design solution for a video streaming application that facilitates live video calls between realtors and clients. The platform enables virtual property tours, allowing realtors to showcase properties remotely while providing clients with immersive viewing experiences.

<details>
<summary><strong>Executive Summary</strong></summary>

This document presents a comprehensive architecture proposal for a video streaming application designed to facilitate live video calls between realtors and clients. The solution leverages modern web technologies and cloud services to deliver a robust, scalable, and user-friendly platform.

### Key Highlights

| Feature | Description | Technology |
|---------|-------------|------------|
| Real-time Video Communication  | High-quality video streaming with low latency | AWS Chime SDK |
| Multi-platform Support         | Web and mobile applications | React + React Native |
| Scalable Backend                | Robust API with flexible querying | Ruby on Rails |
| Cloud-Native Architecture      | Scalable infrastructure with containerization | AWS ECS/Fargate |
| Comprehensive Analytics        | Multi-platform tracking and user behavior analysis | Mixpanel + GA4 + Hotjar |

</details>

<details>
<summary><strong>Product View</strong></summary>

### Expected Business Impact

The video streaming platform is expected to revolutionize the real estate industry by:

| Impact Area | Description | Expected Outcome |
|-------------|-------------|------------------|
| Increasing Conversion Rates | Direct video communication improves client engagement and trust | Higher tour-to-sale conversion |
| Reducing Travel Time | Virtual property tours save time for both realtors and clients | 60% reduction in travel costs |
| Expanding Market Reach | Rural and remote clients can access properties without physical travel | 3x increase in potential client base |
| Improving Customer Satisfaction | Real-time interaction provides immediate answers and personalized experience | 85% customer satisfaction score |

### Assumptions and Questions Raised

#### Key Assumptions

| Assumption | Description | Impact |
|------------|-------------|--------|
| Stable Internet Connectivity | Users have access to reliable internet | Core functionality depends on connectivity |
| Mobile Device Support | Devices support video streaming capabilities | Ensures broad device compatibility |
| Video Communication Comfort | Users are comfortable with video communication | Adoption and user experience |
| Digital Transformation | Real estate market embraces digital solutions | Market acceptance and growth |

#### Questions to Address

| Question | Category | Priority |
|----------|----------|----------|
| What is the minimum bandwidth requirement for video calls? | **Technical** | High |
| How do we handle poor connectivity scenarios? | **Technical** | High |
| What security measures are needed for sensitive property information? | **Security** | Critical |
| How do we ensure compliance with real estate regulations? | **Compliance** | Critical |

#### Questions We'd Ask The Business

| Question | Category | Business Impact |
|----------|----------|-----------------|
| What pricing tiers or revenue model do we target? | **Revenue** | Critical for business model |
| Do we require content-licensing for recorded tours? | **Legal** | Compliance and IP protection |
| Any legal/branding constraints for property media? | **Legal** | Risk mitigation |
| Preferred KYC / ID-verification vendor for realtor or clients onboarding? | **Security** | Trust and compliance |
| SLA penalties. Do we include credits for downtime? | **Operations** | Customer satisfaction |
| What data-retention policy for recordings? | **Compliance** | Legal and privacy requirements |

### Constraint Analysis & Mitigation

#### Ambitious Timelines

| Constraint | Description | Mitigation Strategy |
|------------|-------------|-------------------|
| Rapid Development Timeline | Market entry pressure with complex requirements | Agile methodology with weekly sprints |
| Complex Video Streaming | Real-time video communication requirements | Leverage AWS Chime SDK for managed solution |
| Multi-platform Development | Web and mobile app development needs | Parallel development tracks with shared components |

#### Rural Connectivity Challenges

| Constraint | Description | Mitigation Strategy |
|------------|-------------|-------------------|
| Limited Bandwidth | Rural areas have poor internet connectivity | Adaptive video quality based on connection speed |
| Unstable Connections | Intermittent internet connectivity | Offline mode for property information |
| Mobile Data Limitations | Users have limited mobile data plans | Data compression and optimization techniques |

### Team & Process

### Team Execution Model

#### Tech/Product/Design Sync Rhythm

| Meeting Type | Frequency | Duration | Purpose |
|--------------|-----------|----------|---------|
| Daily Standups | Daily | 15 minutes | Team sync and blocker identification |
| Weekly Sprint Planning | Weekly | 1 hour | Feature prioritization and task assignment |
| Bi-weekly Demos | Every 2 weeks | 30 minutes | Showcase completed features to stakeholders |
| Monthly Retrospectives | Monthly | 1 hour | Process improvement and team feedback |


#### Product-Engineering-Business Impact/Effort Matrix

To prioritize tasks and features in this project, use the matrix below to score each item by its impact and effort across Product, Engineering, and Business dimensions between the stakeholders. This helps ensure we focus on high-impact, manageable-effort work that aligns with both user and business goals.

| Task/Feature                        | Product Impact | Engineering Effort | Business Impact | Business Effort | Priority (suggested) |
|-------------------------------------|:--------------:|:-----------------:|:--------------:|:---------------:|:--------------------:|
| 1:1 Video Calls (MVP)               |     High       |      Medium       |     High       |      Low        |        High          |
| User Authentication & Profiles      |     High       |      Low          |     High       |      Low        |        High          |
| Property Listings (CRUD)            |    Medium      |      Low          |    Medium      |      Low        |       Medium         |
| Tour Scheduling/Booking             |     High       |      Medium       |    Medium      |      Medium     |        High          |
| Dashboard Shell/Layout              |    Medium      |      Low          |    Medium      |      Low        |       Medium         |
| Analytics/Event Tracking (MVP)      |    Medium      |      Medium       |     High       |     Medium      |       Medium         |
| Multi-party Video Calls             |    Medium      |      High         |     High       |      Medium     |       Medium         |
| Advanced Property Search/Filters    |    Medium      |      Medium       |    Medium      |      Medium     |       Medium         |
| Recording & Playback                |    Medium      |      High         |     High       |      Medium     |       Medium         |
| Mobile App (React Native)           |     High       |      High         |     High       |      High       |       Medium         |
| Responsive UI/UX Enhancements       |    Medium      |      Medium       |    Medium      |      Low        |       Medium         |
| Error Handling/Offline Support      |    Medium      |      Medium       |    Medium      |      Low        |       Medium         |
| Analytics Dashboards (Realtor)      |    Medium      |      Medium       |     High       |     Medium      |       Medium         |
| End-to-End Testing/QA               |     High       |      Medium       |     High       |      Medium     |        High          |
| Security Review/Compliance          |     High       |      Medium       |     High       |      High       |        High          |
| Performance Optimizations           |    Medium      |      Medium       |    Medium      |      Low        |       Medium         |
| Final Bug Fixes/Go-Live             |     High       |      Medium       |     High       |      Medium     |        High          |
| AI-powered Recommendations (Post)   |    Medium      |      High         |     High       |      Medium     |        Low           |
| Advanced Analytics/Reporting (Post) |    Medium      |      High         |     High       |      Medium     |        Low           |

- **Impact:** High/Medium/Low (relative to user value or business outcome)
- **Effort:** High/Medium/Low (relative to resources, complexity, or time)
- **Priority:** Use the matrix to discuss and align on what to tackle first (e.g., High Impact + Low Effort = Quick Win)

_Note: These are initial estimates based on the delivery plan and should be refined collaboratively by the team during planning and sprint reviews._

#### Shipping Milestones (8 Weeks, High-Impact First)

> Given our 2-month timeline and a small engineering team, milestones are prioritized for business impact and demo readiness. Each milestone concludes with a demo to stakeholders.

---

### Week 1-2: Core Foundations & Authentication

| Task | Description | Status |
|------|-------------|--------|
| Project Setup | Repositories, CI/CD, environments (staging/production) | Core infrastructure |
| User Authentication | Buyers & realtors with forgot-password flow | Essential security |
| Profile Management | Basic user profile management | User experience |
| Homepage Hero | Call-to-action (register) implementation | Marketing conversion |
| Minimal UI | Login, registration, dashboard shell | Core user interface |

**Demo:** Login, registration, password reset, and homepage navigation

**Acceptance Criteria:**
- Users can register, log in and reset their passwords via email link
- Homepage hero & registration CTA are visible
- Dashboard shell is accessible after login
- CI/CD pipeline is operational

### Week 3-4: Live Video Tour MVP & Dashboards (Phase I)

| Task | Description | Status |
|------|-------------|--------|
| AWS Chime SDK | 1:1 live video calls integration | Core video functionality |
| Tour Scheduling | Schedule and join a tour (buyer requests, realtor hosts) | Booking system |
| Dashboard Widgets | Upcoming appointments (buyer & realtor) | User experience |
| Property Listings | Basic property listing (static/dummy data) | Content management |

**Demo:** End-to-end video call between buyer and realtor + dashboards showing upcoming tours

**Acceptance Criteria:**
- Users can request and join a video tour
- Upcoming tours appear in buyer & realtor dashboards
- Video call works between buyer and realtor
- Basic property data is visible

### Week 5: Property Listings, Booking & History

| Task | Description | Status |
|------|-------------|--------|
| CRUD for property listings | Admin/realtor | Core functionality |
| Buyers can browse/search properties and request tours | Buyer | User experience |
| Calendar integration for tour scheduling | Buyer | Booking system |
| Tour history view for buyers | Buyer | User experience |

**Demo:** Buyer books a tour from a real property listing and views it in history

**Acceptance Criteria:**
- Realtors can create, update, and delete property listings
- Buyers can browse/search and book tours
- Calendar integration is functional
- Buyers can view completed tours in their history

### Week 6: Analytics Integration & Enhanced Features

| Task | Description | Status |
|------|-------------|--------|
| **GA4 Setup & Configuration** | Google Analytics 4 implementation | Analytics |
| **Mixpanel Integration** | Event tracking and user behavior analysis | Analytics |
| **Hotjar Setup** | Heatmaps, session recordings, feedback widgets | Analytics |
| **Property Detail Pages** | Public SEO pages for property listings | SEO & Lead Generation |
| **Tour Library/Archive** | View completed tours with recordings and transcripts | User Retention |
| **Email Notifications** | Tour reminders and confirmations | User Experience |

**Demo:** Analytics dashboard showing real-time events + Property detail page + Tour library

**Acceptance Criteria:**
- GA4 tracks page views, user sessions, and conversions
- Mixpanel captures key business events (tour requests, bookings, completions)
- Hotjar provides heatmaps and session recordings
- Public property pages are SEO-optimized and drive lead generation
- Users can view completed tours with AI-generated summaries
- Email notifications are sent for tour confirmations and reminders

### Week 7: Mobile & UX Enhancements

| Task | Description | Status |
|------|-------------|--------|
| Polish mobile experience | React Native | User experience |
| Responsive UI improvements | React Native | User experience |
| Error handling, loading states, and basic offline support | React Native | User experience |

**Demo:** Mobile tour booking and video call

**Acceptance Criteria:**
- Mobile app supports booking and video calls
- UI is responsive and user-friendly
- App handles errors and offline scenarios gracefully

### Week 8: Polish, QA, and Launch

| Task | Description | Status |
|------|-------------|--------|
| End-to-end testing | Manual + automated | Quality assurance |
| Performance optimizations | Video, API, UI | User experience |
| Security review | Authentication, data privacy | Security |
| Final bug fixes, documentation, and go-live | Documentation, testing | Product readiness |

**Demo:** Full product walkthrough and launch readiness

**Acceptance Criteria:**
- All critical bugs are fixed
- Product passes QA and security review
- Documentation is complete
- Product is ready for launch

---

### Delivery Plan

| Phase | Description | Key Features | Timeline |
|-------|-------------|--------------|----------|
| Phase 1 (MVP) | Core video calling functionality | Basic video calling between two users, Simple property listing display, User authentication and profiles | Weeks 1-4 |
| Phase 2 (Enhanced) | Advanced features and improvements | Advanced property search and filters, Recording and playback features. Offline mode support. | Weeks 5-8 |
| Phase 3 (Advanced) | AI and advanced capabilities | AI-powered property recommendations, Advanced analytics and reporting. Add super admin features. | Post-launch |

### Mapping: Landing Page Features to Milestones

| Landing Page Feature                      | Milestone (Week)  | Notes/Dependencies                     |
|-------------------------------------------|-------------------|----------------------------------------|
| Homepage Hero & Highlights                |      1-2          | Marketing content; hero video demo     |
| Call-to-Action (Register)                 |      1-2          | Must align with auth availability      |
| Registration / Login                      |      1-2          | Core authentication                    |
| Forgot Password                           |      1-2          | Part of authentication flows           |
| Dashboard Shell (Layout)                  |      1-2          | Navigation skeleton                    |
| Realtor Dashboard – Property Listings     |      3-5          | Depends on Property Management CRUD    |
| Realtor Dashboard – Upcoming Appointments |      3-4          | Requires scheduling logic              |
| Realtor Dashboard – Users List            |      3-5          | Pulls from User service                |
| User Dashboard – Upcoming Appointments    |      3-4          | Requires booking flow                  |
| User Dashboard – Tour History             |      5-6          | Post-tour data available               |
| Property Management (CRUD)                |      3-5          | Realtors create/update listings        |
| Browse Property Listings (Buyer)          |      3-5          | Uses property listings; search filters |
| Video Call Demo (1:1 Tour)                |      3-4          | AWS Chime integration                  |
| Booking / Scheduling                      |       5           | Calendar integration                   |
| Recent Call History                       |      5-6          | Optional for MVP                       |
| Analytics Integration                     |       6           | GA4, Mixpanel, Hotjar setup            |
| Property Detail Pages                     |       6           | SEO-optimized public pages             |
| Our Library/Archive                       |       6           | Completed tours with AI summaries      |
| Email Notifications**                     |       6           | Tour reminders and confirmations       |
| Testimonials / Highlights                 | Content/Marketing | Requires marketing assets              |

### Product & Delivery Gaps

| Gap                    | Why it matters                                                     | Quick fix                                                                                              |
|------------------------|--------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------|
| Cost model             | Chime minutes, ECS hours, media storage ⇒ bill shock if untracked  | Cost table (Dev/MVP/Scale) |
| Success metrics (SLOs) | Perf targets exist but not customer-facing guarantees              | SLO table (API p95, Call-setup, Video uptime) |
| Regulatory coverage    | Real-estate transactions involve PII & sometimes KYC               | PII/data flow map, retention policy, user self-service, compliance review, audit logs |
| Incident playbooks     | Alerting exists but no documented runbooks                         | Security/outage/data playbooks, roles, automation, post-mortems, internal storage |

#### Cost Model (Rough-Order-of-Magnitude)

| Environment | Monthly cost drivers                                         | Est. USD |
|-------------|--------------------------------------------------------------|----------|
| Dev         | 200 Chime minutes, 2 × ECS t3.small, 50 GB S3                | ~$150    |
| MVP         | 10k Chime minutes, 8 × ECS t3.medium, 500 GB S3              | ~$2,200  |
| Scale (10×) | 100k Chime minutes, 30 × ECS t3.large, 5 TB S3               | ~$17,000 |

**Cost Model Notes:**
- Chime minutes: The largest cost driver, especially as usage scales (live video calls only).
- ECS compute: Scales with user and API load; t3.medium/large instances for backend and jobs.
- S3 storage: Used for property images, documents, and video recordings. S3 is very cost-effective at scale.
- Transcription: The OpenAI Whisper costs are minimal compared to video and compute.

#### Regulatory Coverage

Regulatory compliance is critical for handling KYC and real estate data. The team should:
- Document and enforce data retention/deletion policies
- Provide user self-service for data access/deletion
- Regularly review compliance with GDPR, CCPA, RESA, etc.
- Maintain immutable audit logs for legal requirements

#### Incident Playbooks

Effective incident response minimizes impact and ensures compliance. The team should:
- Define playbooks for security, outage, and data incidents
- Assign clear roles and escalation paths
- Automate alerting and initial triage
- Run post-mortems and update playbooks after incidents
- Store playbooks in an accessible internal location

#### Service Level Objectives (SLOs)

| Metric               | SLO       | Measurement window            |
|----------------------|-----------|-------------------------------|
| API Latency (p95)    | < 200 ms  | 1-min, ALB metric             |
| Call Setup Time      | < 3 s     | Client → first video frame    |
| Video Uptime         | 99.9 %    | Weekly                        |
| Booking Success Rate | > 98 %    | HTTP 2xx on booking endpoints |
| Error Rate           | < 1 % 5xx | 5-min rolling                 |

</details>

<details>
<summary><strong>Technical View</strong></summary>

### Product & Delivery Gaps

| Gap | Description | Impact | Mitigation |
|-----|-------------|--------|------------|
| Mobile App Complexity | React Native development requires specialized knowledge | Development timeline risk | Hire experienced React Native developer |
| Video Streaming Expertise | AWS Chime SDK integration requires video streaming knowledge | Technical implementation risk | Leverage AWS documentation and community resources |
| Security Compliance | Real estate data requires specific security measures | Compliance risk | Engage security consultant for audit when needed |
| Analytics Integration | Multi-platform analytics requires careful implementation | Data quality risk | Use established analytics platforms with good documentation |

### Technical Quality Pillars

#### Observability

| Component | Description | Tools |
|-----------|-------------|-------|
| Application Monitoring | Real-time performance monitoring | DataDog or New Relic |
| Error Tracking | Comprehensive error logging and alerting | Sentry or Rollbar |
| User Analytics | User behavior and engagement tracking | Mixpanel and Google Analytics |
| Infrastructure Monitoring | System health and resource monitoring | CloudWatch, Grafana |

#### Scalability

| Aspect | Description | Strategy |
|--------|-------------|----------|
| Horizontal Scaling | Add more instances to handle increased load | Auto-scaling groups |
| Database Scaling | Optimize database performance for growth | Read replicas, connection pooling |
| CDN Implementation | Distribute content globally for faster access | CloudFront |
| Caching Strategy | Reduce database load with intelligent caching | Redis |

#### Performance

| Metric | Target | Optimization Strategy |
|--------|--------|---------------------|
| Page Load Time | < 3 seconds | Code splitting, lazy loading |
| API Response Time | < 200ms | Database optimization, caching |
| Video Call Latency | < 150ms | WebRTC optimization, regional servers |
| Mobile App Performance | Smooth 60fps | React Native optimization |

#### Maintainability

| Aspect | Description | Best Practices |
|--------|-------------|----------------|
| Code Quality | Clean, readable, and well-documented code | Rubocop, ESLint, Prettier, TypeScript |
| Testing Strategy | Comprehensive test coverage | Unit, integration, and E2E tests |
| Documentation | Clear technical documentation | API docs, architecture diagrams |
| Code Review Process | Systematic code review workflow | Pull request reviews, automated checks |

#### Testability

| Test Type | Coverage | Tools |
|-----------|----------|-------|
| Unit Tests | > 80% | Jest, RSpec |
| Integration Tests | Critical paths | Cypress, Capybara |
| End-to-End Tests | User journeys | Playwright, Selenium |
| Performance Tests | Load testing | Artillery, JMeter |

### Analytics

#### Remote Tour Tracking Plan

| Event | Description | Business Value |
|-------|-------------|----------------|
| Tour Requested | User requests a property tour | Lead generation tracking |
| Tour Scheduled | Tour is successfully scheduled | Booking funnel analysis |
| Tour Started | Video call begins | Engagement metrics |
| Tour Completed | Video call ends successfully | Conversion tracking |
| Tour Cancelled | Tour is cancelled by user | Churn analysis |

#### Hotjar

| Feature | Purpose | Implementation |
|---------|---------|----------------|
| Heatmaps | Visualize user interaction patterns | Session recording and heatmap generation |
| Session Recordings | Understand user behavior in detail | Privacy-compliant recording |
| Feedback Widgets | Collect user feedback in real-time | In-app feedback collection |
| Conversion Funnels | Track user journey through the platform | Funnel analysis and optimization |

#### Mixpanel

| Event | Properties | Business Insight |
|-------|------------|-----------------|
| User Registration | Source, device, location | User acquisition analysis |
| Property View | Property type, price range, location | Content performance |
| Tour Booking | Property ID, scheduled time, user type | Booking behavior analysis |
| Video Call Start | Call duration, participants, quality | Service quality metrics |
| Tour Completion | Duration, satisfaction score, follow-up actions | Success metrics |

#### Google Analytics

| Metric | Description | Business Value |
|--------|-------------|----------------|
| Traffic Sources | Where users come from | Marketing effectiveness |
| User Demographics | Age, gender, location | Target audience insights |
| Device Usage | Desktop vs mobile usage | Platform optimization |
| Page Performance | Load times and user engagement | Technical optimization |
| Conversion Tracking | Goal completion rates | Business performance |

### System Design

For detailed technical architecture, see [System Design Documentation](system-design.md).

</details>
