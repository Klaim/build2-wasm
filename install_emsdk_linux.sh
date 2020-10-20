
# See https://emscripten.org/docs/getting_started/downloads.html#platform-notes-installation-instructions-sdk


######################################################################
# Linux Requirements

# Install Python
sudo apt-get install python3

# Install CMake (optional, only needed for tests and building Binaryen)
sudo apt-get install cmake

# Install Java (optional, only needed for Closure Compiler minification)
sudo apt-get install default-jre

########################################################################
# Installing EMSDK

# Get the emsdk repo
git clone https://github.com/emscripten-core/emsdk.git

./update_emsdk_latest_stable.sh



