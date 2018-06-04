# IF we set this here, it is set when the module is loaded, and thus will point to the path of this module instead of
# trying to use CMAKE_CURRENT_LIST_DIR, which points to the directory in which this code is invoked!
# This is useful for resources, as in the case here.
set(MYMODULE_DIR "${CMAKE_CURRENT_LIST_DIR}")

function(shatup)
  # Calculate the SHA1 of CMakeLists.txt in the current source dir and save it to the current binary dir.
  message("About to create SHA1 of ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt")

  # NOTE: CMAKE_CURRENT_LIST_DIR is set to directory where function is used, and not defined, so if we used
  # it in a CMakeLists.txt file, ${CMAKE_CURRENT_LIST_DIR}/message.txt wouldn't exist.
  file(READ "${MYMODULE_DIR}/message.txt" msg)
  file(SHA1 "${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt" sha)
  file(
    WRITE
    "${CMAKE_CURRENT_BINARY_DIR}/sha1"
    "${msg}\nsha1(CMakeLists.txt) = ${sha}\n" # This is what is written to the file.
    )
  message("Wrote to ${CMAKE_CURRENT_BINARY_DIR}/sha1")
endfunction()
