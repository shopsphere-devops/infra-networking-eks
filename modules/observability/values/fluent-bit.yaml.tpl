env:
  - name: CLUSTER_NAME
    value: "${CLUSTER_NAME}"
  - name: AWS_REGION
    value: "${AWS_REGION}"
  - name: AWS_ROLE_ARN
    value: "${FLUENTBIT_ROLE_ARN}"
  - name : AWS_WEB_IDENTITY_TOKEN_FILE
    value : /var/run/secrets/eks.amazonaws.com/serviceaccount/token

# Tells Helm to create a Kubernetes ServiceAccount for Fluent Bit.
serviceAccount:
  create: true
  name: fluent-bit # The ServiceAccount name
  annotations:
    eks.amazonaws.com/role-arn: ${FLUENTBIT_ROLE_ARN} # This is the IAM Role ARN created via IRSA (from Terraform).
    # It allows Fluent Bit pods to assume this IAM role and access AWS resources (CloudWatch Logs).
# When you deploy Fluent Bit with this Helm values file, the ServiceAccount is created and annotated.
# The ${FLUENTBIT_ROLE_ARN} placeholder is replaced by Terraform or at runtime with the actual IAM role ARN output from your IRSA setup.

# This section configures Fluent Bit’s behavior using its native configuration syntax.
config:
  # Send logs every 5 seconds, Run in foreground, Set logging verbosity & Use the specified parsers file for log parsing.
  service: |
    [SERVICE]
      Flush 5
      Daemon Off
      Log_Level info
      Parsers_File parsers.conf
      HTTP_Server   On
      HTTP_Listen   0.0.0.0
      HTTP_Port     2020
  # Use the tail input plugin to read log files, Read all container logs from path, Handle multiline log entries, Use the Docker log parser,
  # Tag all logs with kube.* for filtering/routing, Buffer up to 10MB in memory per input, Skip lines that exceed buffer limits.
  inputs: |
    [INPUT]
      Name tail
      Path /var/log/containers/*.log
      # Multiline On
      Parser docker
      Tag kube.*
      Mem_Buf_Limit 10MB
      Skip_Long_Lines On
  # Use the CloudWatch Logs output plugin, Send all logs tagged kube.* to CloudWatch, AWS region, Send logs to this CloudWatch log group ,
  # Prefix for log streams, Create the log group if it doesn’t exist, Retain logs for 14 days.
  outputs: |
    [OUTPUT]
      Name cloudwatch_logs
      Match kube.*
      region ${AWS_REGION}
      log_group_name /eks/${CLUSTER_NAME}/applications
      log_stream_prefix from-fluent-bit-
      auto_create_group true
      log_retention_days 14
  # Use the Kubernetes filter plugin, Apply this filter to logs tagged kube.* , Merge partial log lines (e.g., multiline logs) into a single entry,
  # Remove the original log after merging, Prefix for Kubernetes log tags, Connect to the Kubernetes API to enrich logs with metadata (namespace, pod, container, etc.).
  filters: |
    [FILTER]
      Name kubernetes
      Match kube.*
      Merge_Log On
      Keep_Log Off
      Kube_Tag_Prefix kube.var.log.containers.
      Kube_URL https://kubernetes.default.svc:443

# Conclusion :
# ServiceAccount is created and annotated with the IAM role ARN for IRSA.
# Fluent Bit runs as a DaemonSet, reading container logs from all nodes.
# Filters enrich logs with Kubernetes metadata.
# Outputs send logs to AWS CloudWatch Logs using the IAM role for authentication.
# Placeholders like ${FLUENTBIT_ROLE_ARN}, ${AWS_REGION}, ${CLUSTER_NAME} are replaced by Terraform or Helm at deployment time.
