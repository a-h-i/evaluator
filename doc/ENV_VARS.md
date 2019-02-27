
Environment Variables
=====================


Environment variables that need to be set

KEY | DESCRIPTION | APPLICABLE ENVIRONMENT
-----|------------|--------------
SECRET_KEY_BASE | Rails secret key for cookie signing| production
JWT_KEY| HMAC key for JWT encoding | Always applicable, but must set in production
DB_NAME| PG database name | production
DB_USER| PG username | production
DB_PASSWORD| PG username password | production
VERIFICATION_TOKEN_STR_MAX_LENGTH | Max length of the email verification token (used in query param) default is 30| All
PASS_RESET_TOKEN_STR_MAX_LENGTH | Max length of the password reset token (used in query param) default is 30| All
EV_SMTP_HOST| SMTP server address| Development, production
EV_SMTP_PORT| SMTP server port| Development, production
SMTP_USERNAME| SMTP user name| Development, production
SMTP_PASSWORD| SMTP password| Development, production
TRAVIS | If defined, signals that the application is running in travis CI environment.| Always applicable, do not set in production
EVALUATOR_DOMAIN_NAME | Domain name Evaluator uses | Always applicable.
RAILS_DB_POOL | Number of database pools | Should be one
EVALUATOR_REDIS_CACHE_HOST | cache host address | defaults to localhost
EVALUATOR_REDIS_CACHE_PORT | cache port | defaults to 6379
EVALUATOR_REDIS_CACHE_DB| Cache db | defaults to zero
EVALUATOR_ARGON_T_COST| argon2 t_cost| ask someone who understands password hashing
EVALUATOR_ARGON_M_COST| argon2 m_cost | ask someone who understands password hashing
EVALUATOR_REDIS_MESSAGING_HOST| redis host| should be different server than cache
EVALUATOR_REDIS_MESSAGING_PORT| redis port| should be different server than cache 
EVALUATOR_REDIS_MESSAGING_DB| redis db | should be different than cache value
EV_SUBMISSIONS_PATH| defaults to /mnt/evaluator/submissions | need to be set in production
EV_TEST_SUITE_PATH| defaults to /mnt/evaluator/test_suites | need to be set in production