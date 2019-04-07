# ────────────────── Common Sources ──────────────────

list(APPEND SRCS src/utility/print_exception.cpp)
list(APPEND SRCS src/utility/write_backtrace.cpp)
list(APPEND SRCS src/signals/handlers.cpp)
list(APPEND SRCS src/utility/constants.cpp)
list(APPEND SRCS src/utility/pid_helpers.cpp)
list(APPEND SRCS src/options/parse_options.cpp)
list(APPEND SRCS src/options/options_config.cpp)
list(APPEND SRCS src/signals/atomic_globals.cpp)
list(APPEND SRCS fixtures/sample_config.ini)

# ────────────────── MESSAGE INTERFACE ──────────────────
list(APPEND MESSAGE_INTERFACE src/messaging/message_generation.cpp)
list(APPEND MESSAGE_INTERFACE src/messaging/message_parsing.cpp)
list(APPEND MESSAGE_INTERFACE src/messaging/types.cpp)



# ────────────────── PG Sources ──────────────────
list(APPEND PG_SOURCES src/db/pg.cpp)
list(APPEND PG_SOURCES src/db/submission.cpp)
list(APPEND PG_SOURCES src/db/test_suite.cpp)
list(APPEND PG_SOURCES src/db/helpers.cpp)
list(APPEND PG_SOURCES src/db/project.cpp)

# ────────────────── Redis Sources ──────────────────

list(APPEND REDIS_SOURCES src/redis/reply.cpp)
list(APPEND REDIS_SOURCES src/redis/redis.cpp)

# ────────────────── Worker Sources ──────────────────

list(APPEND WORKER_SOURCES src/worker/worker.cpp)
list(APPEND WORKER_SOURCES src/worker/worker_ctx_raii.cpp)
list(APPEND WORKER_SOURCES src/worker/worker_ctx_redis.cpp)


# ────────────────── Daemon Sources ──────────────────

list(APPEND DAEMON_SOURCES src/daemon_main.cpp)

# ────────────────── Spec Sources
list(APPEND SPEC_SRCS src/test/options_spec.cpp)
list(APPEND SPEC_SRCS src/test/redis_spec.cpp)
list(APPEND SPEC_SRCS src/test/pg_spec.cpp)

file(COPY fixtures DESTINATION .)
# ────────────────── Add sources to targets ────────────────── 

target_sources(${WORKER_NAME}
  PRIVATE
  ${SRCS}
  ${WORKER_SOURCES}
  ${REDIS_SOURCES}
  ${PG_SOURCES}
  ${MESSAGE_INTERFACE}
  src/worker_main.cpp
)

target_sources(${DAEMON_NAME}
  PRIVATE
  ${SRCS}
  ${DAEMON_SOURCES}
)


# ──────────────────  Boost Definitions ────────────────── 
add_compile_definitions(BOOST_ALL_DYN_LINK=1)
set(Boost_USE_STATIC_LIBS OFF)
set(Boost_USE_STATIC_RUNTIME OFF)
set(Boost_USE_DEBUG_RUNTIME OFF)
set(Boost_USE_DEBUG_PYTHON OFF)
set(Boost_USE_MULTITHREADED ON)
set(Boost_THREADAPI pthread)
set(BOOST_REGEX_RECURSIVE TRUE)

# ────────────────── Dependencies
find_package(Threads REQUIRED)
find_package(Boost COMPONENTS system filesystem unit_test_framework program_options REQUIRED)
find_package(Evspec REQUIRED CONFIG)
find_package(PostgreSQL REQUIRED)
find_package(Hiredis REQUIRED)
find_package(Uuid REQUIRED)

# ────────────────── Linked Libraries
list(APPEND LIBS ${Boost_REGEX_LIBRARY} ${LIBXML2_LIBRARIES} ${EVSPEC_LIBRARIES} Threads::Threads)
list(APPEND PG_LIBS ${PostgreSQL_LIBRARIES})
list(APPEND LIBS ${Boost_SYSTEM_LIBRARY})
list(APPEND REDIS_LIBS ${HIREDIS_LIBRARIES})
list(APPEND LIBS ${Boost_PROGRAM_OPTIONS_LIBRARY})
list(APPEND LIBS ${UUID_LIBRARY})
list(APPEND LIBS -lstdc++fs)
list(APPEND LIBS ${Boost_FILESYSTEM_LIBRARY})
# ────────────────── Include directories
list(APPEND INCLUDES ${Boost_INCLUDE_DIRS} ${LIBXML2_INCLUDE_DIRS} ${EVSPEC_INCLUDE_DIRS} ${PostgreSQL_INCLUDE_DIRS})
list(APPEND INCLUDES ${HIREDIS_INCLUDE_DIRS})
list(APPEND INCLUDES src/include )
list(APPEND INCLUDES ${UUID_INCLUDE_DIR})


# ──────────────────  add includes and libraries to targets

target_include_directories(${WORKER_NAME} 
PRIVATE ${INCLUDES})
target_include_directories(${DAEMON_NAME}
PRIVATE ${INCLUDES} )


target_link_libraries(${WORKER_NAME} ${LIBS} ${REDIS_LIBS} ${PG_LIBS})
target_link_libraries(${DAEMON_NAME}  ${LIBS} )




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
  ${WORKER_SOURCES}
  ${REDIS_SOURCES}
  ${PG_SOURCES}
  ${MESSAGE_INTERFACE}
  )
  target_compile_definitions(${testName} PRIVATE BOOST_TEST_DYN_LINK)
  target_include_directories(${testName} 
  PRIVATE ${INCLUDES})
  #link to Boost libraries AND your targets and dependencies
  target_link_libraries(${testName} ${LIBS} ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY} ${REDIS_LIBS} ${PG_LIBS})
  set_target_properties(${testName} PROPERTIES CXX_EXTENSIONS OFF)
  target_compile_features(${testName} PUBLIC cxx_std_20)
  set_target_properties(${testName} PROPERTIES 
              RUNTIME_OUTPUT_DIRECTORY  ${CMAKE_BINARY_DIR}/testBin)
  add_test(NAME ${testName} COMMAND ${testName} WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
endforeach(specSrc)
  


