# build2-wasm-lib

Checked with `build2 v0.13.0`:

0. Install dependencies and Emscriptem SDK: run (maybe after reading) `./install_emsdk_linux.sh` to install the sdk in `./emsdk/`.
    Also `./update_emsdk_latest_stable.sh` can be run to update the sdk, it's run as part of the install.
1. Run the `source` command at the end of the install log, or `source ./emsdk/emsdk_env.sh` (on linux). This will setup the environment the sdk needs to function.
2. The options to use in the WASM configurations are in `config-wasm.options`, so you can do `bdep init -C build-wasm cc --options-file ./config-wasm.options`.
3. Building should work, testing is done through `node path/to/output/testfile` (which is a javascript file with a .wasm file next to that file).
    Here `node` is a `nodejs` provided by the sdk.
    Currently, running `b test` or `bdep test` will run a testscript which runs `node`.

BEWARE: on first init, you might find this issue:
    ```
    ╰─$ bdep init -C ./build-wasm cc --options-file ./config-wasm.options
    initializing in project /home/klaim/work/build2-experiments/build2-wasm/
    error: unable to parse C compiler target 'shared:INFO: (Emscripten: Running sanity checks)': missing cpu
    info: consider using the --config-sub option
    ```
    I didn't find yet why this happen, but deleting the configuration dir and the `.bdep` and re-trying this command will not cause any issue from that point.

BEWARE: when building from the root directory (package repository) I do not see the wasm file being generated, nor do I see some of the `info` logs I added in the project. Not sure why yet. Invoking `b` from the project directory seems to work as expected.

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

8. `b clean` doesnt clean the .wasm file.

9. I managed to make the test work by removing it's code and simply outputing `"Hello!"`, then I setup testscripts so that it works when we run `b test` or `bdep test`.
    I set it up so that if we add  non-wasm configuration, we can run the tests for both.

10. The error I was seeing before when running the test was because exceptions are not even handled at all by default. I assumed they were not-caught, but it's not even the case.
    Now I setup the test so it does what it was doing before and exceptions are handled.



TODO
----

- Run `source emdsk/emsdk_env.sh` automatically in the WebAssembly configuration.
    - Might require that build2 provides a way to run a `source` command and keep the environnement.
- Make a "standalone" wasm module/library (no entry point).
- Check that api binding to JS works as expected.
- Find a way to use the `-o` flag from emcc.
    - Output html file? Try with https://build2.org/release/0.13.0.xhtml#adhoc-recipe ?
- Repro-case of the build command not doing the build the same way when from the root/glue buildfile vs from the project's buildfile.

- From Boris (build2):
    > One thing that would be helpful is to produce two listings: The first is the compilation/linking commands as printed with b -vs when building your project. The second is a list of what you think they should be (i.e., how would you perform the same script manually using the canonical/recommended options, etc).

