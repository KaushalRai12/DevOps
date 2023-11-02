# Prod Global

These are global resources for the prod environment. It includes stuff like users and patch management policies.

Somehow in the state migration terraform lost knowledge of the existing users. So `terraform apply` doesn't run cleanly.

Once we're settled, we can rerun to clean up. For now it's functional
