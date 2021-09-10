# Commands

Easily add and author [Reusable Commands](https://circleci.com/docs/2.0/reusing-config/#authoring-reusable-commands) to the `src/commands` directory.

Each _YAML_ file within this directory will be treated as an orb command, with a name which matches its filename.

## Docker registry

**Name:** _docker_registry_ <br>
**Description:** Logs in to the container registry the image to check is stored in  

**Parameters:**

* **username** (optional): Username to login to the Container registry to pull the image. Default value defined in context env var `$DOCKER_JFROG_USERNAME`
* **password** (optional): Password to login to the Container registry to pull the image. Default value defined in context env var `$DOCKER_JFROG_PASSWORD`
* **url** (optional): URL to the image in the Container registry to pull the image. Default value defined in context env var: `$DOCKER_JFROG_REGISTRY_URL`

Example:
```yaml
steps:
  - docker_registry:
      username: << parameters.username >>
      password: << parameters.password >>
      url: << parameters.url >>
```

## Container user permissions

**Name:** _check_container_user_permmissions_ <br>
**Description:** Command _check_container_user_permmissions_ checks if provided _image_ using a user with root permissions (UID == 0) or having `sudo` abilities.

**Parameters:**

* **imageName** (optional): Name of the container image to check. If not set value is taken from `isopod image` command.
* **username** (optional): Username to login to the Container registry to pull the image. Default value defined in context env var `$DOCKER_JFROG_USERNAME`
* **password** (optional): Password to login to the Container registry to pull the image. Default value defined in context env var `$DOCKER_JFROG_PASSWORD`
* **url** (optional): URL to the image in the Container registry to pull the image. Default value defined in context env var: `$DOCKER_JFROG_REGISTRY_URL`


Examples:
```yaml
  development_workflow:
    jobs:
      - compliance/sre_compliance_checks:
          context: dev
          imageName: "nginx:latest" # Specify a container name if 'isopod image' is not applicable
          requires:
            - build_image
```
or 
```yaml
  development_workflow:
    jobs:
      - compliance/sre_compliance_checks:
          context: dev
          requires:
            - build_image
```
## See:
 - [Orb Author Intro](https://circleci.com/docs/2.0/orb-author-intro/#section=configuration)
 - [How to author commands](https://circleci.com/docs/2.0/reusing-config/#authoring-reusable-commands)
