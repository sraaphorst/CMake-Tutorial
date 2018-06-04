# Tutorial from: https://cgold.readthedocs.io/en/latest/overview.html
cmake_minimum_required(VERSION 3.0)

# You should avoid doing anything before the project directive, since these variables might not be set
# and many things are configured by project.
message("Before 'project' directive:")
message("  C:   '${CMAKE_C_COMPILER}'")
message("  C++: '${CMAKE_CXX_COMPILER}'")
message("  Source: ${PROJECT_SOURCE_DIR}")
message("  Binary: ${PROJECT_BINARY_DIR}")
message("  Version: ${PROJECT_VERSION}")
message("  Version (alt): ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}\n")

# If needed, you can set a toolchain file here, or via -DCMAKE_TOOLCHAIN_FILE=<relative path> when doing cmake -H
# set (CMAKE_TOOLCHAIN_FILE <relative-path>)

# project declares a non-divisible monolithic hierarchy of targets and must be in the top-level CMakeLists.txt.
# Sets languages to C / C++ default. Specify language after if desired, e.g. C just to build C files, or NONE if no language is needed.
# CXX is used for C++.
# LANGUAGES and VERSION keywords introduced in 3.0:
project(cmaketutorial
  VERSION 1.2.3
  LANGUAGES C CXX)

message("After 'project' directive:")
message("  C:   '${CMAKE_C_COMPILER}'")
message("  C++: '${CMAKE_CXX_COMPILER}'")
message("  Source: ${PROJECT_SOURCE_DIR}")
message("  Binary: ${PROJECT_BINARY_DIR}")
message("  Version: ${PROJECT_VERSION}")
message("  Version (alt): ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}\n")

# CMAKE_MODULE_PATH starts empty, but should be set to ;-list directories of where your personal .cmake files are located.
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake-modules")

# Example of an if statement checking version: is version >= 3.0?
message("Using CMake version ${CMAKE_VERSION}")
if (NOT CMAKE_VERSION VERSION_LESS 3.0)
  message("Processing CMakeLists.txt, version >= 3.0\n")
else()
  message("Processing CMakeLists.txt, verson < 3.0\n")
endif()

### Variables for different paths: ###
message("From top level:")
message("  Source (general)  : ${PROJECT_SOURCE_DIR}")
message("  Source (cmaketutorial): ${cmaketutorial_SOURCE_DIR}\n")

# Add another directory to the project. Has its own variable scope, but will be initialized with variables of parent scope.
set(cmaketutorial_variable "I was defined in cmaketutorial's CMakeLists.txt file.")
add_subdirectory(math)

# Version information. We don't need this if we specify VERSION in the project directive.
#set (CMAKETUTORIAL_VERSION_MAJOR 1)
#set (CMAKETUTORIAL_VERSION_MINOR 2)
#set (CMAKETUTORIAL_VERSION_PATCH 3)

# Fill in the template configuration file.
# If we do a "cmake --build _builds/Debug", fooconfig.h.in will be made into fooconfig.h and placed in _builds/Debug.
configure_file (
  ${PROJECT_SOURCE_DIR}/CmaketutorialConfig.h.in
  ${PROJECT_BINARY_DIR}/CmaketutorialConfig.h
  )

# This is necessary to make fooconfig.h visible to foo.cpp
include_directories("${PROJECT_BINARY_DIR}")

add_executable(cmaketutorial cmaketutorial.cpp)

# cmake 2.8 allows (oddly) libraries to be linked against themselves.
# If the minimum version of cmake required is 2.8, cmake 3.0 would generate a warning.
# If the minimum version of cmake required is 3.0, cmake would generate a terminal error.
# To suppress errors / warnings about things like this (say in 3.0), we can do so with cmake_policy.
# We should guard cmake_policy since nonexistent policy numbers (e.g. in cmake 2.8, this wouldn't exist)
# will generate an error.
#if (POLICY CMP0038)
#  cmake_policy(SET CMP0038 OLD)
#endif()

