# Library sources 
list(APPEND SRCS src/process.cpp)
list(APPEND SRCS src/java/run.cpp)
list(APPEND SRCS src/java/compilation.cpp)
list(APPEND SRCS src/java/eclipse.cpp)
list(APPEND SRCS src/java/extraction.cpp)
list(APPEND SRCS src/java/parse_results.cpp)
list(APPEND SRCS src/java/pom.cpp)
list(APPEND SRCS src/exit_handler.cpp)
list(APPEND SRCS src/evaluate_submission.cpp)
list(APPEND SRCS src/lib_xml_raii.cpp)
list(APPEND SRCS src/lxc/make_virt_ctx.cpp)
list(APPEND SRCS src/delete_ctx.cpp)
list(APPEND SRCS src/lxc/lxc_ctx_t.cpp)
list(APPEND SRCS src/ssh/session_t.cpp)
list(APPEND SRCS src/ssh/sftp_session_t.cpp)
list(APPEND SRCS src/ssh/sftp_file_t.cpp)
list(APPEND SRCS resources/surefire-test-report-3.0.xsd)

# spec sources
list(APPEND SPEC_SRCS src/test/java_specs.cpp)

target_sources(${EXECUTABLE_NAME}
  PRIVATE
  ${SRCS}
  src/main.cpp
)

target_sources(${LIBRARY_NAME}
  PRIVATE
  ${SRCS}
)

list(APPEND HEADERS src/include/evspec.h)
list(APPEND HEADERS src/include/dll_imports.h)
list(APPEND HEADERS src/include/ev_spec_types.h)
list(APPEND HEADERS src/include/process.h)

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
find_package(Threads REQUIRED)
find_package(Boost COMPONENTS system filesystem unit_test_framework regex iostreams REQUIRED)
find_package(LibXml2 REQUIRED)
find_package(LibSSH REQUIRED)
list(APPEND LIBS ${Boost_SYSTEM_LIBRARY} ${Boost_FILESYSTEM_LIBRARY} ${Boost_REGEX_LIBRARY} ${LIBXML2_LIBRARIES} ${Boost_IOSTREAMS_LIBRARY} Threads::Threads)
list(APPEND INCLUDES ${Boost_INCLUDE_DIRS} ${LIBXML2_INCLUDE_DIR} "src/include")
list(APPEND INCLUDES ${LIBSSH_INCLUDE_DIRS})
list(APPEND LIBS ${Boost_ASIO_LIBRARY})
list(APPEND LIBS ${LIBSSH_LIBRARIES})
target_include_directories(${EXECUTABLE_NAME} PRIVATE ${INCLUDES})
target_include_directories(${LIBRARY_NAME} PRIVATE ${INCLUDES})
target_link_libraries(${EXECUTABLE_NAME} ${LIBS} )
target_link_libraries(${LIBRARY_NAME} ${LIBS})
target_compile_options(${EXECUTABLE_NAME} PUBLIC -fconcepts)
target_compile_options(${LIBRARY_NAME} PUBLIC -fconcepts)


enable_testing()

foreach(specSrc ${SPEC_SRCS})
  #Extract the filename without an extension (NAME_WE)
  get_filename_component(testName ${specSrc} NAME_WE)

  #Add compile target
  add_executable(${testName})
  target_sources(${testName}
  PRIVATE
  ${specSrc}
  ${SRCS}
  )
  target_compile_definitions(${testName} PRIVATE BOOST_TEST_DYN_LINK )
  target_compile_options(${testName} PUBLIC -fconcepts)
  
  target_include_directories(${testName} 
  PRIVATE ${INCLUDES})
  #link to Boost libraries AND your targets and dependencies
  target_link_libraries(${testName} ${LIBS} ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY})
  set_target_properties(${testName} PROPERTIES CXX_EXTENSIONS OFF)
  target_compile_features(${testName} PUBLIC cxx_std_20)
  set_target_properties(${testName} PROPERTIES 
              RUNTIME_OUTPUT_DIRECTORY  ${CMAKE_BINARY_DIR}/testBin)
  add_test(NAME ${testName} COMMAND ${testName} WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
endforeach(specSrc)
  