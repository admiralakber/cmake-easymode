# Copyright (C) 2017-2018 Aqeel Akber <email@aqeel.cc>
# 
# This file is subject to the license terms in the LICENSE file
# found in the top-level directory of this distribution.

######## ########    #     # ####### ######  ####### 
##            ##     ##   ## #     # #     # #       
##           ##      # # # # #     # #     # #       
######      ##       #  #  # #     # #     # #####   
##         ##        #     # #     # #     # #       
##        ##         #     # #     # #     # #       
######## ########    #     # ####### ######  ####### 

# EASYMODE C++ BEST PRACTICE BOILERPLATE CMAKE PROJECT 
# Author: Aqeel Akber <email@aqeel.cc>
#
# This CMake Module provides a series of macros will make all your
# CMakeLists.txt files look almost identical and contain very little
# -- if you follow the EasyMode Project structure, the idea being the
# structure is best practice.  At this stage, the focus is on
# development for GNU/Linux operating systems. This is constantly
# evolving, your suggestions are absolutely most welcome.
#
# An EasyMode C++ Project is highly modular, contains documentation,
# unit tests, is git aware, include vendored/external libraries, and
# can provide extensions to Python or CERN ROOT. It can be installed,
# packaged, and easily integrated into other CMake projects.
#
# For an example project see [cmake-easymode-example github
# repository](https://github.com/admiralakber/cmake-easymode-example).
#
# FEATURE TOGGLES
#
#   BUILD_DOC    - Requires Doxygen
#   SWIG_PYTHON  - Requires SWIG and PythonLibs
#   CERN_ROOT    - Requires CERN ROOT
#
# The minimum complete example of an Easy Mode Project is as follows.
#
# project.cc
#  ├── cmake
#  │   ├── ezmode
#  │   │   ├── EasyMode.cmake
#  │   │   ├── EasyMode_thisproj-config.cmake.in
#  │   │   ├── cxxoptions.cmake
#  │   │   └── safegaurds.cmake
#  ├── docs 
#  │   ├── Doxyfile.in 
#  │   └── Doxymain.md
#  ├── extern
#  │   ├── Catch2                 [example / recommended]
#  │   │   └── ...
#  │   └── CMakeLists.txt         [add_library(extern_Folder INTERFACE)]
#  ├── src
#  │   ├── app1
#  │   │   ├── main.cc
#  │   │   └── CMakeLists.txt     [As below]
#  │   ├── lib1                   [ez_unit_init, ez_this_unit_add_*
#  │   │   ├── Abstraction.hh      ez_install_this_unit(bin/lib)]
#  │   │   ├── Implementation.cc    
#  │   │   └── CMakeLists.txt       
#  │   └── CMakeLists.txt         [add_subdirectory]
#  ├── CMakeLists.txt             [ez_proj_init, ez_export_project]
#  ├── LICENSE
#  └── README.md
#
# EasyMode is expected ot be installed in cmake/ezmode/
#
# The top level folder names are hard coded.
#
# As are the files docs/Doxyfile.in and docs/Doxymain.md, needed if
# BUILD_DOC is enabled.
#
# The workflow of using the macros included in this module is
# described in detail below.
#
# ======================================================================


## COLOURS MAKE CMAKE OUTPUT EASIER TO READ / GROUP WORKFLOW
# ------------------------------------------------------------------------
# Thanks Fraser!
# https://stackoverflow.com/questions/18968979/how-to-get-colorized-output-with-cmake
#
if(NOT WIN32)
  string(ASCII 27 Esc)
  set(ColourReset "${Esc}[m")
  set(ColourBold  "${Esc}[1m")
  set(Red         "${Esc}[31m")
  set(Green       "${Esc}[32m")
  set(Yellow      "${Esc}[33m")
  set(Blue        "${Esc}[34m")
  set(Magenta     "${Esc}[35m")
  set(Cyan        "${Esc}[36m")
  set(White       "${Esc}[37m")
  set(BoldRed     "${Esc}[1;31m")
  set(BoldGreen   "${Esc}[1;32m")
  set(BoldYellow  "${Esc}[1;33m")
  set(BoldBlue    "${Esc}[1;34m")
  set(BoldMagenta "${Esc}[1;35m")
  set(BoldCyan    "${Esc}[1;36m")
  set(BoldWhite   "${Esc}[1;37m")
