Copy everything below exactly as one block into your README.md:
# DevOps Node.js Project

This project demonstrates a complete DevOps workflow for deploying a Node.js application to Amazon EKS using Docker, Terraform, Jenkins, Amazon ECR, Kubernetes, Prometheus, and Grafana.

## Project Overview

The application is a simple Node.js service that exposes health and metrics endpoints. The project includes infrastructure provisioning, containerization, continuous integration and deployment, Kubernetes deployment, and monitoring.

The CI/CD pipeline automatically builds the application, creates a Docker image, pushes the image to Amazon ECR, and deploys the updated image to the EKS cluster.

Prometheus collects application and Kubernetes metrics, while Grafana provides dashboards for monitoring application health and performance.

## Architecture

The Node.js application is containerized using Docker and stored in Amazon Elastic Container Registry.

Amazon EKS hosts the Kubernetes workloads.

Terraform provisions the AWS infrastructure including the VPC, EKS cluster, ECR repository, and IAM resources.

Jenkins manages the CI/CD pipeline.

Prometheus collects application and infrastructure metrics.

Grafana provides dashboards for monitoring CPU usage, memory usage, request rate, HTTP errors, total requests, and application uptime.

## Technologies Used

Node.js  
Docker  
Docker Compose  
Jenkins  
GitHub  
Amazon Web Services  
Amazon ECR  
Amazon EKS  
Terraform  
Kubernetes  
Prometheus  
Grafana  
Helm

## Project Structure

```text
devops-nodejs-project/
├── app/
│   ├── app.js
│   ├── Dockerfile
│   ├── package.json
│   ├── package-lock.json
│   └── test.js
├── Jenkins/
│   ├── Dockerfile
│   ├── Jenkinsfile
│   └── docker-compose.yml
├── K8S/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── namespace.yaml
│   ├── hpa.yaml
│   └── iam_policy.json
├── Monitoring/
│   ├── grafana/
│   └── prometheus/
├── Terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── vpc.tf
│   ├── eks.tf
│   ├── ecr.tf
│   ├── jenkins_iam.tf
│   └── outputs.tf
├── Scripts/
│   └── setup.sh
└── README.md
```

## Node.js Application

The application runs on port `3000`.

The health endpoint is:

```text
/health
```

The Prometheus metrics endpoint is:

```text
/metrics
```

The health endpoint is used to verify that the application is running correctly.

The metrics endpoint exposes application metrics that can be collected by Prometheus.

## Docker

The Node.js application is packaged into a Docker image using the Dockerfile located inside the `app` directory.

The Jenkins pipeline builds the Docker image and tags it using the Jenkins build number.

The image is then pushed to Amazon ECR.

## Infrastructure

Terraform is used to provision the AWS infrastructure required for the project.

The Terraform configuration includes the VPC, EKS cluster, ECR repository, IAM resources, and other supporting infrastructure.

Terraform commands are run from the `Terraform` directory.

```bash
terraform init
terraform plan
terraform apply
```

Sensitive Terraform files and state files are excluded from Git.

## Kubernetes Deployment

The Kubernetes manifests are stored in the `K8S` directory.

The application is deployed into the `devops-demo` namespace.

The deployment runs multiple replicas of the Node.js application.

The Kubernetes service exposes the application internally, while the ingress resource provides external access through the configured AWS load balancer.

The Horizontal Pod Autoscaler can adjust the number of application replicas based on resource usage.

Deployment status can be checked with:

```bash
kubectl get pods -n devops-demo
```

Service information can be checked with:

```bash
kubectl get svc -n devops-demo
```

Ingress information can be checked with:

```bash
kubectl get ingress -n devops-demo
```

## Jenkins CI/CD Pipeline

Jenkins handles the continuous integration and continuous deployment process.

The Jenkins pipeline configuration is stored in:

```text
Jenkins/Jenkinsfile
```

The pipeline performs the following workflow.

Jenkins checks out the latest source code from GitHub.

