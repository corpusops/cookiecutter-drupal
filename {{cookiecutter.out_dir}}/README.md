{%- set envs = ['dev', 'qa', 'staging', 'prod', 'preprod'] %}
{%- set aenvs = [] %}{%- for i in envs %}{% if cookiecutter.get(i+'_host', '')%}{% set _ = aenvs.append(i) %}{%endif%}{%endfor%}
# Initialize your development environment

All following commands must be run only once at project installation.

# TL;DR;

```sh
git checkout
git submodule init # only the fist time
git submodule update --recursive
./control.sh init
./control.sh build
./control.sh up
./control.sh ps
./control.sh userexec bin/composerinstall
./control.sh userexec DRUPAL_FORCE_INSTALL=1 bin/install.sh
./control.sh userexec bin/post_update.sh
# with 127.0.0.1 {{cookiecutter.lname}}.local in /etc/hosts
./control.sh cypress_open_local
./control.sh userexec bin/drush uli
```

## First clone

```sh
# check the remote protocol you may want to choose between http and ssh
git clone --recursive {{cookiecutter.git_project_url}}
{%if cookiecutter.use_submodule_for_deploy_code-%}git submodule init # only the fist time
git submodule update --recursive{%endif%}
```

## Before using any ansible command: a note on sudo

If your user is ``sudoer`` but is asking for you to input a password before elavating privileges,
You will need to add ``--ask-become-pass`` (or in earlier ansible versions: ``--ask-sudo-pass``) and maybe ``--become`` to any of the following ``ansible alike`` commands.

## Install docker and docker compose

if you are under debian/ubuntu/mint/centos you can do the following:

```sh
.ansible/scripts/download_corpusops.sh
.ansible/scripts/setup_corpusops.sh
local/*/bin/cops_apply_role --become \
    local/*/*/corpusops.roles/services_virt_docker/role.yml
```

