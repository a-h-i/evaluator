#pragma once
#include <functional>

namespace raii {
class ScopeRaii {
public:
  inline ScopeRaii(std::function<void()> closure) : closure(closure) {}
  inline ~ScopeRaii() { closure(); }

private:
  std::function<void()> closure;
};
} // namespace raii