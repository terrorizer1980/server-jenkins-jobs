# Jenkins Jobs

This repo contains the Jenkins Job Builder definitions. This is
split into various folders based on the project. This way specific
projects can be updated without affecting the other projects.

## Automated Deployment

Deployment takes place via the admin-deploy job. It is run every
15mins, checks out this repo, and deploys all jobs in all folders.

The tool uses [Jenkins Job builder]
(https://pypi.python.org/pypi/jenkins-job-builder) to
deploy the jobs. Version '2.0.0.0b2' or greater *required* to
support all the features used.

The only time a job is updated is if a change is committed to this
repo. If a change is made to a job manually, it will not be
overridden.

## Development

### Installing Jenkins Job Builder

To install Jenkins Job Builder, use pip as the version in the
distro is too old. You *must* also specify the version as the
default installed version is too old to support all features:

```shell
pip install --user jenkins-job-builder==2.0.0.0b2
PATH=$PATH:/home/$USER/.local/bin
```

### Configuration

Jenkins job builder needs a configuration file to know where
to point to update jobs. Here is an example file, which should
be kept in `/home/$USER/.config/jenkins_jobs/jenkins_jobs.ini`:

```ini
[jenkins]
user=jenkins
password=1234567890abcdef1234567890abcdef
url=https://jenkins.example.com
query_plugins_info=False
```

### Testing Changes

To test changes use jenkins-jobs:

```shell
jenkins-jobs test <directory of tests>
```

If the return code is 0, a large amount of XML will be
generated, meaning the build is good.

If there are any errors the, at times vague, message will be
printed.

### Manual Deployment

To manually update jobs run the following:

```shell
git clone https://github.com/CanonicalLtd/server-jenkins-jobs
cd server-jenkins-jobs
jenkins-jobs --ignore-cache update <directory of tests>
```

This will ignore any cache of deployed jobs and force a
redeploy of whatever jobs are in that directory.