# This is erroneous, but would have been accepted in cmake 2.8.
# In cmake 3.0 and higher, it will generate an error unless the cmake_policy above is set.
# add_library(cmaketutorial cmaketutorial.cpp)
# target_link_libraries(cmaketutorial cmaketutorial)

### VARIABLES ###
# Variables are linked to the scope in which they are defined. Changes in other scopes will not propagate.
# You can cache variable values. They are stored in _builds/CMakeCache.txt.
# Variables that don't exist in this scope dereference to the empty string.
message("Regular variable (before):  ${regular_var}")
message("Cache   variable (before):  ${cache_var}")
set(regular_var "I am a regular variable!")
# cache_var will prefer its cache value to anything here unless you use CACHE FORCE.
set(cache_var   "I am a cache variable!" CACHE STRING "docstring goes here")
message("Regular variable (after):   ${regular_var}")
message("Cache   variable (after):   ${cache_var}")

# Variables can be unset. If they are unset / cannot be found, cmake will check the cache.
unset(cache_var)
message("Cache variable after unset: ${cache_var}\n")

function(foo)
  message("[foo] In foo. Variables carry but cannot be changed: ${regular_var}")
  set(regular_var "This doesn't reflect on my parent.")
  message("[foo] Changed to:                                    ${regular_var}")
endfunction()

foo()
message("Out of foo. Variable is now restored:                ${regular_var}")

# Note that the include and macro directives don't introduce a new scope, so set / unset will affect current scope.
macro(modify_regular_var)
  set(regular_var "I can change!!!")
endmacro()

message("Calling macro modify_regular_var...")
modify_regular_var()
message("Out of modify_regular_var. Variable is NOT restored: ${regular_var}")

message("Including file modify-regular_var.cmake...")
# This is included in cmake-modules, but should be found automatically by setting up CMAKE_MODULE_PATH.
include(modify-regular_var)
message("After include, variable is NOT restored:             ${regular_var}\n")

# You can set variables IN the parent scope by specifying PARENT_SCOPE.
# This does not change them in the current scope!
# This will ONLY change them in the direct parent scope, so beware nested functions.
unset(abc)
function(scope2)
  message("[scope2] before:  '${abc}'")
  set(abc "set by scope2" PARENT_SCOPE)
  message("[scope2] after:   '${abc}'")
endfunction()
function (scope1)
  message("[scope1] before:  '${abc}'")
  scope2()
  message("[scope1] after:   '${abc}'")  
endfunction()
scope1()
message("Grandpappy scope: '${abc}'\n")

# Variables can consist of any characters:
set("\"?ab_c+*#" "WOW")
function(print_name varname)
  message("[print_name] Variable name: '${varname}' has value '${${varname}}'\n")
endfunction()
print_name("\"?ab_c+*#")

# Quoted vs. unquoted arguments
set(quoted   "quoted argument")
set(unquoted un"quoted argument")
#set(loopy  x"arg1;arg2;arg3")
set(loopy    arg1;arg2;arg3)

message("quoted   = '${quoted}'")
message("unquoted = '${unquoted}'")
message("forloop  = ")
foreach(x ${loopy})
  message("   '${x}'")
endforeach()
message("")

# You can dereference variables to make new variable names or refer to old ones.
set(prefix var)
set(${prefix}_1 "I am var_1.")
set(${prefix}_2 "But I am the far more gentlemanly var_2!")
set(ctr 1;2)
foreach (x ${ctr})
  message("var_${x} has value ${var_${x}}")
endforeach()
message("")

# Example of usefulness:
foreach(lang C CXX)
  message("Compiler for language ${lang}: ${CMAKE_${lang}_COMPILER}")
  foreach(build_type DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)
    message("\tFlags for language ${lang} + build type ${build_type}: ${CMAKE_${lang}_FLAGS_${build_type}}")
  endforeach()
endforeach()
message("")

# Interpreting as boolean, as well as some commands:
set(condition_a "TRUE") # will be interpreted as true
set(condition_b "NO")   # will be interpreted as false
function(test_condition condition_varname)
  if (${condition_varname})
    message("${condition_varname} with value ${${condition_varname}} evaluates to true")
  else()
    message("${condition_varname} with value ${${condition_varname}} evaluates to false")
  endif()
