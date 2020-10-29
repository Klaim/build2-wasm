
bdep deinit -a  # Make sure we don't have already initialized configs
bdep config remove -a # Dereference configurations
rm -rf build-* # Remove all configurations

# Then create and initialize each configuration:
bdep init -C build-wasm-release @wasm-release cc --options-file config-wasm-release-realproject.options
bdep init -C build-wasm-debug @wasm-debug cc --options-file config-wasm-debug-realproject.options
bdep init -C build-clang10-release @clang10-release cc --options-file config-clang10-release.options
bdep init -C build-clang10-debug @clang10-debug cc --options-file config-clang10-debug.options