else()
  message(FATAL_ERROR "[ EasyMode :: ERROR ] Currently only supports GNU/Linux")
endif()

## EASY MODE PROJECT INTIALIZATION.
# ------------------------------------------------------------------------
# ez_proj_init()
# This macro does the following:
#
# Defines the following variables
#
#   EZ_PROJ_VER
#   GIT_REVISION
#   EZ_INSTALL_BINDIR
#   EZ_INSTALL_LIBDIR
#   EZ_INSTALL_INCDIR
#   EZ_INSTALL_DATADIR
#   EZ_INSTALL_DOCDIR
#  {EZ_PROJ_VER}_INCLUDE_DIRS
#
# Defines the following global properties:
#
#   EZ_PROJ_LIBS - List of libraries that get EZ installed.
#   EZ_PROJ_APPS - List of applications that get  EZ installed.
#
# Runs find_package for the following (Optional) packages and creates
# a feature toggle where appropriate:
#
#   Git     - Variable [GIT_REVISION]
#   Doxygen - Option   [BUILD_DOC - Default ON]
#   SWIG    - Option   [SWIG_PYTHON - Default OFF]
#   ROOT    - Option   [CERN_ROOT - Default OFF]
#   BOOST   - Option   [BOOST_LIBS - Default OFF]
#
macro(ez_proj_init)
  # PREREQUISITES
  # ----------------------------------------
  # First check if PROJECT is defined.
  # EasyMode must initialized after project
  # is defined.
  # ----------------------------------------
  if (NOT DEFINED PROJECT_NAME)
    message(FATAL_ERROR "${BoldRed}[ EasyMode :: ERROR] ez_proj_init(): Set PROJECT_NAME ! See PROJECT()${ColourReset}")
  elseif (NOT DEFINED PROJECT_VERSION_MAJOR)
    message(FATAL_ERROR "${BoldRed}[ EasyMode :: ERROR] ez_proj_init(): Set PROJECT_VERSION_MAJOR ! See PROJECT()${ColourReset}")
  elseif (NOT DEFINED PROJECT_VERSION_MINOR)
    message(FATAL_ERROR "${BoldRed}[ EasyMode :: ERROR] ez_proj_init(): Set PROJECT_VERSION_MINOR ! See PROJECT()${ColourReset}")
  endif()

  # VARIABLES
  # ----------------------------------------
  # The first of a few variables
  # ----------------------------------------
  set(EZ_PROJ_VER ${PROJECT_NAME}-${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR})
  message("${BoldCyan}[ EasyMode :: ${EZ_PROJ_VER} ]${ColourReset}")

  define_property(GLOBAL PROPERTY EZ_PROJ_LIBS
    BRIEF_DOCS "List of libraries that are installed in ${PROJECT}"
    FULL_DOCS "List of libraries that are installed in ${PROJECT}"
    )

  define_property(GLOBAL PROPERTY EZ_PROJ_APPS
    BRIEF_DOCS "List of applications that are installed in ${PROJECT}"
    FULL_DOCS "List of applicatoins that are installed in ${PROJECT}"
    )

  # GIT
  # ----------------------------------------
  # Find git, get the revision number
  # From  https://github.com/bast/cmake-example
  # ----------------------------------------
  find_package(Git)
  if (GIT_FOUND)
    # Get the git revision
    execute_process(
      COMMAND ${GIT_EXECUTABLE} rev-list --max-count=1 HEAD
      OUTPUT_VARIABLE GIT_REVISION
      ERROR_QUIET
      )
    if (NOT ${GIT_REVISION} STREQUAL "")
      string(STRIP ${GIT_REVISION} GIT_REVISION)
    endif()
    message(STATUS "Current git revision is ${GIT_REVISION}")
  else()
    set(GIT_REVISION "unknown")
  endif()

  # VARIABLES cont.
  # ----------------------------------------
  # Install directories for this project.
  # At the moment, only for GNU/Linux
  #
  include(GNUInstallDirs)

  set(EZ_INSTALL_BINDIR ${CMAKE_INSTALL_BINDIR})
  set(EZ_INSTALL_LIBDIR ${CMAKE_INSTALL_LIBDIR}/${EZ_PROJ_VER})
  set(EZ_INSTALL_INCDIR ${CMAKE_INSTALL_INCLUDEDIR}/${EZ_PROJ_VER})
  set(EZ_INSTALL_DATADIR ${CMAKE_INSTALL_DATADIR}/${EZ_PROJ_VER})
  set(EZ_INSTALL_DOCDIR ${CMAKE_INSTALL_DOCDIR})

  message("${BoldMagenta}[ EasyMode :: Install Directories ]${ColourReset}")
  message(STATUS "   Prefix: ${CMAKE_INSTALL_PREFIX}")
  message(STATUS " Binaries: ${EZ_INSTALL_BINDIR}")
  message(STATUS "Libraries: ${EZ_INSTALL_LIBDIR}")
  message(STATUS "  Headers: ${EZ_INSTALL_INCDIR}")
  message(STATUS "     Data: ${EZ_INSTALL_DATADIR}")
  message(STATUS "     Docs: ${EZ_INSTALL_DOCDIR}")

  set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${EZ_INSTALL_LIBDIR}")
  set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

  #
  # Start setting the include directory
  # paths. We will keep adding to this until
  # the end of the macro.
  # ----------------------------------------
  set(${EZ_PROJ_VER}_INCLUDE_DIRS
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src>
    $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/src>
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/extern>
    $<INSTALL_INTERFACE:${EZ_INSTALL_INCDIR}>
    )

  # DOXYGEN DOCUMENTATION
  # ----------------------------------------
  # Automatic API documentation generation
  # based on Doxygen. Input and output
  # files and directories are hard coded
  # intentionally to sane defaults / best
  # practice.
  # ----------------------------------------
  option(BUILD_DOC "Build API documentation (requires Doxygen)" "OFF")

  if (BUILD_DOC)
    message("${BoldMagenta}[ EasyMode :: Doxygen ]${ColourReset}")
    find_package(Doxygen)
    if (NOT DOXYGEN_FOUND)
      message(FATAL_ERROR "${BoldRed}Doxygen is needed to build API documentation${ColourReset}")
    endif()
    set(doxy_main_page ${PROJECT_SOURCE_DIR}/docs/Doxymain.md)
    set(DOXYGEN_IN ${PROJECT_SOURCE_DIR}/docs/Doxyfile.in)
    set(DOXYGEN_OUT ${PROJECT_BINARY_DIR}/docs/Doxyfile)
    configure_file(${DOXYGEN_IN} ${DOXYGEN_OUT} @ONLY)
    message(STATUS "Doxygen configured at ${DOXYGEN_OUT}")
    add_custom_target(doc
      COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_OUT}
      WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
      COMMENT "Generating API documentation with Doxygen"
      VERBATIM)
    install(DIRECTORY ${PROJECT_BINARY_DIR}/docs/ DESTINATION ${EZ_INSTALL_DOCDIR} OPTIONAL)
  endif()

  # SWIG / Python
  # ----------------------------------------
  # Generate Python modules from C++
  # libraries. 
  # ----------------------------------------
  option(SWIG_PYTHON "Enable SWIG to build Python modules" "OFF")

  if (SWIG_PYTHON)
    message("${BoldMagenta}[ EasyMode :: SWIG -> Python ]${ColourReset}")
    find_package(SWIG)
    find_package(PythonLibs REQUIRED)
    if (NOT SWIG_FOUND)
      message(FATAL_ERROR "${BoldRed}SWIG and PythonLibs is needed to build python modules${ColourReset}")
    endif()
    include(${SWIG_USE_FILE})
    set(${EZ_PROJ_VER}_INCLUDE_DIRS ${${EZ_PROJ_VER}_INCLUDE_DIRS} $<BUILD_INTERFACE:${PYTHON_INCLUDE_PATH}>)
  endif()

  # CERN ROOT - Data analysis framework
  # ----------------------------------------
  # Include ROOT libraries and generate
  # ROOT dictionaries for use at the ROOT
  # interpreter.
  # ----------------------------------------
  option(CERN_ROOT "Enable using of CERN ROOT libraries and dictionary generation" "OFF")

  if (CERN_ROOT)
    message("${BoldMagenta}[ EasyMode :: CERN ROOT ]${ColourReset}")
    list(APPEND CMAKE_PREFIX_PATH $ENV{ROOTSYS})
    find_package(ROOT COMPONENTS RIO Net)
    if (NOT ROOT_FOUND)
      message(FATAL_ERROR "${BoldRed}Can not find CERN ROOT libraries. Check environment variable $ROOTSYS.${ColourReset}")
    endif()
    message(STATUS "Found ROOT: ${ROOT_INCLUDE_DIRS} (found version ${ROOT_VERSION})")
    include(${ROOT_USE_FILE})
    set(${EZ_PROJ_VER}_INCLUDE_DIRS ${${EZ_PROJ_VER}_INCLUDE_DIRS} $<BUILD_INTERFACE:${ROOT_INCLUDE_DIRS}>)
  endif()

  # BOOST LIBS - Peer Reviewed C++ Libraries
  # ----------------------------------------
  # Include ROOT libraries and generate
  # ROOT dictionaries for use at the ROOT
  # interpreter.
  # ----------------------------------------
  option(BOOST_LIBS "Enable using of Boost C++ Libraries" "OFF")

  if (BOOST_LIBS)
    message("${BoldMagenta}[ EasyMode :: Boost C++ Libraries ]${ColourReset}")
    set(Boost_USE_MULTITHREADED ON)
    find_package(Boost)
    if (NOT Boost_FOUND)
      message(FATAL_ERROR "${BoldRed}Can not find Boost libraries. Are they installed?${ColourReset}")
    endif()
    message(STATUS "Found Boost: ${Boost_INCLUDE_DIRS} (found version ${Boost_VERSION})")
    include(${Boost_USE_FILE})
    set(${EZ_PROJ_VER}_INCLUDE_DIRS ${${EZ_PROJ_VER}_INCLUDE_DIRS} $<BUILD_INTERFACE:${Boost_INCLUDE_DIRS}>)
  endif()
  
  # FINISHING UP
  # ----------------------------------------
  # Enabled all possible features, now
  # setting the include directories.
  # Looping so that it prints out pretty.
  # ----------------------------------------
  message("${BoldMagenta}[ EasyMode :: Include directories ]${ColourReset}")
  foreach(dir ${${EZ_PROJ_VER}_INCLUDE_DIRS})
    message(STATUS "${dir}")
    include_directories(${dir})
  endforeach()
  message("${BoldCyan}[ EasyMode :: ${EZ_PROJ_VER} ${BoldGreen}initialised${BoldCyan} ]${ColourReset}")
  
