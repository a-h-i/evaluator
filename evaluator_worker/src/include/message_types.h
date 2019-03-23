#pragma once


enum class MetaFieldType: unsigned int {
  MESSAGE_TYPE = 1,
  WORKER_TASKS_PENDING_QUEUE_NAME = 2,
  WORKER_TASKS_RUNNING_QUEUE_NAME = 3,
  WORKER_TASKS_ERROR_QUEUE_NAME = 4,
  WORKER_NAME = 5
};

enum class MessageType: unsigned int {
  WORKER_UP = 1
};