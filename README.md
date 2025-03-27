# Taller Litmus Terraform

This project automates the deployment of a Kubernetes cluster on Linode (Akamai) using Terraform. It also provisions a Persistent Volume (PV) and Persistent Volume Claim (PVC) for storage and sets up a proxy instance for additional functionality. The project integrates with LitmusChaos for chaos engineering experiments.

---

## **Project Description**

The `Taller Litmus Terraform` project is designed to:
- Deploy a Kubernetes cluster on Linode using the Linode Kubernetes Engine (LKE).
- Dynamically generate and use a kubeconfig file for managing the cluster.
- Create a Persistent Volume (PV) and Persistent Volume Claim (PVC) for storage.
- Set up a lightweight Linode instance as a proxy server.
- Integrate with LitmusChaos for chaos engineering experiments.

---

## **File Structure**

The project directory is organized as follows:
tallerlitmus/ ├── terraform/ │ ├── main.tf # Main Terraform configuration file │ ├── variables.tf # Variables used in the Terraform configuration │ ├── outputs.tf # Outputs for the Terraform configuration │ ├── tallerlitmus-lke-cluster-kubeconfig.yaml # Dynamically generated kubeconfig file │ ├── nginx_provision.sh # Script to provision the proxy instance │ └── terraform.tfvars # Variable values for the Terraform configuration ├── README.md # Project documentation

---

## **Prerequisites**

Before using this project, ensure you have the following installed:
1. **Terraform**: Install Terraform from [terraform.io](https://www.terraform.io/).
2. **kubectl**: Install `kubectl` to interact with the Kubernetes cluster.
3. **Linode CLI** (optional): Install the Linode CLI for additional cluster management.
4. **Linode API Token**: Generate an API token from the Linode Cloud Manager.

---

## **Setup Instructions**

### **2. Configure Terraform Variables**
Edit the `terraform/terraform.tfvars` file to provide the required values:

```hcl
token        = "<your-linode-api-token>"
k8s_version  = "1.27"
region       = "us-west"
label        = "tallerlitmus"
root_password = "<your-root-password>"
pools = [
  {
    type  = "g6-standard-2"
    count = 1
  }
]

---

### **3. Initialize Terraform**
Run the following command to initialize Terraform.

```bash
terraform init

---

### **4.  Plan the Deployment
Generate a plan to review the resources that will be created:

terraform plan -var-file="terraform/terraform.tfvars"

---

### **5. Apply the Deployment
Apply the Terraform configuration to create the resources:

### **6.  Verify the Deployment
Check the generated kubeconfig file:
ls terraform/tallerlitmus-lke-cluster-kubeconfig.yaml

Use kubectl to verify the Kubernetes cluster:
Use kubectl to verify the Kubernetes cluster:


### Key Features
Dynamic Kubeconfig Generation:

The kubeconfig file is dynamically generated and saved as tallerlitmus-lke-cluster-kubeconfig.yaml.
Persistent Volume and PVC:

A Persistent Volume (PV) and Persistent Volume Claim (PVC) are created for storage.
Proxy Instance:

A lightweight Linode instance is provisioned as a proxy server.
LitmusChaos Integration:

The project integrates with LitmusChaos for chaos engineering experiments.

### **How to Use This README**

1. Replace `<repository-url>` with the actual URL of your Git repository.
2. Update any placeholders (e.g., `<your-linode-api-token>`, `<your-root-password>`) with actual values.
3. Add additional details if necessary, such as specific LitmusChaos experiments or customizations.

Let me know if you need further assistance! 😊---

### **How to Use This README**

1. Replace `<repository-url>` with the actual URL of your Git repository.
2. Update any placeholders (e.g., `<your-linode-api-token>`, `<your-root-password>`) with actual values.
3. Add additional details if necessary, such as specific LitmusChaos experiments or customizations.

Let me know if you need further assistance! 😊

---
Author: Alejandro Mercado mercadoalex at gmail.com

### Cleanup
To destroy all resources created by Terraform, run:
terraform destroy -var-file="terraform/terraform.tfvars"

