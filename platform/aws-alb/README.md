# aws-alb

**Technology:** AWS Application Load Balancer, TLS 1.2+, ACM Certificate

**LLD component:** `cmp:aws-alb`

Layer 7 load balancer providing TLS 1.2+ termination for all inbound HTTPS traffic. Routes API traffic to API Gateway and static asset requests to CloudFront. Sole public ingress point.
