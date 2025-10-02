STACK_DIR := stacks/main
TFVARS    := ../../config/common.auto.tfvars

.PHONY: init plan apply destroy

init:
	terraform -chdir=$(STACK_DIR) init

plan:
	terraform -chdir=$(STACK_DIR) plan -var-file=$(TFVARS)

apply:
	terraform -chdir=$(STACK_DIR) apply -var-file=$(TFVARS)

destroy:
	terraform -chdir=$(STACK_DIR) destroy -var-file=$(TFVARS)