#define BOOST_TEST_MODULE redis_ctx spec - redis functions spec
#include <boost/test/unit_test.hpp>
#include "redis_ctx.h"
using namespace evworker::redis;
BOOST_AUTO_TEST_SUITE(redis_tests)

BOOST_AUTO_TEST_CASE(redis_connection) {
  redis_ctx* redis;
  BOOST_REQUIRE_NO_THROW(redis = new redis_ctx("127.0.0.1", 6379));
  reply_t reply = redis->command("SELECT %i", 0);
  std::string what;
  BOOST_TEST(!reply.is_error_reply(&what));
}

BOOST_AUTO_TEST_CASE(redis_set_get) {
  redis_ctx* redis;
  BOOST_REQUIRE_NO_THROW(redis = new redis_ctx("127.0.0.1", 6379));
  reply_t reply = redis->command("SELECT %i", 0);
  std::string what;
  BOOST_TEST(!reply.is_error_reply(&what));

  reply = redis->command("SET %s %s", "test", "value");
  BOOST_TEST(!reply.is_error_reply(&what));

  reply = redis->command("GET %s", "test");
  BOOST_TEST(!reply.is_error_reply(&what));
  BOOST_TEST(reply->type == REDIS_REPLY_STRING);
  std::unique_ptr<char[]> buff(new char[reply->len + 1]);
  buff[reply->len] = 0;
  std::memcpy(buff.get(), reply->str, reply->len);
  BOOST_TEST(std::string("value") == std::string(buff.get()));
  BOOST_TEST(reply->len == strlen("value"));
}

BOOST_AUTO_TEST_SUITE_END()