endfunction()
foreach (x a b)
  test_condition(condition_${x})
endforeach()

set(path_to_this "${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt")
function(checkpath path)
  if (EXISTS "${path}")
    message("Path ${path} exists.")
  else()
    message("Path ${path} does not exist.")
  endif()
endfunction()
checkpath("${path_to_this}")

set(target_name cmaketutorial)
function(checktarget name)
  if (TARGET "${name}")
    message("Target ${name} exists.")
  else()
    message("Target ${name} does not exist.")
  endif()
endfunction()
checktarget("${target_name}")
message("")

### LISTS ###
message("Message can " "take lots " "of distinct " "strings")

# list command can be used to calculate length of lists, get elements by index, remove elements by index, etc.
set(list0 a b c d e f g)
list(LENGTH list0 list0_len)
message("list0 = ${list0} has length ${list0_len}")
list(REMOVE_AT list0 1)
message("list0 is now:")
list(LENGTH list0 list0_len)
# Annoying, but we have to do itas RANGE is inclusive.
math(EXPR max_range "${list0_len} - 1")
foreach(idx RANGE ${max_range})
  list(GET list0 ${idx} x)
  message("\tlist0[${idx}] = ${x}")
endforeach()
message("")

# There is no such thing as a list with one element.
# "" is an empty list, and ";" is a list with two empty elements.
function(add_element list_name element_name)
  message("Add '${${element_name}}' to list '${${list_name}}'")
  list(APPEND "${list_name}" "${${element_name}}")
  list(LENGTH "${list_name}" list_len)
  message("Result: '${${list_name}}' (length = ${list_len})")
  set(${list_name} "${${list_name}}" PARENT_SCOPE)
endfunction()

message("Adding a non-empty element to a non-empty list.")
set(mylist "a;b")
set(element "c")
# REMEMBER THAT THIS ITERATES 4 TIMES (0, 1, 2, 3).
foreach(i RANGE 3)
  add_element(mylist element)
endforeach()
message("")

message("Adding empty element to non-empty list.")
set(mylist a b)
set(element "")
foreach(i RANGE 3)
  add_element(mylist element)
endforeach()
message("")

message("Adding empty element to empty list.")
set(mylist "")
set(element "")
foreach(i RANGE 3)
  add_element(mylist element)
endforeach()
message("")


### CACHE VARIABLES ###
# Unlike regular variables, they have no scope and are set globally.
# It is recommended to make them begin with the PROJECTNAME in caps since global.
# They cannot be reset: the cached value will be used, if it exists.
# Variables set with -D are cached variables and take priority over set() command.
# Furthermore, -D ONLY works with cached variables and not regular variables.
# For lots of variables, initial cache can be set with -C cmakefilename.cmake instead of -D... -D... -D...
# Use FORCE to override cache variables:
set(FORCED_VAR "123" CACHE STRING "" FORCE)

# Although all variables are strings, you can add some hints for cmake as to how they should be treated.
set(CACHED_BOOL     "YES"                 CACHE BOOL     "Variable CACHED_BOOL")
set(CACHED_FILEPATH "math/CMakeLists.txt" CACHE FILEPATH "Variable CACHED_FILEPATH")
set(CACHED_PATH     "math/"               CACHE PATH     "Variable CACHED_PATH")
set(CACHED_STRING   "a string!"           CACHE STRING   "Variable CACHED_STRING")

# We can set property choices for CMake-GUI, like an enumeration:
# We can also hide variables for "advanced use" by using mark_as_advanced, which requires the advanced checkbox to be checked.
set(CRYPTO_TYPE "OpenSSL" CACHE STRING "Backend for cryptography")
set_property(CACHE CRYPTO_TYPE PROPERTY STRINGS "OpenSSL;Libgcrypt;WinCNG")
mark_as_advanced(CRYPTO_TYPE)

