# data_science_infrastructure
Terraform, Azure and CICD templates 

## Terraform
Terraform can be used to provision cloud resources and infrastructure in Azure. As opposed to provisioning resources through the Azure UI, Terraform is clear, explicit and consistent in what it creates.  Terraform is used to write a script outlining what resources are required. Terraform is for infrastructure as code, and when combined with github actions, enables infrastructure to be version controlled. Resources can be rapidly provisioned, in the cases of accidental deletion, or replicating infrastructure to alternative subscriptions.

### Step 1 - Create a service principal and add to secrets
``` shell
az ad sp create-for-rbac --name DATA_SCIENCE --role "Contributor"--scopes /subscriptions/<SUBSCRIPTION ID>/resourceGroups/resource_group_name --sdk auth

output
{
"ClientId: "****************************************"
"ClientSecret": "****************************************"
"SubscriptionId": "****************************************"
"TenantId:" "****************************************"
}
```

### Step 2 - Create remote backend state file in Azure Storage Container
This is created through the UI or CLI and the only manual step - a place to store the state file for terraform. 

This  should be set up as described below:
- A resource group called e.g. rg-terraform-infrastructure in the relevant subscriptions
- within each, a storage account called stdstfstate (storage-data-science-terraform-state)
- Within the storage account, a container called ctdstfstate (container-data science-terraform-state)
- From the access keys for the container, the primary key is required which should then be placed in Github secrets
- Assign the rg to the relevant security group so that users can interact with it

``` shell
CLI Example
az group create --name "rg-terraform-infrastructure" --location "uksouth" --subscription ********
az storage account create -n "stdstfstate" -g "rg-terraform-infrastructure" -l "uksouth" --kind StorageV2
az storage account keys list -g rg-terraform-infrastructure -n stdstfstate
[
	{
	"KeyName": Key1,
	"permissions": "Full",
	"value": <ACCOUNT KEY>
	}
]

az storage container create --name ctdstfstatestag --subscription ******** --account-name stdstfstate --account-key <ACCOUNT KEY>
```


