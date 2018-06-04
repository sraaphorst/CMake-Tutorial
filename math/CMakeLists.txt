cmake_minimum_required(VERSION 3.0)
project(math LANGUAGES NONE)

# PROJECT_SOURCE_DIR will be set to math here.
message("From subdirectory math:")
message("  Source (general):       ${PROJECT_SOURCE_DIR}")
message("  Source (cmaketutorial): ${cmaketutorial_SOURCE_DIR}")
message("  Source (math):          ${math_SOURCE_DIR}")
message("  Variable from parent:   ${cmaketutorial_variable}\n")