# Variables marked as INTERNAL will not be displayed in CMake-GUI, and imply FORCE:
set(FOR_INTERNAL_USE_ONLY "fixed stuff" CACHE INTERNAL "")

# option can be used to create a boolean cache entry
option(USER_OPTION_A "Option A" OFF)
option(USER_OPTION_B "Option B" YES) # is stored as ON in cache

# You can unset variables in the cache using unset(var CACHE)
set(CACHED_CRAP "crap..." CACHE STRING "")
unset(CACHED_CRAP CACHE)


### ENVIRONMENT VARIABLES ###
# WARNING: cmake doesn't track changes to environment variables, so if you change one used by cmake, it will not reconfigure unless
# you force it to, either by reconfiguring with cmake -H. -B_builds or by touch CMakeLists.txt

# Read using $ENV{n}, set using set(ENV{n} v), unset using unset(ENV{n}).
message("Environment variable USER: $ENV{USER}")
set(ENV{USER} jdoe)
message("Environment variable USER: $ENV{USER}")
unset(ENV{USER})
message("Environment variable USER: $ENV{USER}")

# Child processes inhert environment variables of parents
set(ENV{ABC} "This is ABC")
message("Top level ABC: $ENV{ABC}")

set(level1 "${CMAKE_CURRENT_LIST_DIR}/level1/level1.cmake")
execute_process(
  COMMAND "${CMAKE_COMMAND}" -P "${level1}" RESULT_VARIABLE result
  )
if (NOT result EQUAL 0)
  message("An error occurred...")
endif()
message("")


### CMAKE LISTFILES: SUBDIRECTORIES, ETC. ####
# CMAKE_CURRENT_SOURCE_DIR is always path to currently processed node
# CMAKE_SOURCE_DIR is always root of tree
# CMAKE_BINARY_DIR is always path to binary dir for root of tree
# CMAKE_CURRENT_BINARY_DIR is always path to binary dir for currently processed node
# They mirror each other's structure, one in the source, and one in the build.
message("Processing root:")
include(printdirs)
add_subdirectory(subproject1)
add_subdirectory(subproject2)
message("")

### INCLUDE MODULES ###
# See note about CMAKE_MODULE_PATH and CMAKE_CURRENT_LIST_DIR at top of file!!!
# Should always prefix your own modules with project name to avoid name-clashing.

# Standard modules here: https://cmake.org/cmake/help/latest/manual/cmake-modules.7.html
# USEFUL FOR ME: FindQt4, DeployQt4, FIND_PACKAGE(Qt5Widgets)
# FIND_PACKAGE(Qt5Widgets), which requires access to Qt5WidgetsConfig.cmake or qt5widgets-config/cmake
#   Can solve by setting Qt5Widgets installation prefix to CMAKE_PREFIX_PATH, or
#   providing Qt5Widgets_DIR to directory containing one of those files.
# See this page: https://github.com/Cockatrice/Cockatrice/issues/205
# May be able to deploy with https://github.com/OpenChemistry/avogadroapp/blob/master/cmake/DeployQt5.cmake
message("Loading Qt5 widgets...")
#set(Qt5Widgets_DIR /Applications/Qt/5.10.1/clang_64/lib/cmake/Qt5Widgets)
set(QT5_DIR /Applications/Qt/5.10.1/clang_64/lib/cmake/Qt5Widgets)
list(APPEND CMAKE_PREFIX_PATH "${QT5_DIR}")
FIND_PACKAGE(Qt5Widgets)
message("Done!\n")

include(ProcessorCount)
ProcessorCount(N)
message("Number of processors: ${N}\n")

# CMAKE_CURRENT_LIST_* variables
include(show-cmake-current-lists)

# Make a SHA1 of this CMakeLists.txt file and store in binary.
# Look at this file in cmake-modules to see file usage and how to properly create a module with resources.
include(sha-er)
shatup()
message("")

### CONTROL STRUCTURES ###
set (A "")

