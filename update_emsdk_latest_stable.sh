# See https://emscripten.org/docs/getting_started/downloads.html#sdk-download-and-install

# Enter the emsdk directory
cd emsdk

# Fetch the latest version of the emsdk (not needed the first time you clone)
git pull

# Download and install the latest SDK tools.
./emsdk install latest

# Make the "latest" SDK "active" for the current user. (writes .emscripten file)
./emsdk activate latest

# Display versions but also checks the context, output warnings if something might not work.
emcc --version
em++ --version
