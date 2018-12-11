# Python demo with Container-env

This project is just a demo show how to use container-env.

First clone, type `direnv allow` to make direnv trust in the file `.envrc`.
Second, build the container executing: `build`
It is done. Now your commands like `python` or `pylama` (and all others in CONTAINER_WRAPPERS inside `.envrc`) will run inside the container seamlessly.

       ./my_script.py

The output should be:

    Hi, I'm running inside the container
    Python version= 3.7.1 (default, Nov 16 2018, 06:24:50)
    [GCC 6.3.0 20170516]

If you would like to use pylama for example, you can use it normally, but it will run inside the container as a regular script.

    pylama my_script.py

The output is:

    my_script.py:7:1: W0612 local variable 'a' is assigned to but never used [pyflakes]
