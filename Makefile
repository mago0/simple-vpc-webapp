.PHONY: all plan apply configure destroy refresh

export TF_VAR_aws_access_key = ${AWS_ACCESS_KEY}
export TF_VAR_aws_secret_key = ${AWS_SECRET_KEY}
export TF_VAR_aws_pubkey = ${AWS_PUBKEY}
export ANSIBLE_HOST_KEY_CHECKING=False

all: plan apply configure

plan:
	terraform plan -out terraform.tfplan

apply:
	terraform apply

configure:
	ansible-playbook -i bin/terraform.py -u ubuntu playbook.yml

destroy:
	terraform plan -destroy -out terraform.tfplan
	terraform apply terraform.tfplan

refresh:
	terraform refresh