... or follow official procedures for
  [docker](https://docs.docker.com/install/#releases) and
  [docker-compose](https://docs.docker.com/compose/install/).

## Update corpusops

You may have to update corpusops time to time with

```sh
./control.sh up_corpusops
```

## Configuration

Use the wrapper to init configuration files from their ``.dist`` counterpart
and adapt them to your needs.

```bash
./control.sh init
```

## Login to the app docker registry

You need to login to our docker registry to be able to use it:


```bash
docker login {{cookiecutter.docker_registry}}  # use your gitlab user
```

{%- if cookiecutter.registry_is_gitlab_registry %}
**⚠️ See also ⚠️** the
    [project docker registry]({{cookiecutter.git_project_url.replace('ssh://', 'https://').replace('git@', '')}}/container_registry)
{%- else %}
**⚠️ See also ⚠️** the makinacorpus doc in the docs/tools/dockerregistry section.
{%- endif%}

# Use your development environment

## Update submodules

Never forget to grab and update regulary the project submodules:

```sh
git pull{% if cookiecutter.use_submodule_for_deploy_code
%}
git submodule init # only the fist time
git submodule update --recursive{%endif%}
```

## Control.sh helper

You may use the stack entry point helper which has some neat helpers but feel
free to use docker command if you know what your are doing.

```bash
./control.sh usage # Show all available commands
```

## Start the stack

After a last verification of the files, to run with docker, just type:

```bash
# First time you download the app, or sometime to refresh the image
./control.sh pull # Call the docker compose pull command
./control.sh up # Should be launched once each time you want to start the stack
```

You may need some alteration on your local `/etc/hosts` to reach the site using
domains and ports declared in docker.env

For example if you have:

```bash
./control.sh dcompose config\
 |docker run -i mikefarah/yq e '.services.drupal.environment' -|grep ABSOLUT
ABSOLUTE_URL_SCHEME=http
ABSOLUTE_URL_DOMAIN={{cookiecutter.local_domain}}
ABSOLUTE_URL_PORT={{cookiecutter.local_http_port}}
```

The project should be reached in http://{{cookiecutter.local_domain}}:{{cookiecutter.local_http_port}} and {{cookiecutter.local_domain}} must resolve to 127.0.0.1.

If you launch a `up` action on dev local environement the application is not yet installed. Shared directories with your local installation, containing things like the *vendors*, are empty, and the database may also be empty. A first test may needs commands like these ones :

```sh
./control.sh up
./control.sh userexec bin/composerinstall
./control.sh userexec bin/install.sh
# or
./control.sh userexec DRUPAL_FORCE_INSTALL=1 bin/install.sh
# or even, if you do not have any config exported yet
./control.sh userexec NO_EXISTING_CONFIG=1 DRUPAL_FORCE_INSTALL=1 bin/install.sh
# and then
./control.sh userexec bin/post_update.sh
```

## Troubleshoot problems

You may need to check for problems by listing containers and checking logs with

```sh
./control.sh ps
# here finding a line like this one:
foobar_{{cookiecutter.app_type}}_1_4a022a7c19bd              /bin/sh -c dockerize -wait ...   Exit 1
# note the exit 1 is not a good news...
# asking for logs
docker logs -f foobar_{{cookiecutter.app_type}}_1_4a022a7c19bd
```

In case of problems in the init.sh script of the {{cookiecutter.app_type}} container you can add some debug by adding a SDEBUG key in the env of the container, you can have even more details by adding an empty NO_STARTUP_LOG env. So, for example, edit your `docker.env` script and add:

```sh
SDEBUG=1
NO_STARTUP_LOG=
```

## Start a shell inside the {{cookiecutter.app_type}} container

- for user shell

    ```sh
    ./control.sh usershell
    ```

- for root shell

    ```sh
    ./control.sh shell
    ```

**⚠️ Remember ⚠️** to use `./control.sh up` to start the stack before.

## Run plain docker-compose commands

- Please remember that the ``CONTROL_COMPOSE_FILES`` env var controls which docker-compose configs are use (list of space separated files), by default it uses the dev set.

    ```sh
    ./control.sh dcompose <ARGS>
    ```

## Rebuild/Refresh local docker image in dev

```sh
control.sh buildimages
```

## Calling drush & console commands

```sh
./control.sh console [options]
./control.sh drupal [options]
./control.sh drush [options]
# For instance:
# ./control.sh console
# ./control.sh drush cache-rebuild
# ...
```

**⚠️ Remember ⚠️** to use `./control.sh up` to start the stack before.

## Run tests

```sh
./control.sh tests
# also consider: linting|coverage
```

**⚠️ Remember ⚠️** to use `./control.sh up` to start the stack before.

## File permissions

If you get annoying file permissions problems on your host in development, you can use the following routine to (re)allow your host
user to use files in your working directory


```sh
./control.sh open_perms_valve
```

## Docker volumes

Your application extensivly use docker volumes. From times to times you may
need to erase them (eg: burn the db to start from fresh)

```sh
docker volume ls  # hint: |grep \$app
docker volume rm $id
```

## Reusing a precached image in dev to accelerate rebuilds

Once you have build once your image, you have two options to reuse your image as a base to future builds, mainly to accelerate buildout successive runs.

- Solution1: Use the current image as an incremental build: Put in your .env

    ```sh
    {{cookiecutter.app_type.upper()}}_BASE_IMAGE={{ cookiecutter.docker_image }}:latest-dev
    ```

- Solution2: Use a specific tag: Put in your .env

    ```sh
    {{cookiecutter.app_type.upper()}}_BASE_IMAGE=a tag
    # this <a_tag> will be done after issuing: docker tag registry.makina-corpus.net/mirabell/chanel:latest-dev a_tag
    ```

## Integrating an IDE


### Using VSCode

Adding this to ``.vscode/settings.json`` would help to give you a smooth editing experience

```json
{
  "breadcrumbs.enabled": true,
  "css.validate": true,
  "diffEditor.ignoreTrimWhitespace": false,
  "editor.tabSize": 2,
  "editor.autoIndent": "full",
  "editor.insertSpaces": true,
  "editor.formatOnPaste": true,
  "editor.formatOnSave": true,
  "editor.renderControlCharacters": true,
  "editor.renderWhitespace": "boundary",
  "editor.wordWrapColumn": 100,
  "editor.wordWrap": "bounded",
  "editor.detectIndentation": true,
  "editor.rulers": [
    100
  ],
  "files.associations": {
    "*.inc": "php",
    "*.module": "php",
    "*.install": "php",
    "*.theme": "php",
    "*.tpl.php": "php",
    "*.test": "php",
    "*.php": "php",
    "*.info": "ini",
    "*.html": "twig"
  },
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "html.format.enable": true,
  "html.format.wrapLineLength": 80,
  "telemetry.enableTelemetry": false,

  /* Empty Indent */
  "emptyIndent.removeIndent": true,
  "emptyIndent.highlightIndent": false,
  "emptyIndent.highlightColor": "rgba(246,36,89,0.6)",

  // Validate --------
  "php.validate.enable": true,
  "php.validate.run": "onType",

  // IntelliSense --------
  "php.suggest.basic": false,

  // Intelephense and Drupal >8 only. This should be set to the path to core/index.php.
  "intelephense.environment.documentRoot": "app/www/index.php",
  "intelephense.format.enable": false,
  "php-docblocker.gap": true,
  "php-docblocker.useShortNames": true,
  "emmet.includeLanguages": {
    "twig": "html"
  },
  "files.eol": "\n",
  }
```

Adding this to ``.vscode/settings.json`` would help to give you a smooth editing experience

```json
  {
    "files.watcherExclude": {
        "**/.git/objects/**": true,
        "**/.git/subtree-cache/**": true,
        "**/node_modules/*/**": true,
        "**/local/*/**": true,
      }
  }
```

### PHPCS Linter

- You need to have `drupal/coder` added in your composer.json.

- In the composer.json, add `phpcs --config-set installed-path ../../drupal/coder/coder_sniffer` in the `post-install-cmd` and `post-update-cmd` `scripts` steps.

Using the **relative path** is **important** to get phpcs working from inside the container (`vendor/bin/phpcs`) and from outside (IDE).

- There is a default phpcs.xml file in app directory, adapt it to your needs (especially the `<file>` sections).

- Add the PHPCS extension (**Not** the one by by Ioannis Kappas, ikappas.phpcs, **use intead the shevaua one**, shavaua.phpcs).

- Alter your `.vscode/settings.json` file

It should contain this part for phpcs:

```json
{
  // PHP CS --------
  "phpcs.enable": true,
  "phpcs.executablePath": "./app/vendor/squizlabs/php_codesniffer/bin/phpcs",
  "phpcs.standard": "./app/phpcs.xml",
  "phpcs.autoConfigSearch": false,
  "phpcs.lintOnOpen": false,
  "phpcs.lintOnSave": true,
  "phpcs.lintOnType": true,
  "phpcs.lintOnlyOpened": true,
  "phpcs.showWarnings": true,
  "phpcs.showSources": true,
}
```

As you see phpcs only runs for edited files (with red in the IDE editor and messages in Problems console).
If you want to check all the files in one call run:

```
./control.sh userexec "vendor/bin/phpcs --standard=./phpcs.xml"
```

### Debugging with VSCode

FIXME

## Regenerate project doc

### simple way

We'll use the docker way, you may need to redo a `control.sh build` if your stack
does not have a doc container yet (message No such service: docs).

Then run:

```bash
./control.sh make_docs
```

This will build a temporary docs container, mounting the local directory `/docs/` and `local/` source directories, and reseting your local `app/var/private/docs/` directory content.

So you may need these steps after that:

```bash
git add -f app/var/private/docs/*/*
git commit -m "Generate docs" app/var/private/docs/
```

## Doc for deployment on environments

- [See here](./docs/README.md)

## FAQ

### View environments values & secrets

All env specific data is stored in `.ansible/inventory/<env>/clear.yml`, with shared variables defaults in `.ansible/inventory/all/clear.yml`, and defaults not defined here are defined in other ansible yml like `local/drupal-deploy-common/.ansible/playbooks/roles/drupal_vars/defaults/main.yml`.

For secret variables (`.ansible/inventory/<env>/default.yml`) you will need the VAULT PASSWORD, stored in Bitwarden. Then:

.. code:: sh

    export A_ENV_NAME=prod # or dev, preprod, etc.
    .ansible/scripts/edit_vault.sh

### Nginx always restarting

If you get troubles with the nginx docker env restarting all the time, try recreating it :

```bash
docker-compose -f docker-compose.yml -f docker-compose-dev.yml up -d --no-deps --force-recreate nginx backup
```

If you get the same problem with the {{cookiecutter.app_type}} docker env :

```bash
docker-compose -f docker-compose.yml -f docker-compose-dev.yml stop {{cookiecutter.app_type}} db
docker volume rm ICIUnNom-postgresql # check with docker volume ls
docker-compose -f docker-compose.yml -f docker-compose-dev.yml up -d db
# wait for database stuff to be installed
docker-compose -f docker-compose.yml -f docker-compose-dev.yml up {{cookiecutter.app_type}}
```

## Pipelines workflows tied to deploy environments and built docker images
### TL;DR
- We use deploy branches where some git **branches** are dedicated to deploy related **gitlab**, **configuration managment tool's environments**, and **docker images tags**.<br/>
- You can use them to deliver to a specific environment either by:
    1. Not using promotion workflow and only pushing to this branch and waiting for the whole pipeline to complete the image build, and then deploy on the targeted env.
    2. Using tags promotion: "Docker Image Promotion is the process of promoting Docker Images between registries to ensure that only approved and verified images are used in the right environments, such as production."<br/>
        - You **run or has run a successful pipeline with the code you want to deploy**, (surely ``{{cookiecutter.main_branch}}``).
        - You can then **``promote`` its tag** to either **one or all** env(s) with the ``promote_*`` jobs and reuse the previously produced tag.<br/>
        - After the succesful promotion, you can then manually **deploy on the targeted env(s)**.

### Using promotion in practice
- As an example, we are taking <br/>
  &nbsp;&nbsp;&nbsp;&nbsp;the ``{{aenvs[-2]}}`` branch which is tied to <br/>
  &nbsp;&nbsp;&nbsp;&nbsp;the {{aenvs[-2]}} **inventory ansible group**<br/>
  &nbsp;&nbsp;&nbsp;&nbsp;and deliver the {{aenvs[-2]}} **docker image**<br/>
  &nbsp;&nbsp;&nbsp;&nbsp;and associated resources on the **{{aenvs[-2]}} environment**.
- First, run an entire pipeline on the branch (eg:``{{cookiecutter.main_branch}}``)  and the commit you want to deploy.<br/>
  Please note that it can also be another branch like `stable` if `stable` branch was configured to produce the `stable` docker tags via the `TAGGUABLE_IMAGE_BRANCH` [`.gitlab-ci.yml`](./.gitlab-ci.yml) setting.
- Push your commit to the desired related env branche(s) (remove the ones you won't deploy now) to track the commit you are deploying onto

    ```sh
    # on local main branch
    git fetch --all
    git reset --hard origin/{{cookiecutter.main_branch}}
    git push --force origin{% for i in aenvs %} HEAD:{{i}}{%endfor %}
    ```
    1. Go to your gitab project ``pipelines`` section and immediately kill/cancel all launched pipelines.
    2. Find the killed pipeline on the environment (branch) you want to deploy onto (and if you don't have it, launch one via the ``Run pipeline`` button and **immediatly kill** it),<br/>
       Click on the ``canceled/running`` button link which links the pipeline details), <br/>
       It will lead to a jobs dashboard which is really appropriated to complete next steps.<br/>
       Either run:
        - ``promote_all_envs``: promote all deploy branches with the selected ``FROM_PROMOTE`` tag (see just below).
        - ``promote_single_env``: promote only this env with the selected ``FROM_PROMOTE`` tag (see just below).
        - Indeed, **in both jobs**, you can override the default promoted tag which is ``latest`` with the help of that ``FROM_PROMOTE`` pipeline/environment variable.<br/>
          This can help in those following cases:
            - If you want `production` to be deployed with the `dev` image, you can then set `FROM_PROMOTE=dev`.
            - If you want `dev` to be deployed with the `stable` image produced by the `stable` branch, you can then set `FROM_PROMOTE=stable`.
    3. Upon successful promotion, run the ``manual_deploy_$env`` job. (eg: ``manual_deploy_dev``)


# Teleport (load one env from one another)
init your vault (see [`docs/deploy.md`](./docs/README.md#docs#generate-vault-password-file)).

```sh
CORPUSOPS_VAULT_PASSWORD="xxx" .ansible/scripts/setup_vaults.sh
```

```sh
# Generate SSH deploy key locally for ansible to work and dump
# the ssh key contained in inventory in a place suitable
# by ssh client (ansible)
.ansible/scripts/call_ansible.sh .ansible/playbooks/deploy_key_setup.yml
```

## Load a staging/prod database on another env
controller is localhost, the box where you run the playbook, so your laptop, but can be any configured ansible host.

```sh
.ansible/scripts/call_ansible.sh -vvvv .ansible/playbooks/teleport.yml \
-e "{teleport_destination: controller, teleport_origin: prod, teleport_debug: true}"
```

Think to look after the site homepage to see if it's avalaible, and in case it's on a 503 error or else, but the teleport did not failed, reboot the stack

```sh
./control.sh down
./control.sh up
```

If your CSS styles are broken, rebuild them and flush drupal cache

```sh
npm install && npm ci
# or
yarn install && yarn build

./control.sh  userexec "cd www && ../bin/drush cr"
```