Application dependencies are installed.

Application tests and smoke tests are executed.

A Docker image is built.

The image is authenticated and pushed to Amazon ECR.

Jenkins connects to the Amazon EKS cluster.

The Kubernetes deployment is updated with the new image.

The deployment is verified after the update.

AWS credentials are stored securely in Jenkins Credentials instead of being written directly into the repository.

## Amazon ECR

Amazon Elastic Container Registry stores the Docker images created by the Jenkins pipeline.

The application repository is:

```text
devops-demo-app
```

Each Jenkins build can create a versioned Docker image using the Jenkins build number.

The latest image is also tagged as `latest`.

## Amazon EKS

Amazon Elastic Kubernetes Service hosts the application workload.

The application is deployed to the EKS cluster using Kubernetes manifests.

The Jenkins pipeline automatically updates the deployment whenever a new Docker image is built and pushed.

## Prometheus Monitoring

Prometheus is installed using the `kube-prometheus-stack` Helm chart.

The monitoring components run in the `monitoring` namespace.

Prometheus collects Kubernetes metrics and application metrics from the Node.js `/metrics` endpoint.

The monitoring pods can be checked with:

```bash
kubectl get pods -n monitoring
```

## Grafana

Grafana is used to visualize metrics collected by Prometheus.

Grafana can be accessed locally using Kubernetes port forwarding.

```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3001:80
```

Grafana is then available at:

```text
http://localhost:3001
```

The Grafana dashboard includes application memory usage, CPU usage, request rate, uptime, HTTP error rate, and total request count.

## Grafana Metrics

Application memory usage:

```promql
process_resident_memory_bytes
```

Application CPU usage:

```promql
process_cpu_seconds_total
```

Request rate:

```promql
rate(http_requests_total[5m])
```

Application uptime:

```promql
min(time() - process_start_time_seconds{job="devops-demo-app"})
```

HTTP error rate:

```promql
sum(rate(http_requests_total{job="devops-demo-app",status=~"4..|5.."}[5m]))
```

Total requests:

```promql
sum(http_requests_total{job="devops-demo-app"})
```

## Monitoring Architecture

The Node.js application exposes Prometheus metrics through the `/metrics` endpoint.

Prometheus collects those metrics from the Kubernetes application service.

Grafana uses Prometheus as its data source and displays the collected metrics through dashboards.

This provides visibility into application performance, resource usage, request traffic, uptime, and HTTP errors.

## CI/CD Workflow

A code change is committed and pushed to GitHub.

Jenkins retrieves the latest source code.

The application is tested.

A Docker image is created.

The Docker image is pushed to Amazon ECR.

Jenkins updates the Kubernetes deployment in Amazon EKS.

Kubernetes deploys the new application version.

Prometheus continues collecting application metrics.

Grafana displays the latest application monitoring information.

## Verification

Application pods can be verified with:

```bash
kubectl get pods -n devops-demo
```

The health endpoint can be used to verify application health:

```text
/health
```

The metrics endpoint can be used to verify Prometheus metrics:

```text
/metrics
```

Monitoring components can be verified with:

```bash
kubectl get pods -n monitoring
```

## Security

AWS access keys and secret keys are not stored directly in the GitHub repository.

Jenkins credentials are managed through the Jenkins Credentials system.

Terraform state files, Terraform variable files, Node.js dependencies, downloaded binaries, and local configuration files are excluded using `.gitignore`.

## Result

This project demonstrates a complete DevOps workflow for a Node.js application.

The application source code is stored in GitHub, automatically built and deployed through Jenkins, containerized using Docker, stored in Amazon ECR, deployed to Amazon EKS, and monitored using Prometheus and Grafana.

The completed project demonstrates infrastructure as code, containerization, CI/CD automation, Kubernetes orchestration, AWS cloud deployment, and application monitoring.
Paste that directly into GitHub’s README.md editor, then click Preview. It should now show proper headings, spacing, and code blocks instead of one giant paragraph.

