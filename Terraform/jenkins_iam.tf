# --- IAM user/policy for Jenkins ---
# Jenkins needs credentials to push images to ECR and to deploy to EKS
# (aws eks update-kubeconfig + kubectl). In production, prefer running
# Jenkins agents on EC2/EKS with an instance/IRSA role instead of a
# long-lived access key — this IAM user is the simplest path to get
# started and is fine for a demo/learning environment.

resource "aws_iam_user" "jenkins" {
  name = "${var.project_name}-jenkins"
}

resource "aws_iam_user_policy" "jenkins_ecr" {
  name = "${var.project_name}-jenkins-ecr"
  user = aws_iam_user.jenkins.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ECRAuth"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "ECRPushPull"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = aws_ecr_repository.app.arn
      },
      {
        Sid      = "EKSDescribe"
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster", "eks:ListClusters"]
        Resource = "*"
      }
    ]
  })
}

# Grants the Jenkins IAM user Kubernetes RBAC access via EKS access entries
# (modern replacement for the aws-auth ConfigMap).
resource "aws_eks_access_entry" "jenkins" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_user.jenkins.arn
}

resource "aws_eks_access_policy_association" "jenkins_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_user.jenkins.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"

  access_scope {
    type = "cluster"
  }
}