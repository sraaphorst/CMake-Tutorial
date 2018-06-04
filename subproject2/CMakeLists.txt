message("Processing subproject2:")

# The location for this is included automatically from the list(APPEND CMAKE_MODULE_PATH ...) statement in the root node.
include(printdirs)

add_subdirectory(subproject2_1)
add_subdirectory(subproject2_2)

