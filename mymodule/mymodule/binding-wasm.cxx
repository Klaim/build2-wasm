#include "mymodule.hxx"

#include <emscripten/bind.h>


EMSCRIPTEN_BINDINGS(my_module) {
    emscripten::function("hello", &mymodule::hello);
}

