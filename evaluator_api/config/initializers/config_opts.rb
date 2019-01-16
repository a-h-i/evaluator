# Application wide options shared with client side

Rails.application.config.configurations = {
  error_messages: {
    expired_token: 'Token has expired',
    token_verification: 'Unable to verify Token',
    forbidden: 'Forbidden',
    authentication_error: 'Authentication Error',
    argument_error: 'Argument error',
    record_not_found: 'Record not found',
    forbidden_teacher_only: 'Must be a teacher to perform this action',
    unverified_login: 'Must be verified to login',
    incorrect_reset_token: 'Incorrect reset token',
    incorrect_verification_token: 'Incorrect verification token',
    too_soon: 'Please calm down',
    bad_request: 'Bad Request',
    internal_server_error: 'Internal Server error',
    forbidden_super_user_only: 'Must be a super user to perform this action'
  },
  default_token_exp: 24.hours,
  messages: {
    registration_success: 'Registered to course',
    unregistration_success: 'Unregistered from course'
  },
  max_num_submissions: 3,
  verification_expiration: 5.hours,
  pass_reset_expiration: 24.hours,
  user_verification_resend_delay: 5.minutes,
  pass_reset_resend_delay: 5.minutes,
  notification_event_types: {
    submission_result_ready: 'RESULT_READY',
    test_suite_processed: 'SUITE_PROCESSED',
    course_created: 'COURSE_CREATED',
    course_published: 'COURSE_PUBLISHED',
    project_created: 'PROJECT_CREATED',
    project_published: 'PROJECT_PUBLISHED',
    project_unpublished: 'PROJECT_UNPUBLISHED',
    suite_created: 'SUITE_CREATED',
    submission_deleted: 'SUBMISSION_DELETED',
    suite_deleted: 'SUITE_DELETED',
    project_deleted: 'PROJECT_DElETED',
    course_deleted: 'COURSE_DELETED',
    team_job_status: 'TEAM_JOB_STATUS',
    project_bundle_ready: 'BUNDLE_READY',
    team_grade_created: 'TEAM_GRADE_CREATED'
  },
  project_bundle_life_hours: 24
}
