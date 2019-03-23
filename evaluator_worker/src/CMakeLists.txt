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
# ────────────────── Worker Sources ──────────────────


list(APPEND WORKER_SOURCES src/worker/worker.cpp)
list(APPEND WORKER_SOURCES src/worker_main.cpp)
list(APPEND WORKER_SOURCES src/worker/redis.cpp)
list(APPEND WORKER_SOURCES src/worker/worker_ctx_raii.cpp)
list(APPEND WORKER_SOURCES src/worker/worker_ctx_redis.cpp)
list(APPEND WORKER_SOURCES src/worker/pg.cpp)

# ────────────────── Daemon Sources ──────────────────

list(APPEND DAEMON_SOURCES src/daemon_main.cpp)

# ────────────────── Spec Sources
list(APPEND SPEC_SRCS src/test/options_spec.cpp)

file(COPY fixtures DESTINATION .)
# ────────────────── Add sources to targets ────────────────── 

target_sources(${WORKER_NAME}
  PRIVATE
  ${SRCS}
  ${WORKER_SOURCES}
)

target_sources(${DAEMON_NAME}
  PRIVATE
  ${SRCS}
  ${DAEMON_SOURCES}
)

target_sources(${TEST_EXEC_NAME}
  PRIVATE
  ${SRCS}
  ${SPEC_SRCS}
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
find_package(Boost COMPONENTS system unit_test_framework program_options REQUIRED)
find_package(Evspec REQUIRED CONFIG)
find_package(PostgreSQL REQUIRED)
find_package(Hiredis REQUIRED)
find_package(Uuid REQUIRED)

# ────────────────── Linked Libraries
list(APPEND LIBS ${Boost_REGEX_LIBRARY} ${LIBXML2_LIBRARIES} ${EVSPEC_LIBRARIES} Threads::Threads)
list(APPEND LIBS ${PostgreSQL_LIBRARIES})
list(APPEND LIBS ${Boost_SYSTEM_LIBRARY})
list(APPEND LIBS ${HIREDIS_LIBRARIES})
list(APPEND LIBS ${Boost_PROGRAM_OPTIONS_LIBRARY})
list(APPEND LIBS ${UUID_LIBRARY})
list(APPEND LIBS -lstdc++fs)

# ────────────────── Include directories
list(APPEND INCLUDES ${Boost_INCLUDE_DIRS} ${LIBXML2_INCLUDE_DIRS} ${EVSPEC_INCLUDE_DIRS} ${PostgreSQL_INCLUDE_DIRS})
list(APPEND INCLUDES ${HIREDIS_INCLUDE_DIRS})
list(APPEND INCLUDES src/include )
list(APPEND INCLUDES ${UUID_INCLUDE_DIR})


# ──────────────────  add includes and libraries to targets

target_include_directories(${WORKER_NAME} 
PRIVATE ${INCLUDES})
target_include_directories(${TEST_EXEC_NAME}
PRIVATE ${INCLUDES})
target_include_directories(${DAEMON_NAME}
PRIVATE ${INCLUDES} )


target_link_libraries(${WORKER_NAME} ${LIBS} )
target_link_libraries(${TEST_EXEC_NAME} ${LIBS} )
target_link_libraries(${DAEMON_NAME}  ${LIBS})