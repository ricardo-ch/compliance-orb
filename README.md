# SRE Compliance Orb

[![CircleCI Build Status](https://circleci.com/gh/ricardo-ch/compliance-orb.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/ricardo-ch/compliance-orb) [![CircleCI Orb Version](https://badges.circleci.com/orbs/ricardo/compliance-orb.svg)](https://circleci.com/orbs/registry/orb/ricardo/compliance-orb) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/ricardo-ch/compliance-orb/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

## Overview

The goal of the SRE compliance Orb is to make non-compliance to SRE standards visible.
There are currently 2 hard requirements which need to be fulfilled by the orb:
* No, gatekeepers. Failing checks must not stop the pipeline to run successful
* Checks need to run asynchronous to not increase the deployment time of the apps

By using the major version reference `ricardo/compliance-orb@1` in the projects `.circleci/config.yml` file, newly added tests will be automatically executed on new runs of the pipeline.
This will ensure the compliance Orb will add as less additional work to application maintainers as possible.

## How to use

To use the orb add this:
```yaml
orbs:
  compliance: ricardo/compliance-orb@<published_version>
```

to your `.circleci/config.yml` file.

Usage, examples and docs:

* [Commands](src/commands/README.md)
* [Executors](src/executors/README.md)
* [Jobs](src/jobs/README.md)
* [Scripts](src/scripts/README.md)
* [Orb](src/README.md)


Note that the orb relies on multiple context variables notably in order to authenticate to Kubernetes clusters.
Thus this orb will only work on Ricardo's dev|prod CircleCi context.

## How to develop

Make sure the added changes are respecting the requirements described in [Overview](#Overview)

### Versioning

* `Major` versions are only used for breaking changes.
* For new checks or functions use `minor`
* To fix issues in existing tests use `patch`

Versions are described in ["How to publish"](#How to Publish) section of this document.

### Local testing

Before pushing to repository run:

```shell
circleci orb pack src | circleci orb validate - 
```

The command above will validate syntax and format of your orb. The same checks are done during build on CircleCI.
Do not commit generated file: orb.yml.

## Resources

[CircleCI Orb Registry Page](https://circleci.com/orbs/registry/orb/ricardo/compliance-orb) - The official registry page of this orb for all versions, executors, commands, and jobs described.
[CircleCI Orb Docs](https://circleci.com/docs/2.0/orb-intro/#section=configuration) - Docs for using and creating CircleCI Orbs.

### How to Contribute

We welcome [issues](https://github.com/ricardo-ch/compliance-orb/issues) to and [pull requests](https://github.com/ricardo-ch/compliance-orb/pulls) against this repository!

### How to Publish
* Create and push a branch with your new features.
* When ready to publish a new production version, create a Pull Request from _feature branch_ to `master`.
* The title of the pull request must contain a special semver tag: `[semver:<segment>]` where `<segment>` is replaced by one of the following values.

| Increment | Description|
| ----------| -----------|
| major     | Issue a 1.0.0 incremented release|
| minor     | Issue a x.1.0 incremented release|
| patch     | Issue a x.x.1 incremented release|
| skip      | Do not issue a release|

Example: `[semver:major]`

* Squash and merge. Ensure the semver tag is preserved and entered as a part of the commit message.
* On CircleCi, ensure to manually approve the workflow. After approval, the orb will automatically be published to the Orb Registry.

For further questions/comments about this or other orbs, visit the Orb Category of [CircleCI Discuss](https://discuss.circleci.com/c/orbs).

## Status

This orb is not listed. To list it again use `circleci orb unlist <namespace>/<orb> <true|false> [flags]` or [see docs](https://circleci-public.github.io/circleci-cli/circleci_orb_unlist.html).

The currently released version is **not published**


## Known Issue

You may get this error when pushing a new PR,

```bash
The dev version of ricardo/compliance-orb@dev:alpha has expired. Dev versions of orbs are only valid for 90 days after publishing.
```

If you see this error, you need to publish a dev:alpha version manually. The fix is to run this:

```bash
circleci orb pack ./src | circleci orb validate -
circleci orb pack ./src | circleci orb publish -  ricardo/compliance-orb@dev:alpha
```
