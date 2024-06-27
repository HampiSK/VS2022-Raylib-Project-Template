# Raylib Project Template (VS2022)

This simple project sets up a Visual Studio 2022 environment for game development with all necessary dependencies, including automatic download and linkage.

## Requirements
- [Visual Studio 2022](https://visualstudio.com) (Not strictly required, but the included setup scripts support only this version)

## Getting Started
1. Navigate to the `/Setup` directory and run the appropriate setup file for your operating system.
   - Note: The Linux setup has not been tested.
2. All dependencies will be automatically downloaded and configured.
3. A VS2022 solution will be created in the root directory.
4. Start developing and enjoy!

## Included
- Example Code:
  * `/Game/Source` - Directory contains an example game implementation.
  * `/Game/Test` - Directory includes example test implementations.
- `/Dependencies` directory for all game dependencies:
  * `./Build-Dependencies.lua` - Defines the setup order of dependencies.
  * `./Build-Googletest.lua` - Includes the testing dependency used for tests (`googletest v1.14.x`).
  * `./Build-Raylib.lua` - Includes the game engine (`Raylib v5.0`).
  * Additional dependencies can be added similarly.
- A simple `.gitignore` to exclude project files and binaries.
- Premake binaries for Windows and Linux (`Premake v5.0-beta2`).

## License
- The repository is licensed (see `LICENSE.txt` for details).
- Premake is licensed under the BSD 3-Clause (see included `LICENSE.txt` for more details).
