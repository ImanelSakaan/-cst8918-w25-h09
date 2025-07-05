# Hybrid-H09 Azure Kubernetes Service (AKS) Cluster with Terraform
---

## ✅ Step 1: Setup Your Environment

### 1. Install prerequisites:
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Git](https://git-scm.com/downloads) (for version control)

### 2. Login to Azure:
```bash
az login
````

---

## ✅ Step 2: Create Terraform Project

### 1. Folder structure:

```
aks-lab/
├── main.tf
├── outputs.tf
├── providers.tf
├── variables.tf
├── terraform.tfvars
```

### 2. `providers.tf`:

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
}
```

### 3. `variables.tf`:

```hcl
variable "resource_group_name" {
  default = "aks-lab-rg"
}

variable "location" {
  default = "East US"
}

variable "aks_name" {
  default = "aks-lab-cluster"
}

variable "node_count" {
  default = 1
}

variable "max_node_count" {
  default = 3
}
```

### 4. `main.tf`:

```hcl
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "app" {
  name                = var.aks_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-lab"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_B2s"
    max_count  = var.max_node_count
    min_count  = var.node_count
    enable_auto_scaling = true
  }

  identity {
    type = "SystemAssigned"
  }

  kubernetes_version = null # latest
}
```

### 5. `outputs.tf`:

```hcl
output "kube_config" {
  value     = azurerm_kubernetes_cluster.app.kube_config_raw
  sensitive = true
}
```

---

## ✅ Step 3: Deploy AKS using Terraform

In the `aks-lab` directory, run:

```bash
terraform init
terraform apply
```
![image](https://github.com/user-attachments/assets/aa47f526-783a-43e2-992b-a82a38acad18)

![image](https://github.com/user-attachments/assets/7b756c23-2384-4727-b9f9-cb197048a5a5)


Accept the plan and wait until the AKS cluster is deployed (\~5–10 minutes).

---

## ✅ Step 4: Save and Set kubeconfig

```bash
echo "$(terraform output kube_config)" > ./kubeconfig

```
![image](https://github.com/user-attachments/assets/9b802430-899a-4885-8235-79c8f3d81500)
**IMPORTANT**: Open the `kubeconfig` file and remove any `<<eof` or `eof` lines manually if they appear.

Then set the environment variable:

* On Linux/macOS:

  ```bash
  export KUBECONFIG=./kubeconfig
  ```
* On Windows CMD:

  ```cmd
  set KUBECONFIG=.\kubeconfig
  ```
* On PowerShell:

  ```powershell
  $env:KUBECONFIG = ".\kubeconfig"
  ```
![image](https://github.com/user-attachments/assets/ac437229-11cb-4f8a-aa58-c0e6ca5e4fa7)

### Test:

```bash
kubectl get nodes
```
![image](https://github.com/user-attachments/assets/98aaa263-da3e-4d7c-92f0-2ef3224d63be)

---

## ✅ Step 5: Deploy the Sample Application

1. Save the provided YAML as `sample-app.yaml` in your folder.

2. Run:

```bash
kubectl apply -f sample-app.yaml
```
![image](https://github.com/user-attachments/assets/c2f78c62-3ca2-45c8-b542-e760899e9801)

**Expected output**:

```
deployment.apps/rabbitmq created
service/store-front created
```

---

## ✅ Step 6: Verify Everything is Running

```bash
kubectl get pods
kubectl get services
kubectl get svc store-front
```
![image](https://github.com/user-attachments/assets/396565b1-04e5-46d9-8b40-5bf984d46448)


![image](https://github.com/user-attachments/assets/dc339a46-d592-4bbc-b639-b806d97207cc)

![image](https://github.com/user-attachments/assets/2c331089-07ba-479f-b51f-2606120cf9f4)


Copy the `EXTERNAL-IP` of the `store-front` service and open it in your browser to view the app.

http://40.90.241.182

![image](https://github.com/user-attachments/assets/49552d83-e316-4ad6-99ce-87a9c270ef8e)

---

## ✅ Step 7: Push to GitHub

1. Initialize your repo:

```bash
git init
git remote add origin -cst8918-w25-h09
git add .
git commit -m "AKS Terraform Lab"
git push -u origin main
```



---

## ✅ Step 8: Cleanup Resources

```bash
kubectl delete -f sample-app.yaml
terraform destroy
```


