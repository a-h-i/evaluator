

list(APPEND SRCS src/spec.cpp)
list(APPEND SRCS src/process.cpp)
list(APPEND SRCS src/java/run.cpp)
list(APPEND SRCS src/java/compilation.cpp)
list(APPEND SRCS src/java/eclipse.cpp)
list(APPEND SRCS src/java/extraction.cpp)
list(APPEND SRCS src/java/parse_results.cpp)
list(APPEND SRCS src/java/pom.cpp)
list(APPEND SRCS src/exit_handler.cpp)
list(APPEND SRCS resources/surefire-test-report-3.0.xsd)
target_sources(${EXECUTABLE_NAME}
  PRIVATE
  ${SRCS}
  src/main.cpp
)
target_sources(${TEST_EXEC_NAME}
  PRIVATE
  ${SRCS}
  src/test/java_specs.cpp
)
target_sources(${LIBRARY_NAME}
  PRIVATE
  ${SRCS}
)

list(APPEND HEADERS src/include/evspec.h)
list(APPEND HEADERS src/include/ev_spec_types.h)

set_property(TARGET ${LIBRARY_NAME} PROPERTY
PUBLIC_HEADER ${HEADERS}
)

add_compile_definitions(BOOST_ALL_DYN_LINK=1)
set(Boost_USE_STATIC_LIBS OFF)
set(Boost_USE_STATIC_RUNTIME OFF)
set(Boost_USE_DEBUG_RUNTIME OFF)
set(Boost_USE_DEBUG_PYTHON OFF)
set(Boost_USE_MULTITHREADED ON)
set(Boost_THREADAPI pthread)
set(BOOST_REGEX_RECURSIVE TRUE)
find_package(Boost COMPONENTS system filesystem unit_test_framework regex iostreams REQUIRED)
find_package(LibXml2 REQUIRED)
list(APPEND LIBS ${Boost_SYSTEM_LIBRARY} ${Boost_FILESYSTEM_LIBRARY} ${Boost_REGEX_LIBRARY} ${LIBXML2_LIBRARIES} ${Boost_IOSTREAMS_LIBRARY})
list(APPEND INCLUDES ${Boost_INCLUDE_DIRS} ${LIBXML2_INCLUDE_DIR} "src/include")
target_include_directories(${EXECUTABLE_NAME} PRIVATE ${INCLUDES})
target_include_directories(${TEST_EXEC_NAME} PRIVATE ${INCLUDES})
target_include_directories(${LIBRARY_NAME} PRIVATE ${INCLUDES})
target_link_libraries(${EXECUTABLE_NAME} ${LIBS} )
target_link_libraries(${TEST_EXEC_NAME}  ${LIBS})
target_link_libraries(${LIBRARY_NAME} ${LIBS})


