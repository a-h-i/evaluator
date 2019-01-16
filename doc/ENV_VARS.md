
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
SMTP_ADDRESS| SMTP server address| Development, production
SMTP_PORT| SMTP server port| Development, production
SMTP_USERNAME| SMTP user name| Development, production
SMTP_PASSWORD| SMTP password| Development, production
TRAVIS | If defined, signals that the application is running in travis CI environment.| Always applicable, do not set in production
EVALUATOR_DOMAIN_NAME | Domain name Evaluator uses | Always applicable.
RAILS_DB_POOL | Number of database pools | Should be one