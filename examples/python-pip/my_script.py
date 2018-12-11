#!/usr/bin/env python
import sys


def unused_function():
    # intentional unused variable
    a = 1
    return


print("Hi, I'm running inside the container")
print("Python version=", sys.version)