# Use STREQUAL to compare strings.
# Note: if cmake policy CMP0054 is set to OLD or not present (i.e pre-cmake 3.1), STREQUAL ignores quotes.
# For cmake < 3.1 you can use:
string(COMPARE EQUAL "${A}" "" is_empty)
if (is_empty)
  message("string compare equal says it's empty.")
endif()

if (A STREQUAL "")
  message("Value of A is the empty string.")
else()
  message("Value of A is not the empty string.")
endif()

set (B "A")
if (${B} STREQUAL "")
  message("Value of ${B} is the empty string.")
else()
  message("Value of ${B} is not the empty string.")
endif()

set (A "x")
set ("xB" "hello")
if ("${${A}B}" STREQUAL "hello")
  message("${${A}B} says hello!")
endif()

# foreach will not process empty lists, but it will process a list with an empty element:
message("[foreach]: empty list")
foreach (x)
  messave("\tx=${x}")
endforeach()

message("[foreach]: dereferenced empty list")
set(empty_list)
foreach(x ${empty_list})
  message("\tx=${x}")
endforeach()

# This counts as a list with empty element and thus runs.
message("[foreach]: dereferenced empty quoted list")
foreach(x "${empty_list}")
  message("\tx=${x}")
endforeach()

# This runs.
message("[foreach]: list with empty element")
foreach(x "")
  message("\tx=${x}")
endforeach()
message("")

# You can also do foreach RANGE with limits:
set(mystr "")
foreach(x RANGE 2 8 2)
  set(mystr "${mystr} ${x}")
endforeach()
message("[foreach RANGE 2 8 2] generated: ${mystr}.")

# There is also a while command.
message("[while] loop with condition as variable:")
set(a "")
set(condition TRUE)
while (condition)
  set(a "${a}x")
  message("\ta=${a}")
  string(COMPARE NOTEQUAL "${a}" "xxxxx" condition)
endwhile()

message("[while] loop with explicit condition:")
set(a "")
while(NOT a STREQUAL "xxxxx")
  set(a "${a}x")
  message("\ta=${a}")
endwhile()

# cmake also has a loop "break" statement, as expected.
message("[break] infinite while loop with break statement after 3x:")
set(a "")
while(YES)
  set(a "${a}x")
  message("\ta=${a}")
  if (a STREQUAL "xxx")
    break()
  endif()
endwhile()

# We also have continue.
message("[continue] foreach RANGE 1 6 loop skipping 2 and 5.")
foreach(x RANGE 1 6)
  if (x EQUAL 2 OR x EQUAL 5)
    continue()
  endif()
  message("\tx=${x}")
endforeach()

# Calling a function with an unexpected number of arguments
message("[function] with unexpected number of arguments")
function(func1 a b c)
  message("\tfunc1 called with ${ARGC} arguments.")
  message("\tall=${ARGV}")
  message("\tunexpected=${ARGN}")
endfunction()

# This would fail. You must provide at least the required number of arguments.
# func1(1 2)
func1(1 2 3 4 5)

### PARSING ARGUMENTS ###
# We can parse command-line arguments using cmake_parse_arguments
#include(CMakeParseArguments)
#function(accept-args)
#  set(optional FOO BOO)
#  set(one X Y Z)
#  set(multiple L1 L2)

  # This populates a number of elements of the form x_
#  cmake_parse_arguments(x "${optional}" "${one}" "${multiple}" "${ARGV}")

  # cmake_parse_arguments constructs x_UNPARSED_ARGUMENTS.
#  string(COMPARE NOTEQUAL "${x_UNPARSED_ARGUMENTS}" "" has_unparsed)
#  if (has_unparsed)
#    message(FATAL_ERROR "[accept-args] unpased arguments: ${x_UNPARSED_ARGUMENTS}")
#  endif()

#  message("[accept-args] FOO=${x_FOO}, BOO=${x_BOO}")
#  message("[accept-args] X=${x_X}, Y=${x_Y}, Z=${x_Z}")
#  set(l1 "")
#  foreach(item ${x_L1})
#    set(l1 "${l1} '${item}'")
#  endforeach()
#  message("[accept-args] x_L1: 
  
message("Processing CMakeLists.txt done.")
