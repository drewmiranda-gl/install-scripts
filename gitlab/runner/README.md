# Install

[https://docs.gitlab.com/runner/install/](https://docs.gitlab.com/runner/install/)

# Register

[https://docs.gitlab.com/runner/register/](https://docs.gitlab.com/runner/register/)

```sh
sudo gitlab-runner register \
    --non-interactive \
    --url "https://gitlab.com/" \
    --token "$RUNNER_TOKEN" \
    --executor "docker" \
    --docker-image alpine:latest \
    --description "docker-runner"
```