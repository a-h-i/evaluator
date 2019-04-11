cmake_minimum_required(VERSION 3.10)
# Define version and project
project(evspec VERSION 3.0 LANGUAGES CXX
DESCRIPTION  "Evaluator Library for running projects."
)
add_compile_definitions(VERSION_MAJOR=${PROJECT_VERSION_MAJOR})
add_compile_definitions(VERSION_MINOR=${PROJECT_VERSION_MINOR})
include(GNUInstallDirs)

# Target names
set(EXECUTABLE_NAME "evSpecEx")
set(LIBRARY_NAME ${PROJECT_NAME})
set(PACKAGE_NAME "Evspec")

# Target directores for installation and configurawtion files
set(EVSPEC_LIB_DIR "${CMAKE_INSTALL_LIBDIR}/${LIBRARY_NAME}")
set(EVSPEC_EXPORT_DIR "${EVSPEC_LIB_DIR}/cmake")
set(EVSPEC_INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/${LIBRARY_NAME}")
set(EVSPEC_PKGCONF_DIR "${CMAKE_INSTALL_LIBDIR}/pkgconfig")
set(EVSPEC_CONFIG_DIR "${CMAKE_INSTALL_SYSCONFDIR}/${LIBRARY_NAME}")
set(EVSPEC_PKGCONF_FILE "${LIBRARY_NAME}.pc")
set(EVSPEC_LD_CONF_DIR "${CMAKE_INSTALL_SYSCONFDIR}/ld.so.conf.d")
set(EVSPEC_LD_CONF_FILE_NAME "${LIBRARY_NAME}.conf")    



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
if(${CMAKE_BUILD_TYPE} STREQUAL "Release")
    add_definitions(-DNDEBUG)
else()
    add_definitions(-DDEBUG)
endif()
MARK_AS_ADVANCED(
    CMAKE_CXX_FLAGS_PROFILE
    CMAKE_C_FLAGS_PROFILE
    CMAKE_EXE_LINKER_FLAGS_PROFILE
    CMAKE_SHARED_LINKER_FLAGS_PROFILE )


# Define targets

add_executable(${EXECUTABLE_NAME} "")
add_library(${LIBRARY_NAME} SHARED "")
target_compile_definitions(${LIBRARY_NAME} PUBLIC EVSPEC_DLL)
target_compile_definitions(${LIBRARY_NAME} PRIVATE EVSPEC_DLL_EXPORTS)
# Custom CMAKE Modules if any
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake_modules")

# Src files and depencies configured in seperate file
include("src/CMakeLists.txt")

# Shared library properties

set_target_properties(${LIBRARY_NAME} PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION}

    )


# Note this is not done when installing

file(COPY fixtures DESTINATION .)
file(COPY resources/surefire-test-report-3.0.xsd DESTINATION .)



# Configuration files
configure_file(evspeclib.pc.in ${EVSPEC_PKGCONF_FILE} @ONLY)
configure_file(evspec.ld.conf ${EVSPEC_LD_CONF_FILE_NAME} @ONLY)


# Set for install tree
configure_file(EvspecConfig.cmake.in
  "EvspecConfig.cmake" @ONLY)
configure_file(EvspecConfigVersion.cmake.in
    "EvspecConfigVersion.cmake" @ONLY)





# Installation targets

install(TARGETS ${LIBRARY_NAME}
    LIBRARY DESTINATION ${EVSPEC_LIB_DIR}
    PUBLIC_HEADER DESTINATION ${EVSPEC_INCLUDE_DIR}
    PERMISSIONS WORLD_READ WORLD_EXECUTE
    CONFIGURATIONS Release
    COMPONENT LIBRARY

    )

# Install cmake config files
install(FILES 
    ${CMAKE_BINARY_DIR}/EvspecConfig.cmake
    ${CMAKE_BINARY_DIR}/EvspecConfigVersion.cmake
    DESTINATION ${EVSPEC_EXPORT_DIR}
)



# Install pkgconfig
install(FILES ${CMAKE_BINARY_DIR}/${EVSPEC_PKGCONF_FILE}
    DESTINATION  ${EVSPEC_PKGCONF_DIR})
# Install ldconf
install(FILES ${CMAKE_BINARY_DIR}/${EVSPEC_LD_CONF_FILE_NAME}
    DESTINATION ${EVSPEC_LD_CONF_DIR}
)

install(FILES ${CMAKE_SOURCE_DIR}/resources/surefire-test-report-3.0.xsd
    DESTINATION ${EVSPEC_CONFIG_DIR}
    PERMISSIONS WORLD_READ
    COMPONENT CONFIG
)


# Configure compiler

target_compile_features(${EXECUTABLE_NAME} PUBLIC cxx_std_20)
target_compile_features(${LIBRARY_NAME} PUBLIC cxx_std_20)

set_target_properties(${EXECUTABLE_NAME} PROPERTIES CXX_EXTENSIONS OFF)
set_target_properties(${LIBRARY_NAME} PROPERTIES CXX_EXTENSIONS OFF)


# Uninstall command
add_custom_command(
    COMMAND cat ${CMAKE_BINARY_DIR}/install_manifest.txt | xargs rm  > uninstall_manifest.txt
    OUTPUT uninstall_manifest.txt
)

add_custom_target(uninstall 
DEPENDS uninstall_manifest.txt
)