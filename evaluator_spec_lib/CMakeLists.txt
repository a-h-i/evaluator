cmake_minimum_required(VERSION 3.10)
project(evSpecLib VERSION 0.1 LANGUAGES CXX)

add_compile_definitions(VERSION_MAJOR=${PROJECT_VERSION_MAJOR})
add_compile_definitions(VERSION_MINOR=${PROJECT_VERSION_MINOR})
set(CMAKE_BUILD_PARALLEL_LEVEL 4)
set(EXECUTABLE_NAME "evSpecEx")
set(TEST_EXEC_NAME "evSpecSpecs")
set(LIBRARY_NAME "evSpecLib")

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang" OR "${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU" )
    add_definitions(
        -std=c++2a
        -Wall
        -Wextra
        -pedantic
        )
    # Yes discard default values
    set(CMAKE_CXX_FLAGS_RELEASE "-flto -O3 -march=native -fmerge-all-constants -fgcse-sm -fgcse-las")
    set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-flto -s")
elseif ( "${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC" )
    add_definitions(
        /Wall
        /WX        
        )
    set(CMAKE_CXX_FLAGS_RELEASE "/Ox /Oi /arch:SSE2")
endif()



add_executable(${EXECUTABLE_NAME} "")
add_executable(${TEST_EXEC_NAME} "")
add_library(${LIBRARY_NAME} SHARED "")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake_modules")

include("src/CMakeLists.txt")

set_target_properties(${LIBRARY_NAME} PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION}
    PUBLIC_HEADER src/include/evspec.h
    )


file(COPY fixtures DESTINATION .)
file(COPY resources/surefire-test-report-3.0.xsd DESTINATION .)
configure_file(evspeclib.pc.in evspeclib.pc @ONLY)



install(TARGETS ${LIBRARY_NAME}
    LIBRARY DESTINATION lib ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION include ${CMAKE_INSTALL_INCLUDEDIR}
    PERMISSIONS WORLD_READ
    CONFIGURATIONS Release
    COMPONENT LIBRARY)
install(FILES ${CMAKE_BINARY_DIR}/evspeclib.pc
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/pkgconfig)

install(FILES ${CMAKE_SOURCE_DIR}/resources/surefire-test-report-3.0.xsd
    DESTINATION etc/evspec/surefire-test-report-3.0.xsd
    PERMISSIONS WORLD_READ
    COMPONENT CONFIG
)

target_compile_features(${EXECUTABLE_NAME} PUBLIC cxx_std_20)
target_compile_features(${TEST_EXEC_NAME} PUBLIC cxx_std_20)
target_compile_features(${LIBRARY_NAME} PUBLIC cxx_std_20)
set_target_properties(${EXECUTABLE_NAME} PROPERTIES CXX_EXTENSIONS OFF)
set_target_properties(${TEST_EXEC_NAME} PROPERTIES CXX_EXTENSIONS OFF)
set_target_properties(${LIBRARY_NAME} PROPERTIES CXX_EXTENSIONS OFF)