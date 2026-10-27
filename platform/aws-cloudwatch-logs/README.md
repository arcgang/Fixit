# aws-cloudwatch-logs

**Technology:** AWS CloudWatch Logs, AWS S3 (archival), AWS KMS

**LLD component:** `cmp:aws-cloudwatch-logs`

Centralised structured log aggregation for audit events (request ID, timestamp, actor, outcome) and operational logs. 90-day operational retention. Exports to S3 for 7-year archival. Satisfies C013 and NFR-12.
