# Container env

Container-env is a tool to help you run your development environment in a container transparently. Also, avoids local installation and makes the development environment very portable. Using container-env when you type `python` (or `ruby` or `node`) in your command line you run the tool inside the container. You don't need to worry about Docker command line, mount the project directory etc. Everything will work seamlessly.

Container-env fills a gap between docker tools. Today, if you would like to run a web server, you can do it easily using docker-compose. But if you want to run the python interpreter for example, or maybe a linter tool, frequently requires a local installation.

This approach makes your IDE compatible with tools running inside docker container because these tools will run as they are installed locally.

Container-env works wrapping all command line tools to run inside a Docker container and add them to the PATH. So, your command will run like a local command but inside a container.

## Install

```shell
bash <(curl -fsSL https://raw.githubusercontent.com/snbuback/container-env/master/install.sh)"
```

   This tool runs using [direnv](https://direnv.net). The installer will install direnv for you but you may need to add the direnv hook in your shell environment.

   Below few examples how to integration direnv. You can have more information on the [direnv website](https://direnv.net).

* For Bash
  
  In the ~/.bashrc add:
```shell
eval "$(direnv hook bash)"
```

* For ZSH
  In the ~/.zshrc (or ~/.zprofile if you use oh-my-zsh) add:
```shell
eval "$(direnv hook zsh)"
```

## How to use

Go to the base directory of your project, normally the base directory of git and type:

      direnv edit .

This will open an editor. Type the content:

      CONTAINER_NAME=fedora
      CONTAINER_WRAPPERS=(python)

      container_layout

After you close your edit, when you type `python3` or `vi` in you command line these commands will run inside the container
with access to the local folder.

Bellow few examples for some programming languages.

## Examples

   Look at the examples in the example directory.

* [Python](./examples/python-pip)
* [Ruby](./examples/ruby)
* [Node](./examples/node-npm)

## Environment variables

The are some variables you can change in your .envrc to configure the script:

| Variable               | Default                                                    | Definition                                                             |
| ---------------------- | ---------------------------------------------------------- | ---------------------------------------------------------------------- |
| CONTAINER_PROJECT_DIR  | directory of .envrc file                                   | Project base path. This directory is mounted as volume for each script |
| CONTAINER_APP_DIR      | $CONTAINER_PROJECT_DIR                                     | Working directory for you application inside the container             |
| CONTAINER_ARGS         | --rm -i -P -v \$CONTAINER_PROJECT_DIR:\$CONTAINER_APP_DIR} | Basic docker command arguments                                         |
| CONTAINER_EXTRA_ARGS   | (empty)                                                    | Any extra docker command arguments. Add your customizations here.      |
| CONTAINER_EXE          | (docker executable path)                                   | Docker executable path                                                 |
| CONTAINER_AUTO_WRAPPER | 1                                                          | Generate the auto-wrappers                                             |
| CONTAINER_WRAPPERS     | (python ruby node java php)                                | Executable name to generates path to                                   |

## Auto-wrappers

If the environment variable `CONTAINER_AUTO_WRAPPER` is 1 (default), some scripts are generated automatically even if
they are not in the `CONTAINER_WRAPPERS` list.

* `shell`: Execute bash inside your container. Be aware that any change in the container outside the project dir will be losted.
* `build`: Execute `docker build -t $CONTAINER_NAME .` to build your project image. Generated only if there is a `Dockerfile` in the project dir.
* `up` / `down`: Execute `docker-compose up` or `docker-compose down`. Generated only if there is a `docker-compose.yml` in the project dir.
