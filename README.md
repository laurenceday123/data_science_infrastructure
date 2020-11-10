# data_science_infrastructure
Terraform, Azure and CICD templates 

## Terraform
Terraform can be used to provision cloud resources and infrastructure in Azure. As opposed to provisioning resources through the Azure UI, Terraform is clear, explicit and consistent in what it creates.  Terraform is used to write a script outlining what resources are required. Terraform is for infrastructure as code, and when combined with github actions, enables infrastructure to be version controlled. Resources can be rapidly provisioned, in the cases of accidental deletion, or replicating infrastructure to alternative subscriptions.

### Step 1 - Create a service principal and add to secrets
``` shell
az ad sp create-for-rbac --name DS_PLAY --role "Contributor"--scopes /subscriptions/<SUBSCRIPTION ID>/resourceGroups/data-science --sdk auth
```
