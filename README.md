# mexximp

Matlab MEX-function wrapper for Assimp.

mexximp is a Matlab interface to the [Assimp](http://www.assimp.org/) tool.  You can import scenes using the Assimp importer, read and modify scene contents, create scenes from scratch, and export scenes using the Assimp exporter

The way it works is Assimp wrangles scenes to and from its own C-struct representation of scenes.  Then mexximp wrangles the C-structs to and from plain old Matlab structs that you can work with.
```
Scene file <-> Asssimp C-structs <-> mexximp Matlab structs
```

# Getting Started

Here's how to get started:
 - clone this repo and add it to your Matlab path
 - install Assimp (see below)
 - in Matlab, execute the script [makeMexximp](https://github.com/RenderToolbox3/mexximp/blob/master/makeMexximp.m)
 - try an example like [exportTestScene](https://github.com/RenderToolbox3/mexximp/blob/master/examples/scratch/exportTestScene.m)

# Installing Assimp

mexximp depends on Assimp being installed.  For full Collada support you should get Assimp 3.1.1 or later.

On Linux, your distribution's assimp package might be out of date.  So you should build from source.  Fortunately, this is pretty easy:
 - Get the source code as an [archive](http://www.assimp.org/main_downloads.html) or from [GitHub](https://github.com/assimp/assimp)
 - Unzip or clone the source
 - cd to the source folder
 - `cmake CMakeLists.txt -G 'Unix Makefiles'`
 - `make`

This is all it took for me (ben) on Linux Mint 17.3.  I hope your mileage does *not* vary.
 
On OS X, it should be as easy as:
 - get [Homebrew](http://brew.sh/)
 - `brew install assimp`
