{"data":{"mapUsers":"- groups:\n  - system:masters\n  userarn: ${terraform_user_arn}\n  username: terraformer\n- groups:\n  - system:masters\n  userarn: ${helm_user_arn}\n  username: helm-deployer\n- groups:\n  - aex:developer\n  userarn: ${k8s_developer_user_arn}\n  username: k8s-developer\n- groups:\n  - aex:power-user\n  userarn: ${k8s_power_user_arn}\n  username: k8s-power-user"}}