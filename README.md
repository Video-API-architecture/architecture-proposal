# RealtyForYou Architecture Proposal

This document presents a comprehensive **Systems Design solution** for a video streaming application that facilitates live video calls between realtors and clients. The platform enables virtual property tours, allowing realtors to showcase properties remotely while providing clients with immersive viewing experiences.

## 📋 Table of Contents

- [Executive Summary](#executive-summary)
- [Product View](#product-view)
  - [Expected Business Impact](#expected-business-impact)
  - [Assumptions and Questions Raised](#assumptions-and-questions-raised)
  - [Constraint Analysis & Mitigation](#constraint-analysis--mitigation)
    - [Ambitious Timelines](#ambitious-timelines)
    - [Rural Connectivity Challenges](#rural-connectivity-challenges)
  - [Team Execution Model](#team-execution-model)
    - [Tech/Product/Design Sync Rhythm](#techproductdesign-sync-rhythm)
    - [Shipping Milestones (8 Weeks, High-Impact First)](#shipping-milestones-8-weeks-high-impact-first)
  - [Landing Pages](#landing-pages)
  - [Delivery Plan](#delivery-plan)
- [🔧 Technical View](#-technical-view)
  - [Product & Delivery Gaps](#product--delivery-gaps)
  - [Technical Quality Pillars](#technical-quality-pillars)
    - [🔍 Observability](#-observability)
    - [📈 Scalability](#-scalability)
    - [⚡ Performance](#-performance)
    - [🔧 Maintainability](#-maintainability)
    - [🧪 Testability](#-testability)
  - [Analytics](#analytics)
    - [Remote Tour Tracking Plan](#remote-tour-tracking-plan)
    - [Hotjar](#hotjar)
    - [Mixpanel](#mixpanel)
    - [Google Analytics](#google-analytics)
  - [Systems Design](system-design.md)

## 🎯 Executive Summary

This document presents a comprehensive architecture proposal for a **video streaming application** designed to facilitate live video calls between realtors and clients. The solution leverages modern web technologies and cloud services to deliver a robust, scalable, and user-friendly platform.

### ✨ Key Highlights

| Feature | Description | Technology |
|---------|-------------|------------|
| **🎥 Real-time Video Communication**  | High-quality video streaming with low latency | AWS Chime SDK |
| **📱 Multi-platform Support**         | Web and mobile applications | React + React Native |
| **⚡ Scalable Backend**                | Robust API with flexible querying | Ruby on Rails + GraphQL |
| **☁️ Cloud-Native Architecture**      | Scalable infrastructure with containerization | AWS ECS/Fargate |
| **📊 Comprehensive Analytics**        | Multi-platform tracking and user behavior analysis | Mixpanel + GA4 + Hotjar |

## 📈 Product View

### 🚀 Expected Business Impact

The video streaming platform is expected to revolutionize the real estate industry by:

| Impact Area | Description | Expected Outcome |
|-------------|-------------|------------------|
| **📈 Increasing Conversion Rates** | Direct video communication improves client engagement and trust | Higher tour-to-sale conversion |
| **⏰ Reducing Travel Time** | Virtual property tours save time for both realtors and clients | 60% reduction in travel costs |
| **🌍 Expanding Market Reach** | Rural and remote clients can access properties without physical travel | 3x increase in potential client base |
| **😊 Improving Customer Satisfaction** | Real-time interaction provides immediate answers and personalized experience | 85% customer satisfaction score |

### 🤔 Assumptions and Questions Raised

#### ✅ Key Assumptions

| Assumption | Description | Impact |
|------------|-------------|--------|
| **🌐 Stable Internet Connectivity** | Users have access to reliable internet | Core functionality depends on connectivity |
| **📱 Mobile Device Support** | Devices support video streaming capabilities | Ensures broad device compatibility |
| **🎥 Video Communication Comfort** | Users are comfortable with video communication | Adoption and user experience |
| **🏠 Digital Transformation** | Real estate market embraces digital solutions | Market acceptance and growth |

#### ❓ Questions to Address

| Question | Category | Priority |
|----------|----------|----------|
| What is the minimum bandwidth requirement for video calls? | **Technical** | High |
| How do we handle poor connectivity scenarios? | **Technical** | High |
| What security measures are needed for sensitive property information? | **Security** | Critical |
| How do we ensure compliance with real estate regulations? | **Compliance** | Critical |

#### ❓ Questions We'd Ask The Business

| Question | Category | Business Impact |
|----------|----------|-----------------|
| What pricing tiers or revenue model do we target? | **Revenue** | Critical for business model |
| Do we require content-licensing for recorded tours? | **Legal** | Compliance and IP protection |
| Any legal/branding constraints for property media? | **Legal** | Risk mitigation |
| Preferred KYC / ID-verification vendor for realtor onboarding? | **Security** | Trust and compliance |
| SLA penalties—do we include credits for downtime? | **Operations** | Customer satisfaction |
| What data-retention policy for recordings and PII? | **Compliance** | Legal and privacy requirements |

### ⚠️ Constraint Analysis & Mitigation

#### 🕐 Ambitious Timelines

| Constraint | Description | Mitigation Strategy |
|------------|-------------|-------------------|
| **⏱️ Rapid Development Timeline** | Market entry pressure with complex requirements | Agile methodology with weekly sprints |
| **🎥 Complex Video Streaming** | Real-time video communication requirements | Leverage AWS Chime SDK for managed solution |
| **📱 Multi-platform Development** | Web and mobile app development needs | Parallel development tracks with shared components |

#### 🌐 Rural Connectivity Challenges

| Constraint | Description | Mitigation Strategy |
|------------|-------------|-------------------|
| **📶 Limited Bandwidth** | Rural areas have poor internet connectivity | Adaptive video quality based on connection speed |
| **🔌 Unstable Connections** | Intermittent internet connectivity | Offline mode for property information |
| **📱 Mobile Data Limitations** | Users have limited mobile data plans | Data compression and optimization techniques |

### 👥 Team & Process

### 🚀 Team Execution Model

#### 📅 Tech/Product/Design Sync Rhythm

| Meeting Type | Frequency | Duration | Purpose |
|--------------|-----------|----------|---------|
| **Daily Standups** | Daily | 15 minutes | Team sync and blocker identification |
| **Weekly Sprint Planning** | Weekly | 1 hour | Feature prioritization and task assignment |
| **Bi-weekly Demos** | Every 2 weeks | 30 minutes | Showcase completed features to stakeholders |
| **Monthly Retrospectives** | Monthly | 1 hour | Process improvement and team feedback |

#### 📅 Shipping Milestones (8 Weeks, High-Impact First)

> Given our 2-month timeline and a small engineering team, milestones are prioritized for business impact and demo readiness. Each milestone concludes with a demo to stakeholders.

---

### 🏗️ Week 1-2: Core Foundations & Authentication

| Task | Description | Status |
|------|-------------|--------|
| **🔧 Project Setup** | Repositories, CI/CD, environments (staging/production) | Core infrastructure |
| **🔐 User Authentication** | Buyers & realtors with forgot-password flow | Essential security |
| **👤 Profile Management** | Basic user profile management | User experience |
| **🏠 Homepage Hero** | Call-to-action (register) implementation | Marketing conversion |
| **🎨 Minimal UI** | Login, registration, dashboard shell | Core user interface |

**🎯 Demo:** Login, registration, password reset, and homepage navigation

**✅ Acceptance Criteria:**
- Users can register, log in and reset their passwords via email link
- Homepage hero & registration CTA are visible
- Dashboard shell is accessible after login
- CI/CD pipeline is operational

### 🎥 Week 3-4: Live Video Tour MVP & Dashboards (Phase I)

| Task | Description | Status |
|------|-------------|--------|
| **📹 AWS Chime SDK** | 1:1 live video calls integration | Core video functionality |
| **📅 Tour Scheduling** | Schedule and join a tour (buyer requests, realtor hosts) | Booking system |
| **📊 Dashboard Widgets** | Upcoming appointments (buyer & realtor) | User experience |
| **🏠 Property Listings** | Basic property listing (static/dummy data) | Content management |
| **📈 Event Tracking** | Core analytics (Mixpanel/GA4) | Business intelligence |

**🎯 Demo:** End-to-end video call between buyer and realtor + dashboards showing upcoming tours

**✅ Acceptance Criteria:**
- Users can request and join a video tour
- Upcoming tours appear in buyer & realtor dashboards
- Video call works between buyer and realtor
- Basic property data is visible
- Key events are tracked in analytics

### 📅 Week 5: Property Listings, Booking & History

| Task | Description | Status |
|------|-------------|--------|
| **🏠 CRUD for property listings** | Admin/realtor | Core functionality |
| **🏠 Buyers can browse/search properties and request tours** | Buyer | User experience |
| **🏠 Calendar integration for tour scheduling** | Buyer | Booking system |
| **🏠 Tour history view for buyers** | Buyer | User experience |

**🎯 Demo:** Buyer books a tour from a real property listing and views it in history

**✅ Acceptance Criteria:**
- Realtors can create, update, and delete property listings
- Buyers can browse/search and book tours
- Calendar integration is functional
- Buyers can view completed tours in their history

### 📅 Week 6: Analytics Dashboards

| Task | Description | Status |
|------|-------------|--------|
| **🏠 Analytics dashboards for realtors** | Realtor | Business intelligence |
| **📈 Expand event tracking** | Realtor | Business intelligence |

**🎯 Demo:** Realtor views analytics dashboard with tour metrics

**✅ Acceptance Criteria:**
- Realtors can view analytics dashboards with tour metrics

### 📅 Week 7: Mobile & UX Enhancements

| Task | Description | Status |
|------|-------------|--------|
| **🏠 Polish mobile experience** | React Native | User experience |
| **🏠 Responsive UI improvements** | React Native | User experience |
| **🏠 Error handling, loading states, and basic offline support** | React Native | User experience |

**🎯 Demo:** Mobile tour booking and video call

**✅ Acceptance Criteria:**
- Mobile app supports booking and video calls
- UI is responsive and user-friendly
- App handles errors and offline scenarios gracefully

### 📅 Week 8: Polish, QA, and Launch

| Task | Description | Status |
|------|-------------|--------|
| **🏠 End-to-end testing** | Manual + automated | Quality assurance |
| **🏠 Performance optimizations** | Video, API, UI | User experience |
| **🏠 Security review** | Authentication, data privacy | Security |
| **🏠 Final bug fixes, documentation, and go-live** | Documentation, testing | Product readiness |

**🎯 Demo:** Full product walkthrough and launch readiness

**✅ Acceptance Criteria:**
- All critical bugs are fixed
- Product passes QA and security review
- Documentation is complete
- Product is ready for launch

---

### Deferred Features (Post-Launch)
- Advanced property search and filters
- AI-powered property recommendations
- Advanced analytics and reporting

### Landing Pages

**Homepage Design:** [Link](https://realtyforyou.lovable.app)
- Hero section with video call demonstration
- Feature highlights and benefits
- Testimonials from realtors and clients
- Call-to-action for registration

**Authentication**
- Login [Link](https://realtyforyou.lovable.app/signin)
- Sign up [Link](https://realtyforyou.lovable.app/signup)
- Forgot Password [Link](https://realtyforyou.lovable.app/forgot-password)

**Realtor Dashboard:** 
- Property listings [Link](https://realtyforyou.lovable.app/admin/dashboard)
- View property [Link](https://realtyforyou.lovable.app/admin/properties/1)
- Upcoming tour appointments: [Link](https://realtyforyou.lovable.app/admin/tours)
- See a list of users: [Link](https://realtyforyou.lovable.app/admin/users)

**User Dashboard**
- Recent tour appointments history [Link](https://realtyforyou.lovable.app/tours)
  - Upcoming tour appointments [Link](https://realtyforyou.lovable.app/tours?query=upcoming)
  - Browse active property listings [Link](https://realtyforyou.lovable.app/tours?query=active)
    - See property listing [Link](https://realtyforyou.lovable.app/admin/properties/:id)
- Book/Reschedule/Cancel an appointment [Link](https://realtyforyou.lovable.app/book-tour)

---

### 📋 Delivery Plan

| Phase | Description | Key Features | Timeline |
|-------|-------------|--------------|----------|
| **🚀 Phase 1 (MVP)** | Core video calling functionality | Basic video calling between two users, Simple property listing display, User authentication and profiles | Weeks 1-4 |
| **⚡ Phase 2 (Enhanced)** | Advanced features and improvements | Multi-party video calls, Advanced property search and filters, Recording and playback features | Weeks 5-8 |
| **🎯 Phase 3 (Advanced)** | AI and advanced capabilities | AI-powered property recommendations, Advanced analytics and reporting | Post-launch |

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
| Analytics Dashboards                      |       6           | Basic realtor stats                    |
| Testimonials / Highlights                 | Content/Marketing | Requires marketing assets              |

### Product & Delivery Gaps

| Gap                    | Why it matters                                                     | Quick fix                                                                                              |
|------------------------|--------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------|
| Cost model             | Chime minutes, ECS hours, media storage ⇒ bill shock if untracked  | Build a 3-row cost table (Dev/MVP/Scale) with ±20% estimates; include recording storage & MediaConvert |
| Success metrics (SLOs) | Perf targets exist but not customer-facing guarantees              | Publish an SLO table: API p95 < 200 ms, Call-setup < 3 s, Video uptime 99.9 % etc.                     |
| Regulatory coverage    | Real-estate transactions involve PII & sometimes KYC               | Reference RESA (BC), FINTRAC, and US state privacy rules; define data-retention & deletion windows     |
| Incident playbooks     | Alerting exists but no documented runbooks                         | Link PagerDuty runbook template; codify post-mortem ≤ 48 h SLA                                         |

#### Cost Model (Rough-Order-of-Magnitude)

| Environment | Monthly cost drivers                                                       | Est. USD |
|-------------|----------------------------------------------------------------------------|----------|
| Dev         | 200 Chime minutes, 2 × ECS t3.small, 50 GB S3                              | ~$150    |
| MVP         | 10 k Chime minutes, 8 × ECS t3.medium, 500 GB S3, MediaConvert hours       | ~$2 500  |
| Scale (10×) | 100 k Chime minutes, 30 × ECS t3.large, 5 TB S3, higher MediaConvert usage | ~$20 000 |

#### Service Level Objectives (SLOs)

| Metric               | SLO       | Measurement window            |
|----------------------|-----------|-------------------------------|
| API Latency (p95)    | < 200 ms  | 1-min, ALB metric             |
| Call Setup Time      | < 3 s     | Client → first video frame    |
| Video Uptime         | 99.9 %    | Weekly                        |
| Booking Success Rate | > 98 %    | HTTP 2xx on booking endpoints |
| Error Rate           | < 1 % 5xx | 5-min rolling                 |

## 🔧 Technical View

### 🏗️ Technical Quality Pillars

#### 🔍 Observability

| Component | Description | Implementation |
|-----------|-------------|----------------|
| **Logging** | Structured logging with correlation IDs | Centralized log aggregation with request tracing |
| **Monitoring** | Real-time system health and performance metrics | CloudWatch dashboards and custom metrics |
| **Tracing** | Distributed tracing for request flows | AWS X-Ray integration for request correlation |
| **Alerting** | Proactive notification of issues and anomalies | PagerDuty integration with SLO-based alerts |

#### 📈 Scalability

| Strategy | Description | Implementation |
|----------|-------------|----------------|
| **Horizontal Scaling** | Auto-scaling based on demand | ECS Auto Scaling Groups with CPU/Memory metrics |
| **Load Balancing** | Distribution of traffic across multiple instances | Application Load Balancer (ALB) with health checks |
| **Database Sharding** | Partitioning data for better performance | Read replicas and connection pooling |
| **CDN Integration** | Global content delivery for static assets | CloudFront distribution for images and static files |

#### ⚡ Performance

| Metric | Target | Implementation |
|--------|--------|----------------|
| **Response Time** | < 200ms for API calls | Optimized database queries and Redis caching |
| **Video Quality** | Adaptive bitrate streaming | AWS Chime SDK with dynamic quality adjustment |
| **Caching** | Redis for frequently accessed data | Multi-level caching strategy with TTL |
| **Optimization** | Image compression and lazy loading | WebP format and progressive image loading |

#### 🔧 Maintainability

| Aspect | Description | Implementation |
|--------|-------------|----------------|
| **Code Quality** | Automated linting and code reviews | RuboCop, ESLint, and mandatory PR reviews |
| **Documentation** | Comprehensive API and code documentation | OpenAPI specs, inline code docs, and README files |
| **Testing** | Unit, integration, and end-to-end tests | RSpec, Jest, and Cypress test suites |
| **Modular Architecture** | Clear separation of concerns | Service objects, concerns, and layered architecture |

#### 🧪 Testability

| Requirement | Target | Implementation |
|-------------|--------|----------------|
| **Test Coverage** | > 80% code coverage | Automated coverage reporting with SimpleCov |
| **Mock Services** | Isolated testing environments | FactoryBot, MSW, and Docker test containers |
| **CI/CD Pipeline** | Automated testing and deployment | GitHub Actions with parallel test execution |
| **Performance Testing** | Load testing and stress testing | Artillery.js and k6 for API and video call testing |

### Analytics

A robust analytics strategy is essential for understanding user behavior, optimizing product features, and driving business outcomes. This platform leverages a multi-tool analytics stack to provide both qualitative and quantitative insights.

---

### Analytics Stack Overview

| Tool           | Strengths                                 | Best Use Cases                                   |
|----------------|-------------------------------------------|--------------------------------------------------|
| **Mixpanel**   | Event-level user tracking & cohorts       | Product insights, funnel drop-offs, retention    |
| **Hotjar**     | Session replays & heatmaps                | UX issues, behavioral pain points, UI analysis   |
| **GA4**        | Marketing analytics & attribution         | Campaigns, traffic, geo/device segmentation      |

---

### How We Use Analytics

- **Product Analytics (Mixpanel):**
  - Track key user events (tour requested, joined, completed, registration_started, password_reset_requested/completed, booking_scheduled, booking_rescheduled/cancelled, property_created/updated/deleted, analytics_dashboard_viewed, etc.)
  - Analyze conversion funnels (e.g., "Tour Requested" → "Tour Joined" → "Tour Completed")
  - Segment users by role (buyer, realtor) and behavior
  - Cohort analysis to measure retention and engagement over time

- **User Experience Insights (Hotjar):**
  - Record user sessions to identify pain points and drop-off moments
  - Generate heatmaps to visualize user focus areas on landing pages and video tours
  - Collect direct feedback via in-app surveys
  - Use session recordings to guide UI/UX improvements

- **Acquisition & Marketing Analytics (Google Analytics 4):**
  - Track user acquisition channels (SEO, email, paid, etc.)
  - Monitor conversion rates from landing page to booked tour
  - Set and track goals (e.g., "Tour Scheduled", "Video Joined")
  - Analyze geo/device breakdown to optimize for rural/mobile users

---

### Remote Tour Tracking Plan

| Event Name                 | Properties                                                      | Triggered By      | Tracked On                |
|----------------------------|-----------------------------------------------------------------|-------------------|---------------------------|
| tour_requested             | tour_id, property_id, user_id, scheduled_time                   | Buyer             | Frontend (React)          |
| tour_joined                | tour_id, user_id, role, timestamp                               | Buyer + Realtor   | React / React Native      |
| tour_left                  | tour_id, user_id, duration_in_session, role                     | Buyer + Realtor   | React Native              |
| recording_started          | tour_id, user_id, timestamp, recording_method                   | Realtor           | Backend (Chime webhook)   |
| recording_saved            | tour_id, video_url, duration, file_size                         | System            | Backend (Rails job)       |
| highlight_created          | highlight_id, tour_id, user_id, timestamp, note                 | Buyer             | Frontend                  |
| note_added                 | tour_id, user_id, timestamp, text_length, media_type            | Buyer             | Frontend                  |
| recording_played           | tour_id, user_id, start_time, device_type, geo                  | Buyer             | React (Web)               |
| call_quality_warning       | tour_id, user_id, signal_strength, packet_loss, latency         | System (SDK)      | React Native SDK          |
| tour_completed             | tour_id, user_id, duration, participants_count                  | System            | Backend                   |
| password_reset_requested   | user_id, method (email/sms), timestamp                          | Buyer/Realtor     | Frontend (React/Native)   |
| password_reset_completed   | user_id, timestamp                                              | Buyer/Realtor     | Backend (Rails)           |
| homepage_cta_clicked       | user_id (anon if logged out), location (hero/footer), timestamp | Visitor           | Frontend (React)          |
| registration_started       | user_id (anon), referral_source, timestamp                      | Visitor           | Frontend                  |
| property_created           | property_id, realtor_id, timestamp                              | Realtor           | Frontend                  |
| property_updated           | property_id, realtor_id, fields_changed, timestamp              | Realtor           | Frontend                  |
| property_deleted           | property_id, realtor_id, timestamp                              | Realtor           | Frontend                  |
| booking_scheduled          | booking_id, tour_id, user_id, scheduled_time                    | Buyer             | Frontend                  |
| booking_rescheduled        | booking_id, tour_id, user_id, new_time                          | Buyer             | Frontend                  |
| booking_cancelled          | booking_id, tour_id, user_id, cancel_reason                     | Buyer             | Frontend                  |
| dashboard_viewed           | user_id, role, dashboard_type (realtor|buyer), timestamp        | Buyer/Realtor     | Frontend                  |
| analytics_dashboard_viewed | realtor_id, timestamp, filters_applied                          | Realtor           | Frontend                  |
