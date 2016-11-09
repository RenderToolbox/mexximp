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

mexximp depends on Assimp.  For full support of Collada scene files, you should install  Assimp 3.1.1 or later.

### OS X
It should be as easy as:
 - Get [Homebrew](http://brew.sh/).
 - `brew install assimp`

### Linux
Your distribution's assimp package might be out of date, so you should build Assimp from source.  Fortunately, this is pretty easy:
 - Get the source code as an [archive](http://www.assimp.org/main_downloads.html) or from [GitHub](https://github.com/assimp/assimp).
 - Unzip or clone the source.
 - `cd` to the source folder.
 - `cmake CMakeLists.txt -G 'Unix Makefiles'`
 - `make`

This is all it took for me (ben) on Linux Mint 17.3.  I hope your mileage does *not* vary.

### Note on Linux Library Version Hell
If you build Assimp with a recent version of gcc, this may conflict with system library versions that are bundled with Matlab and loaded when Matlab starts.  This would result in an error like this, when you try to use mexximp:
```
Invalid MEX-file '/home/username/GitRepos/mexximp/build/mexximpImport.mexa64': /share/software/MATLAB-R2015b/bin/glnxa64/../../sys/os/glnxa64/libstdc++.so.6: version 'GLIBCXX_3.4.19' not found (required by /usr/local/lib/libassimp.so.3)
```

This is a general issue when working with Matlab and mex-functions that load shared libraries.  We have an [issue](https://github.com/RenderToolbox/mexximp/issues/2) about it.

#### Work-around
One work-around is to set the `LD_PRELOAD` environment variable before starting Matlab.  This instructs the system to load your new version of the `libstdc++` system library, instead of loading the old version that's bundled with Matlab.

First you can locate your new version:
```
locate libstdc++.so.6
```
This may return several results.  Choose one from a system location like `/usr/lib`, for example, `/usr/lib/x86_64-linux-gnu/libstdc++.so.6`

Then from the terminal, you would launch matlab with the following command instead of just `matlab`:
```
LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6 matlab
```
This should work allow you to use Matlab normally, and also use mexximp.

Another option is to set `LD_PRELOAD` once and for all, from a startup script like `.bash_profile`.  You would add a line like this:
```
export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6
```
