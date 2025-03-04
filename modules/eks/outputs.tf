output "eks_cluster_endpoint"{
    value = module.eks.cluster_endpoint
}

output "eks_ca_certificate" {
    value = base64decode(module.eks.cluster_certificate_authority_data)
}

output "eks_cluster_name" {
    value = module.eks.cluster_name
}

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "AWS_PROFILE=${var.aws_profile_name} aws eks update-kubeconfig --name ${module.eks.cluster_name} --kubeconfig ~/.kube/eks-${var.project_name} --region ${var.region}"
  }
  # triggers = {
  #   always_run = "${timestamp()}"
  # }
}

output "eks_oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "eks_oidc_provider_url" {
  value = module.eks.oidc_provider
}

### Node IP ###
## For use as a jumphost


# Get information about the EC2 instances in the node group
data "aws_instances" "worker_node" {
  instance_tags = {
    "eks:cluster-name"   = module.eks.cluster_name
  }

  instance_state_names = ["running"]
}

# Output the public IP of the first node (if available)
output "node_ip" {
  value       = length(data.aws_instances.worker_node.public_ips) > 0 ? data.aws_instances.worker_node.public_ips[0] : "No public IP available"
  description = "Public IP of the first node in worker-node-1 group (if available)"
}