AZURE_LOCATION ?= eastus
AZURE_RESOURCE_GROUP ?= "coco-$(AZURE_LOCATION)-rg"
AZURE_SUBSCRIPTION_ID ?= "null"

resourcegroup:
	az group create -g $(AZURE_RESOURCE_GROUP) -l $(AZURE_LOCATION)

gallery:
	az deployment group create -g $(AZURE_RESOURCE_GROUP) --template-file gallery-template.json --parameters @gallery-params.json

packer: ubuntu2004-snp-host.json cocopreview.json
	packer build -var-file cocopreview.json $<
