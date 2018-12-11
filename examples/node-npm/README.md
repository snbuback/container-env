# Node demo with Container-env

This project is just a demo show how to use container-env.

First clone, type `direnv allow` to make direnv trust in the file `.envrc`.
Second, build the container executing: `build`
It is done. Now your commands like `node` or `npm` (and all others in CONTAINER_WRAPPERS inside `.envrc`) will run inside the container seamlessly.

    ./my_script.js

The output should be:

    I'm running inside the container
    Ruby version 2.5.3 (2018-10-18) [x86_64-linux]

If you would like to use `irb` for example, you can use it normally, but it will run inside the container as a regular script.

When add a new dependencie with 
