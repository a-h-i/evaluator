cmake_minimum_required(VERSION 3.10)
# Define version and project

project(evworker VERSION 1.0 LANGUAGES CXX
DESCRIPTION  "Evaluator Worker for evaluating submission."
)
add_compile_definitions(VERSION_MAJOR=${PROJECT_VERSION_MAJOR})
include(GNUInstallDirs)
# Target names
set(WORKER_NAME "evworker")
set(TEST_EXEC_NAME "evworker_specs")
set(DAEMON_NAME "evworkerd")




# Custom configurations
if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang" OR "${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU" )
    add_definitions(
        -Wall
        -Wextra
        -pedantic
        -Werror
        )
    # Yes discard default values
    set(CMAKE_CXX_FLAGS_RELEASE "-fvisibility=hidden -fvisibility-inlines-hidden -flto=jobserver -O3 -march=native -fmerge-all-constants -fgcse-sm -fgcse-las -fPIC -faggressive-loop-optimizations -fdelete-null-pointer-checks -fira-hoist-pressure -fira-loop-pressure -fsched-pressure -funsafe-math-optimizations")
    set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-flto=jobserver -s -funsafe-math-optimizations" )
    set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "-flto=jobserver -shared -fPIC -funsafe-math-optimizations -fvisibility=hidden -fvisibility-inlines-hidden")
elseif ( "${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC" )
    add_definitions(
        /Wall
        /WX        
        )
    set(CMAKE_CXX_FLAGS_RELEASE "/Ox /Oi /arch:SSE2")
endif()
# Profile target

SET( CMAKE_CXX_FLAGS_PROFILE "-pg" CACHE STRING
    "Flags used by the C++ compiler during maintainer builds."
    FORCE )
SET( CMAKE_C_FLAGS_PROFILE "-pg" CACHE STRING
    "Flags used by the C compiler during maintainer builds."
    FORCE )
SET( CMAKE_EXE_LINKER_FLAGS_PROFILE
    "-pg" CACHE STRING
    "Flags used for linking binaries during maintainer builds."
    FORCE )
SET( CMAKE_SHARED_LINKER_FLAGS_PROFILE
    "-pg" CACHE STRING
    "Flags used by the shared libraries linker during maintainer builds."
    FORCE )
# Disables debug assertion is stdlib
if("${CMAKE_BUILD_TYPE}" STREQUAL "Release")
    add_definitions(-DNDEBUG)
endif()
MARK_AS_ADVANCED(
    CMAKE_CXX_FLAGS_PROFILE
    CMAKE_C_FLAGS_PROFILE
    CMAKE_EXE_LINKER_FLAGS_PROFILE
    CMAKE_SHARED_LINKER_FLAGS_PROFILE )


# Define targets

add_executable(${WORKER_NAME} "")
add_executable(${TEST_EXEC_NAME} "")
add_executable(${DAEMON_NAME} "")

# configure_file(src/include/config.h.in ${CMAKE_SOURCE_DIR}/src/include/config.h @ONLY)

# Custom CMAKE Modules if any
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake_modules")

# Src files and depencies configured in seperate file
include("src/CMakeLists.txt")



# Installation targets


install(TARGETS ${WORKER_NAME} ${DAEMON_NAME}
RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
PERMISSIONS WORLD_READ WORLD_EXECUTE
CONFIGURATIONS Release
COMPONENT RUNTIME
)

# Configure compiler

target_compile_features(${WORKER_NAME} PUBLIC cxx_std_20)
target_compile_features(${DAEMON_NAME} PUBLIC cxx_std_20)
target_compile_features(${TEST_EXEC_NAME} PUBLIC cxx_std_20)
set_target_properties(${WORKER_NAME} PROPERTIES CXX_EXTENSIONS OFF)
set_target_properties(${DAEMON_NAME} PROPERTIES CXX_EXTENSIONS OFF)
set_target_properties(${TEST_EXEC_NAME} PROPERTIES CXX_EXTENSIONS OFF)


# Uninstall command
add_custom_command(
    COMMAND cat ${CMAKE_BINARY_DIR}/install_manifest.txt | xargs rm  > uninstall_manifest.txt
    OUTPUT uninstall_manifest.txt
)

add_custom_target(uninstall 
DEPENDS uninstall_manifest.txt
)