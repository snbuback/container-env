# Container-env

Container-env fills a gap between docker tools. Today, if you would like to run a web server, you can do it easily using docker-compose. But if you want to run an interactive python interpreter for instance, or maybe a linter tool frequently requires a local installation. Container-env works wrapping all command line tools to run inside a Docker container and add them to the PATH. So, the tools will look like a local installation, but they will run inside the container, creating a totally isolated development environment. It is inspired in tools like [virtualenv](https://virtualenv.pypa.io/en/latest/) (for python), [rvm](https://rvm.io) (for ruby) or [nvm](https://github.com/creationix/nvm) (for nodejs) but can rule all of them.

Take a look in the example below. Let's suppose you don't have `go` installed and wants to start the development with it.

![Image of Yaktocat](demo.gif)

So, container-env keeps your development environment clean, since everything will run inside a container. Your linter tool, for example, eslint/pylint/pylama/pyflakes/rubocop will work exactly as a local installation but running inside the container.

To achieve that container-env creates a script wrapper for these tools. So, when you run container-env starts a temporary container, forwarding all arguments to the tool. Also, it mounts the project directory inside the container so the interaction inside the container will look like any local interaction.

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
* [Go](./examples/golang)

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
