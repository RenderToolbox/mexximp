# mexximp

Matlab [mex-function](http://www.mathworks.com/help/matlab/apiref/mexfunction.html) wrapper for [Assimp](http://www.assimp.org/) tool.

mexximp is a Matlab interface to the [Assimp](http://www.assimp.org/) tool.  You can import 3D scene files using the Assimp importer, read and modify scene data, create scenes from scratch, and export scenes using the Assimp exporter.

Here's how it works.  Assimp wrangles 3D scene files to and from its own C-struct representation.  This is what makes Assimp awesome.  Then mexximp wrangles the C-structs to and from Matlab structs that you can work with.
```
3D scene file <-> Asssimp C-structs <-> mexximp Matlab structs
```

# Getting Started

Here's how to get started:
 - clone this repo and add it to your Matlab path
 - install Assimp (see below)
 - in Matlab, execute the script [makeMexximp](https://github.com/RenderToolbox3/mexximp/blob/master/makeMexximp.m)
 - try an example like [exportTestScene](https://github.com/RenderToolbox3/mexximp/blob/master/examples/scratch/exportTestScene.m)

# Installing Assimp

mexximp depends Assimp.  For full support of Collada scene files, you should install  Assimp 3.1.1 or later.

On Linux, your distribution's assimp package might be out of date.  So you should build Assimp from source.  Fortunately, this is pretty easy:
 - Get the source code as an [archive](http://www.assimp.org/main_downloads.html) or from [GitHub](https://github.com/assimp/assimp)
 - Unzip or clone the source
 - cd to the source folder
 - `cmake CMakeLists.txt -G 'Unix Makefiles'`
 - `make`

This is all it took for me (ben) on Linux Mint 17.3.  I hope your mileage does *not* vary.
 
On OS X, it should be as easy as:
 - get [Homebrew](http://brew.sh/)
 - `brew install assimp`
