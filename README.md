# terraform-spinnaker

## Intallation

1. Enable **Cloud Resource Manager API** in GCP project where Spinnaker is hosted.

2. Add proper Moniker annotations to all deployments. For example:
```
annotations {
  "moniker.spinnaker.io/application" = "api" 
}
```

3. Rename `terraform.tfvars.template` into `terraform.tfvars` and fill with proper values

4. Initialize terraform with proper GCS backend
```
terraform init
```

2. Run terraform phase 1
```
terraform plan -out=tfplan # select phase 1
terraform apply tfplan
```

3. Run terraform phase 2 (once Spinnaker Kubernetes deployment is ready)
```
terraform plan -out=tfplan # select phase 2
terraform apply tfplan
```

Docker base image: https://github.com/spinnaker/halyard/blob/master/Dockerfile

## TODO:
* Integration with Stackdriver https://www.spinnaker.io/setup/monitoring/stackdriver/