# build2-wasm-lib

0. Install dependencies and Emscriptem SDK: run (maybe after reading) `./install_emsdk_linux.sh` to install the sdk in `./emsdk/`.
    Also `./update_emsdk_latest_stable.sh` can be run to update the sdk, it's run as part of the install.
1. Run the `source` command at the end of the install log, or `source ./emsdk/emsdk_env.sh` (on linux). This will setup the environment the sdk needs to function.
2. The options to use in the WASM configurations are in `config-wasm.options`, so you can do `bdep init -C build-wasm cc --options-file ./config-wasm.options`.
3. Building should work, however running the output requires `node path/to/output/file` (which is a javascript file with a .wasm file next to that file).
    Here `node` is a `nodejs` provided by the sdk.

NOTES GATHERED WHILE EXPERIMENTING
----------------------------------

0. The EMSDK is very easy to install and upated, but this is because it's relying on last git version + an internal dependency management tool.
    The `source`-ing changing the environnement for emsdk might be done by `build2` in the future?

1. `em++` and `emcc` are accepted by `build2` without any obvious issue, as expected, probably because they are `clang` variations.
    I attempted: `bpkg create cc config.cxx=em++ config.c=emcc` without any obvious issue.

2. When compiling a project generated from `bdep new -t lib` (without any modification):
    ```
    em++: warning: linking a library with `-shared` will emit a static object file.  This is a form of emulation to support existing build systems.  If you want to build a runtime shared library use the SIDE_MODULE setting. [-Wemcc]
    em++: warning: ignoring unsupported linker flag: `-soname` [-Wlinkflags]
    em++: warning: ignoring unsupported linker flag: `-rpath` [-Wlinkflags]
    ```
    But no error.
    Obviously at this point `b test` will fail as the binaries should be executed in a WebAssembly VM.
    Info related to `SIDE_MODULE`, dynamic libraries and stand-alone mode: https://github.com/emscripten-core/emscripten/wiki/WebAssembly-Standalone
    From now on I will try to build the test with the library being static.

3. Logging the target info: `info: cxx.target = wasm32-emscripten, cxx.target.class = other, cxx.target.cpu = wasm32, cxx.target.system = emscripten`

4. Adding in `root.build`:
    ```
    if ($cxx.target.cpu == 'wasm32')
        bin.lib = static
    ```
    Then building I get these warnings:
    ```
    em++: warning: ../build-wasm/libhello/libhello/libhello.a: archive is missing an index; Use emar when creating libraries to ensure an index is created [-Wemcc]
    em++: warning: ../build-wasm/libhello/libhello/libhello.a: adding index [-Wemcc]
    ```

5. Trying a verbose build shows that the `ar`is the one fromt he system. The one in the sdk is named `emar`.
    Setting `config.bin.ar = emar` removes the warnings. (added to the configuration option file)

6. The compilers generates a .wasm and a .js from the executable output by default. `build2` passes the `-o` arguments assuming it's the same as with gcc/clang, but it's actually different for this compiler. The result is that the js files ends up having a non-extension name (on linux at least).

7. The javascript file generated should be executable using `node build-dir/.../tests/basic/driver` but currently it only triggers an exception with a number which I didn't find the signification yet. Here `node` is the `nodejs` installed through the emsdk (you can try `nodejs` instead if you want to use the system one).

