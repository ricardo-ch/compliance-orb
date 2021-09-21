# scripts/

This is where any scripts you wish to include in your orb can be kept. This is encouraged to ensure your orb can have all aspects tested, and is easier to author, since we sacrifice most features an editor offers when editing scripts as text in YAML.

As a part of keeping things seperate, it is encouraged to use environment variables to pass through parameters, rather than using the `<< parameter. >>` syntax that CircleCI offers.

# Including Scripts

Utilizing the `circleci orb pack` CLI command, it is possible to import files (such as _shell scripts_), using the `<<include(scripts/script_name.sh)>>` syntax in place of any config key's value.

```yaml
# commands/check_container_user_permissions.yml
description: >
  This command check's if target docker image user is root user
parameters:
  username:
    type: string
  password:
    type: string
  url:
    type: string
  imageName:
    type: string
    default: ""
steps:
  - docker_registry:
      username: << parameters.username >>
      password: << parameters.password >>
      url: << parameters.url >>
  - run:
      name: pull target image
      command: |
        docker pull $(isopod image)
  - run:
      environment:
        IMAGE_NAME: << parameters.imageName >>
      name: check for sudo permissions and root user in Container
      command: <<include(scripts/check_container_user_permissions.sh)>>
```

```shell
# scripts/check_container_user_permissions.sh
#!/usr/bin/env sh

if [ -z "${IMAGE_NAME}" ];
then
  TARGET_IMAGE=$(isopod image)
else
  TARGET_IMAGE="${IMAGE_NAME}"
fi

...
...
...

get_sudo_permissions


```