endmacro()


## EASY MODE UNIT INTIALIZATION.
# ------------------------------------------------------------------------
# ez_unit_init()
# This macro does the following:
#
# Defines the following variables
#
#   EZ_THIS_UNIT_NAME               - pulled from the folder name
#   EZ_THIS_UNIT_NAME_FULL          - {PROJECT_NAME}_{EZ_THIS_UNIT_NAME}
#   EZ_THIS_UNIT_HEADERS            - list
#   EZ_THIS_UNIT_SOURCES            - list
#  {EZ_THIS_UNIT_NAME_FULL}_HEADERS - list
#  {EZ_THIS_UNIT_NAME_FULL}_SOURCES - list
#
macro(ez_unit_init)
  # PREREQUISITES
  # ----------------------------------------
  # EasyMode project must be initialised
  # first to setup global variables, etc.
  # ----------------------------------------
  if (NOT DEFINED EZ_PROJ_VER)
    message(FATAL_ERROR "${BoldRed}[ EasyMode :: ERROR ] ez_unit_init(): Initialize project first \n${BoldBlue} Use ez_proj_init() at ${CMAKE_SOURCE_DIR}.${ColourReset}")
  endif()

  # VARIABLES
  # ----------------------------------------
  get_filename_component(EZ_THIS_UNIT_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
  set(EZ_THIS_UNIT_NAME_FULL ${PROJECT_NAME}_${EZ_THIS_UNIT_NAME})
  message("${Blue}[ EasyMode :: Unit ${EZ_THIS_UNIT_NAME_FULL} ]${ColourReset}")

  set(EZ_THIS_UNIT_HEADERS "")
  set(EZ_THIS_UNIT_SOURCES "")
  set(${EZ_THIS_UNIT_NAME_FULL}_HEADERS "")
  set(${EZ_THIS_UNIT_NAME_FULL}_SOURCES "")
  message(STATUS "Unit intialized at ${CMAKE_CURRENT_SOURCE_DIR}")
  
endmacro()

## EZ MODE UNIT ERROR MESSAGE
# ------------------------------------------------------------------------
# ez_error_unit_init()
# Spits back an error message.
# Used in the macros that are later defined.
#
macro(ez_error_unit_init)
  message(FATAL_ERROR "${BoldRed}[ EasyMode :: ERROR ] Initialize unit first\n${BoldBlue} Use ez_unit_init() at\n ${CMAKE_CURRENT_SOURCE_DIR}${ColourReset}")
endmacro()


## EZ MODE UNIT ADD HEADER
# ------------------------------------------------------------------------
# ez_unit_add_header(unitname filename)
# This macro does the following:
#
# Appends to variables
#  {filename} to {unitname}_HEADERS
#
# Also see:
#   ez_this_unit_add_header(filename)
#   ez_unit_add_source(unitname filename)
#
macro(ez_unit_add_header name filename)
  set(${name}_HEADERS ${name}_HEADERS ${filename})
endmacro()

## EZ MODE THIS UNIT ADD HEADER
# ------------------------------------------------------------------------
# ez_this_unit_add_header(filename)
# This macro calls: ez_unit_add_header assuming name is of this unit.
#
# Also see:
#   ez_this_unit_add_source(filelname)
#
macro(ez_this_unit_add_header filename)
  if (NOT DEFINED EZ_THIS_UNIT_NAME_FULL)
    ez_error_unit_init()
  endif()
  ez_unit_add_header(${EZ_THIS_UNIT_NAME_FULL} ${filename})
  set(EZ_THIS_UNIT_HEADERS ${EZ_THIS_UNIT_HEADERS} ${filename})
endmacro()

## EZ MODE UNIT ADD SOURCE
# ------------------------------------------------------------------------
# ez_unit_add_source(unitname filename)
# This macro does the following:
#
# Appends to variables
#  {filename} to {unitname}_SOURCES
#
# Also see:
#   ez_this_unit_add_source(filename)
#   ez_unit_add_header(unitname filename)
#
macro(ez_unit_add_source name filename)
    set(${name}_SOURCES ${name}_SOURCES ${filename})
endmacro()

## EZ MODE THIS UNIT ADD SOURCE
# ------------------------------------------------------------------------
# ez_this_unit_add_source(filename)
# This macro calls: ez_unit_add_source assuming name is of this unit.
#
# Also see:
#   ez_this_unit_add_header(filelname)
#
macro(ez_this_unit_add_source filename)
  if (NOT DEFINED EZ_THIS_UNIT_NAME_FULL)
    ez_error_unit_init()
  endif()
  ez_unit_add_source(${EZ_THIS_UNIT_NAME_FULL} ${filename})
  set(EZ_THIS_UNIT_SOURCES ${EZ_THIS_UNIT_SOURCES} ${filename})
endmacro()

## EZ MODE INSTALL UNIT
# ------------------------------------------------------------------------
# ez_install_unit(unitname as)
# This macro does the following:
#
# Appends to variables
#  {unitname} to EZ_PROJ_{upper(as)} - These get exported with project
#
# Installs unit as a component given by {as} into directories as
# defined during project initialization. It also exports the unit
# into the file {EZ_INSTALL_DATADIR}/cmake/{unitname}-config.cmake
# This way ussers should be able to use find_package(fullunitname)
# to import just a single library out of a project.
#
# Also see:
#   ez_install_this_unit(as)
#
macro(ez_install_unit name as)
  if (${as} STREQUAL "lib")
    set_property(GLOBAL APPEND PROPERTY EZ_PROJ_LIBS ${name})
    install(FILES ${EZ_THIS_UNIT_HEADERS} DESTINATION ${EZ_INSTALL_INCDIR}/${EZ_THIS_UNIT_NAME})
    message(STATUS "Library Unit ${name} - installed")
  elseif (${as} STREQUAL "bin")
    set_property(GLOBAL APPEND PROPERTY EZ_PROJ_APPS ${name})
    message(STATUS "Application Unit ${name} - installed")
  else()
    message(FATAL_ERROR "${BoldRed}[ EasyMode :: Unit ${name} ] Install type must be - lib, bin${ColourReset}")
  endif()
  
  install(TARGETS ${name}
    EXPORT ${name}-config
    RUNTIME DESTINATION ${EZ_INSTALL_BINDIR}
    LIBRARY DESTINATION ${EZ_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${EZ_INSTALL_INCDIR}/${EZ_THIS_UNIT_NAME}
    INCLUDES DESTINATION ${EZ_INSTALL_INCDIR}/${EZ_THIS_UNIT_NAME}
    COMPONENT ${as})
  
  install(EXPORT ${name}-config DESTINATION ${EZ_INSTALL_DATADIR}/cmake)
endmacro()


## EZ MODE INSTALL THIS UNIT
# ------------------------------------------------------------------------
# ez_install_unit(as)
# This macro calls: ez_install_unit assuming name is of this unit.
#
# Also see:
#   ez_install_unit(unitname as)
#
macro(ez_install_this_unit as)
  if (NOT DEFINED EZ_THIS_UNIT_NAME_FULL)
    ez_error_unit_init()
  endif()
  ez_install_unit(${EZ_THIS_UNIT_NAME_FULL} ${as})
endmacro()


## EZ MODE EXPORT PROJECT - SHOULD BE THE LAST THING DONE
# ------------------------------------------------------------------------
# ez_export_project()
# This macro does the following:
#
# Iterates over EZ_PROJ_LIBS and EZ_PROJ_APPS
# Populates it with the above units exported config files.
# ${EZ_PROJECT_BINARY_DIR}/cmake/${PROJECT_NAME}-config.cmake
# And installs the above total project config file.
#
# This enables the end user to use find_package({PROJECT_NAME})
# and it'll be equivalent to including every installed library
# individually.
#
# In most conceivable cases be the last function that CMake runs.
#
# Also see:
#   ez_install_this_unit(as)
#
macro(ez_export_project)
  message("${Cyan}[ EasyMode :: ${EZ_PROJ_VER} ${Green}exporting${Cyan} ]${ColourReset}")
  message(STATUS "Exporting units...")
  get_property(export_libs GLOBAL PROPERTY EZ_PROJ_LIBS)
  get_property(export_apps GLOBAL PROPERTY EZ_PROJ_APPS)
  get_filename_component(self_dir "${CMAKE_CURRENT_LIST_FILE}" PATH)
  set(EZ_PROJ_LIBS_EXPORT "# libraries")
  set(EZ_PROJ_APPS_EXPORT "# applications")

  # First generate the list of includes for libraries
  foreach(lib ${export_libs})
    set(EZ_PROJ_LIBS_EXPORT "${EZ_PROJ_LIBS_EXPORT}\ninclude(\${SELF_DIR}/${lib}-config.cmake")
    message(STATUS "Library Unit ${lib} - included")
  endforeach()
  # now the apps
  foreach(app ${export_apps})
    set(EZ_PROJ_APPS_EXPORT "${EZ_PROJ_APPS_EXPORT}\ninclude(\${SELF_DIR}/${app}-config.cmake")
    message(STATUS "Application Unit ${app} - included")
  endforeach()

  # Make the substitution in the project cmake file
  configure_file(${PROJECT_SOURCE_DIR}/cmake/ezmode/EasyMode_thisproj-config.cmake.in
    ${PROJECT_BINARY_DIR}/cmake/${PROJECT_NAME}-config.cmake @ONLY)

  # Install the file
  install(FILES ${PROJECT_BINARY_DIR}/cmake/${PROJECT_NAME}-config.cmake
    DESTINATION ${EZ_INSTALL_DATADIR}/cmake)

  message(STATUS "Done... users can now find_package(${PROJECT_NAME}) after install.")
  
  message("${BoldCyan}[ EasyMode :: ${EZ_PROJ_VER} ${BoldGreen}DONE!${BoldCyan} ]${ColourReset}")
  
endmacro()
