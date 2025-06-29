# Coffee Shop Application Deployment

## Architecture
- **Development**: EC2 + Docker Compose
- **Production**: EKS + RDS + ALB + HPA
- **Infrastructure**: Custom Terraform modules
- **Monitoring**: Prometheus + Grafana
- **CI/CD**: GitHub Actions with Trivy scanning

## Components
- **VPC Module**: Custom networking infrastructure
- **Security Groups Module**: Layered security approach
- **EC2 Module**: Development environment
- **EKS Module**: Production Kubernetes cluster
- **RDS Module**: Managed PostgreSQL database

## Deployment
1. `terraform workspace select dev && terraform apply`
2. `terraform workspace select prod && terraform apply`
3. `kubectl apply -f k8s/all-in-one.yaml`