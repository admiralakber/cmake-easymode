Copyright (C) 2017-2018 Aqeel Akber <email@aqeel.cc>
```
######## ########    #     # ####### ######  ####### 
##            ##     ##   ## #     # #     # #       
##           ##      # # # # #     # #     # #       
######      ##       #  #  # #     # #     # #####   
##         ##        #     # #     # #     # #       
##        ##         #     # #     # #     # #       
######## ########    #     # ####### ######  ####### 
```
**If the best practice isn't the easiest, it's a bug.**

## EASYMODE C++ BEST PRACTICE BOILERPLATE CMAKE PROJECT 
#### Author: Aqeel Akber <email@aqeel.cc>

This CMake Module provides a series of macros will make all your
CMakeLists.txt files look almost identical and contain very little --
if you follow the EasyMode Project structure, the idea being the
structure is best practice. At this stage, the focus is on development
for GNU/Linux operating systems.

This is constantly evolving, your suggestions are absolutely most
welcome. Help make the best practice be the easiest practice.

An EasyMode C++ Project is highly modular, contains documentation,
unit tests, is git aware, include vendored/external libraries, and can
provide extensions to Python or CERN ROOT. It can be installed,
packaged, and easily integrated into other CMake projects.

**For a minimal example project see [cmake-easymode-example github
repository](https://github.com/admiralakber/cmake-easymode-example).**

FEATURE TOGGLES
```
  BUILD_DOC    - Requires Doxygen (Default ON)
  SWIG_PYTHON  - Requires SWIG and PythonLibs (Default OFF)
  CERN_ROOT    - Requires CERN ROOT (Default OFF)
```
The minimum complete example of an Easy Mode Project is as follows.

```
project.cc
 ├── cmake
 │   ├── ezmode
 │   │   ├── EasyMode.cmake
 │   │   ├── EasyMode_thisproj-config.cmake.in
 │   │   ├── cxxoptions.cmake
 │   │   └── safegaurds.cmake
 ├── docs 
 │   ├── Doxyfile.in 
 │   └── Doxymain.md
 ├── extern
 │   ├── Catch2                 [example / recommended]
 │   │   └── ...
 │   └── CMakeLists.txt         [add_library(extern_Folder INTERFACE)]
 ├── src
 │   ├── app1
 │   │   ├── main.cc
 │   │   └── CMakeLists.txt     [As below]
 │   ├── lib1                   [ez_unit_init, ez_this_unit_add_*
 │   │   ├── Abstraction.hh      ez_install_this_unit(bin/lib)]
 │   │   ├── Implementation.cc    
 │   │   └── CMakeLists.txt       
 │   └── CMakeLists.txt         [add_subdirectory]
 ├── CMakeLists.txt             [ez_proj_init, ez_export_project]
 ├── LICENSE
 └── README.md
```

EasyMode is expected ot be installed in cmake/ezmode/

The top level folder names are hard coded.

As are the files docs/Doxyfile.in and docs/Doxymain.md, needed if
BUILD_DOC is enabled.

The workflow of using the macros included in this module is
described in detail below.

## Macros / Workflow
### EASY MODE PROJECT INTIALIZATION.
```ez_proj_init()```
This macro does the following:

Defines the following variables
```
  EZ_PROJ_VER
  GIT_REVISION
  EZ_INSTALL_BINDIR
  EZ_INSTALL_LIBDIR
  EZ_INSTALL_INCDIR
  EZ_INSTALL_DATADIR
  EZ_INSTALL_DOCDIR
 {EZ_PROJ_VER}_INCLUDE_DIRS
```
Defines the following global properties:
```
  EZ_PROJ_LIBS - List of libraries that get EZ installed.
  EZ_PROJ_APPS - List of applications that get  EZ installed.
```
Runs find_package for the following (Optional) packages and creates
a feature toggle where appropriate:
```
  Git     - Variable [GIT_REVISION]
  Doxygen - Option   [BUILD_DOC - Default ON]
  SWIG    - Option   [SWIG_PYTHON - Default OFF]
  ROOT    - Option   [CERN_ROOT - Default OFF]
```
### EASY MODE UNIT INTIALIZATION.
```ez_unit_init()```
This macro does the following:

Defines the following variables
```
  EZ_THIS_UNIT_NAME               - pulled from the folder name
  EZ_THIS_UNIT_NAME_FULL          - {PROJECT_NAME}_{EZ_THIS_UNIT_NAME}
  EZ_THIS_UNIT_HEADERS            - list
  EZ_THIS_UNIT_SOURCES            - list
 {EZ_THIS_UNIT_NAME_FULL}_HEADERS - list
 {EZ_THIS_UNIT_NAME_FULL}_SOURCES - list
```
### EZ MODE UNIT ADD HEADER(SOURCE)
```ez_unit_add_header(unitname filename)```
This macro does the following:

Appends to variables
 ```{filename} to {unitname}_HEADERS```

Also see:
  ```ez_this_unit_add_header(filename)```
  ```ez_unit_add_source(unitname filename)```

### EZ MODE THIS UNIT ADD HEADER(SOURCE)
```ez_this_unit_add_header(filename)```
This macro calls: ez_unit_add_header assuming name is of this unit.

Also see:
  ez_this_unit_add_source(filelname)

### EZ MODE INSTALL UNIT
```ez_install_unit(unitname as)```
This macro does the following:

Appends to variables
 ```{unitname} to EZ_PROJ_{upper(as)} - These get exported with project```

Installs unit as a component given by {as} into directories as
defined during project initialization. It also exports the unit
into the file ```{EZ_INSTALL_DATADIR}/cmake/{unitname}-config.cmake```
This way ussers should be able to use ```find_package(fullunitname)```
to import just a single library out of a project.

Also see:
  ```ez_install_this_unit(as)```

### EZ MODE EXPORT PROJECT - SHOULD BE THE LAST THING DONE
```ez_export_project()```
This macro does the following:

Iterates over ```EZ_PROJ_LIBS``` and ```EZ_PROJ_APPS```
Populates it with the above units exported config files.
```${EZ_PROJECT_BINARY_DIR}/cmake/${PROJECT_NAME}-config.cmake```
And installs the above total project config file.

This enables the end user to use ```find_package({PROJECT_NAME})```
and it'll be equivalent to including every installed library
individually.

In most conceivable cases be the last function that CMake runs.

Also see:
  ```ez_install_this_unit(as)```
