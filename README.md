# simple-vpc-webapp

Installs the Word Game application via Docker in a simple VPC.

## Requirements

Terraform and Ansible must be installed on your local system.

Built with:

    ansible 2.2.0.0
    terraform 0.8.4

## Setup

Must export AWS credentials and EC2 keypair-pubkey

    export AWS_ACCESS_KEY="..."
    export AWS_SECRET_KEY="..."
    export AWS_PUBKEY="ssh-rsa ..."

## Build

From the project root, run `make all`

Near the bottom of the build, the public IP will be displayed as such:

    TASK [print public ip] *********************************************************
    ok: [app1] => {
        "msg": "xx.xx.xx.xx"
    }

Browse to the public IP to view the app.

## Teardown

From the project root, run `make destroy`
