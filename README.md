# Github Access, but with Terraform

Based on [this repo](https://github.com/hashicorp-education/learn-terraform-github-user-teams).


# HOW TO RUN

Always start by ensuring your session is setup: 
```
export GITHUB_TEST_PAT="ghp_yada-yada"
direnv allow
```

On your first run:
```shell
pushd tf
# have to do this one first, so it knows about all the pieces
terraform apply -target github_team.all
# then you can do everything
terraform apply
popd
```

From here on out, just run: 
```
pushd tf
terraform apply
popd
```


## Notes

- CSVs are all stored in `data/`
- The name of `membership/` and `teams/` CSVs must match the __SLUG__ of the targeted team.