## Running Terraform Scripts

* Install Terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli
* **For AWS scripts only** Setup AWS profiles: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html

  Either use the `default` profile, or one of the mechanisms here: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

  _Note: Not sure if you need AWS CLI installed, I suspect not_

  _Another Note: Your user will need the relevant permissions on the resources you are manipulating_
* Terminal to the folder with the `.tf` file(s)
* `terraform apply`
 
### Terraform Logs
To enable Terraform logs, you have to set two environment variables, namely the **TF_LOG** and **TF_LOG_PATH** variables. TF_LOG is the log level and can be TRACE, DEBUG, WARNING or ERROR. TF_LOG_PATH is the file path for logging to file. Terraform can only log to file. Eg for Powershell you will run these two commands:
* $TF_LOG="DEBUG"
* $TF_LOG_PATH="terraform_logs.txt"

These only last for the Powershell session.

