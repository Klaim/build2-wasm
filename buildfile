# Glue buildfile that "pulls" all the packages in the project.
#
import pkgs = {*/ -emsdk/ -build*/}

./: $pkgs
