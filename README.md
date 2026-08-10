                                           DevOps Node.js Project
This project demonstrates a complete DevOps workflow for deploying a Node.js application to Amazon EKS using Docker, Terraform, Jenkins, Amazon ECR, Kubernetes, Prometheus, and Grafana.
Project Overview
The application is a simple Node.js service that exposes health and metrics endpoints. The project includes infrastructure provisioning, containerization, continuous integration and deployment, Kubernetes deployment, and monitoring.
The CI/CD pipeline automatically builds the application, creates a Docker image, pushes the image to Amazon ECR, and deploys the updated image to the EKS cluster.
Prometheus collects application and Kubernetes metrics, while Grafana provides dashboards for monitoring application health and performance.
Architecture
The Node.js application is containerized using Docker and stored in Amazon Elastic Container Registry.
Amazon EKS hosts the Kubernetes workloads.
Terraform is used to provision AWS infrastructure including the VPC, EKS cluster, ECR repository, and related IAM resources.
Jenkins handles the CI/CD pipeline.
Prometheus collects application and infrastructure metrics.
Grafana provides dashboards for monitoring CPU usage, memory usage, request rate, HTTP errors, total requests, and application uptime.
Technologies Used
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
Project Structure
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
Node.js Application
The application runs on port 3000.
The health endpoint is available at:
/health
The Prometheus metrics endpoint is available at:
/metrics
The health endpoint is used by the CI/CD pipeline and Kubernetes health checks.
The metrics endpoint exposes application metrics that are collected by Prometheus.
Docker
The application is packaged into a Docker image using the Dockerfile located in the app directory.
The image is built during the Jenkins pipeline and tagged using the Jenkins build number.
The image is then pushed to Amazon ECR.
Infrastructure
Terraform provisions the AWS infrastructure required for the project.
The Terraform configuration creates the networking resources, EKS cluster, ECR repository, and IAM permissions required by Jenkins and Kubernetes.
Terraform commands are run from the Terraform directory.
terraform init
terraform plan
terraform apply
Terraform state files and variable files containing sensitive information are excluded from Git.
Kubernetes Deployment
The Kubernetes manifests are stored in the K8S directory.
The application is deployed into the devops-demo namespace.
The deployment runs multiple replicas of the Node.js application.
The Kubernetes service exposes the application internally.
The ingress resource provides external access through the configured AWS load balancer.
The Horizontal Pod Autoscaler can automatically adjust the number of application replicas based on resource usage.
Deployment status can be verified with:
kubectl get pods -n devops-demo
Ingress information can be viewed with:
kubectl get ingress -n devops-demo
Jenkins CI/CD Pipeline
Jenkins runs inside a Docker container.
The Jenkins image includes the tools required by the pipeline, including Docker, AWS CLI, kubectl, Node.js, and npm.
The Jenkins pipeline configuration is stored in:
Jenkins/Jenkinsfile
The pipeline checks out the source code from GitHub, installs application dependencies, runs validation and smoke tests, builds the Docker image, authenticates with Amazon ECR, pushes the image, updates the Kubernetes deployment, and verifies the deployment.
AWS credentials are stored securely in Jenkins Credentials and referenced by the pipeline using the credential ID:
aws-jenkins-creds
Amazon ECR
Docker images are stored in Amazon Elastic Container Registry.
Each Jenkins build pushes a versioned image using the Jenkins build number and also updates the latest image tag.
The repository used by the application is:
devops-demo-app
Monitoring
The project uses the Prometheus Operator through the kube-prometheus-stack Helm chart.
The monitoring stack is installed in the monitoring namespace.
Prometheus collects Kubernetes metrics and application metrics exposed through /metrics.
Grafana uses Prometheus as its data source.
The monitoring stack can be verified with:
kubectl get pods -n monitoring
Grafana can be accessed locally using port forwarding:
kubectl port-forward -n monitoring svc/monitoring-grafana 3001:80
Grafana is then available at:
http://localhost:3001
Grafana Dashboard
The Grafana dashboard monitors the Node.js application using Prometheus metrics.
Application memory usage is monitored with:
process_resident_memory_bytes
Application CPU usage is monitored with:
process_cpu_seconds_total
Request rate is monitored with:
rate(http_requests_total[5m])
Application uptime is monitored with:
min(time() - process_start_time_seconds{job="devops-demo-app"})
HTTP error rate is monitored with:
sum(rate(http_requests_total{job="devops-demo-app",status=~"4..|5.."}[5m]))
Total application requests are monitored with:
sum(http_requests_total{job="devops-demo-app"})
Prometheus Monitoring
The project includes custom Prometheus configuration under:
Monitoring/prometheus/
The ServiceMonitor allows Prometheus to scrape the Node.js application metrics endpoint.
PrometheusRule resources can be used to define alerts for application health and performance conditions.
CI/CD Workflow
A code change is committed and pushed to GitHub.
Jenkins checks out the latest source code.
The application dependencies are installed and tested.
A Docker image is created.
The image is pushed to Amazon ECR.
Jenkins connects to the Amazon EKS cluster.
Kubernetes is updated to use the new Docker image.
The deployment is verified.
Prometheus continuously collects application metrics.
Grafana displays the application monitoring data.
Verification
Application pods can be verified with:
kubectl get pods -n devops-demo
Services can be verified with:
kubectl get svc -n devops-demo
Ingress can be verified with:
kubectl get ingress -n devops-demo
Monitoring components can be verified with:
kubectl get pods -n monitoring
The application health endpoint should return a successful HTTP response.
/health
The metrics endpoint should return Prometheus-formatted metrics.
/metrics
Security
AWS access keys and secrets are not stored directly in the repository.
Jenkins credentials are managed through the Jenkins Credentials system.
Terraform state files, Terraform variable files, application dependencies, downloaded binaries, and local configuration files are excluded using .gitignore.
Result
The project provides a complete DevOps deployment workflow for a Node.js application.
Application code is stored in GitHub, automatically built through Jenkins, packaged using Docker, stored in Amazon ECR, deployed to Amazon EKS, and monitored using Prometheus and Grafana.
The completed environment demonstrates infrastructure as code, containerization, CI/CD automation, Kubernetes orchestration, AWS cloud deployment, and production-style monitoring.

