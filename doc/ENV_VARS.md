
Environment Variables
=====================


Environment variables that need to be set

KEY | DESCRIPTION | APPLICABLE ENVIRONMENT
-----|------------|--------------
EVALUATOR_API_DATABASE_HOST| defaults to localhost | production
EVALUATOR_API_DATABASE_PORT| defaults to 5432 | production
EVALUATOR_API_DATABASE_PASSWORD| PG username password | production
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
RAILS_LOG_TO_STDOUT| Set to TRUE with unicorn deployments | should be set in production, has no effect on non production environments