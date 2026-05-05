## AutoFinOps: Real-Time Cloud Cost Optimization Platform for SaaS (AWS)

### A mid-sized SaaS company on Amazon Web Services spends **₹35–₹50 lakhs monthly**, with **25–40% wasted** due to idle compute, over-provisioned databases, and unused storage. Despite **predictable workloads**, the **lack of real-time cost visibility** and **automated optimization** leads to consistent **over-provisioning** and **billing spikes**. A **small DevOps team**, without a **dedicated FinOps practice**, cannot efficiently manage optimization across **50+ services** without risking reliability**. If unresolved, this could result in **₹1–₹1.5 crore in annual losses**, directly impacting **profitability** and limiting **future growth**.

> Cut cloud waste by **30–40%**, reducing monthly spend from **₹50L to ~₹30L**, saving **₹1–₹1.5 crore annually** while improving cost visibility and operational efficiency.

## Key Architecture Decisions & Trade-offs
| Decision | Chosen Option | Why This Over Alternative | Trade-off / Risk Mitigated |
|----------|---------------|---------------------------|----------------------------|
| Compute for image processing | Lambda | Pay-per-use, auto-scales to zero | Cold starts → mitigated with provisioned concurrency |
| Storage | S3 private bucket | Cheapest, durable, encryption at rest | Public bucket risk → solved with signed URLs + IAM |
| Networking | Custom VPC + private subnets | Security + control | Extra cost → justified by least-privilege |
| Scaling | Auto Scaling + CloudFront | Handles 10x spikes | Cost during quiet periods → near zero|





