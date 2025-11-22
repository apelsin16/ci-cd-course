# modules/eks/eks.tf

# 1. IAM Ролі для EKS Master та Worker Nodes
resource "aws_iam_role" "eks_master" {
  name = "${var.cluster_name}-master-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
    Version = "2012-10-17"
  })
}
resource "aws_iam_role_policy_attachment" "eks_master_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_master.name
}

resource "aws_iam_role" "eks_node" {
  name = "${var.cluster_name}-node-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
    Version = "2012-10-17"
  })
}
resource "aws_iam_role_policy_attachment" "eks_node_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node.name
}
resource "aws_iam_role_policy_attachment" "eks_node_worker" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node.name
}
resource "aws_iam_role_policy_attachment" "eks_node_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}

# 2. Створення Кластера EKS
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_master.arn
  version  = "1.29" # Рекомендована версія

  vpc_config {
    subnet_ids = var.private_subnet_ids # Кластер розміщуємо у приватних підмережах
    # Додатково можна додати public_access_cidrs = ["..."] для обмеження доступу
  }
}

# 3. Створення Node Group (робочі вузли)
resource "aws_eks_node_group" "private" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "private-nodes"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = var.private_subnet_ids

  instance_types  = [var.instance_type]
  
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_cni,
    aws_iam_role_policy_attachment.eks_node_worker,
  ]
}