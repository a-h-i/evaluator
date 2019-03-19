#pragma once
// Generic helper definitions for shared library support
// Source : https://gcc.gnu.org/wiki/Visibility
#if defined _WIN32 || defined __CYGWIN__
  #define EVSPEC_HELPER_DLL_IMPORT __declspec(dllimport)
  #define EVSPEC_HELPER_DLL_EXPORT __declspec(dllexport)
  #define EVSPEC_HELPER_DLL_LOCAL
#else
  #if __GNUC__ >= 4
    #define EVSPEC_HELPER_DLL_IMPORT __attribute__ ((visibility ("default")))
    #define EVSPEC_HELPER_DLL_EXPORT __attribute__ ((visibility ("default")))
    #define EVSPEC_HELPER_DLL_LOCAL  __attribute__ ((visibility ("hidden")))
  #else
    #define EVSPEC_HELPER_DLL_IMPORT
    #define EVSPEC_HELPER_DLL_EXPORT
    #define EVSPEC_HELPER_DLL_LOCAL
  #endif
#endif

// Now we use the generic helper definitions above to define EVSPEC_API and EVSPEC_LOCAL.
// EVSPEC_API is used for the public API symbols. It either DLL imports or DLL exports (or does nothing for static build)
// EVSPEC_LOCAL is used for non-api symbols.

#ifdef EVSPEC_DLL // defined if EVSPEC is compiled as a DLL
  #ifdef EVSPEC_DLL_EXPORTS // defined if we are building the EVSPEC DLL (instead of using it)
    #define EVSPEC_API EVSPEC_HELPER_DLL_EXPORT
  #else
    #define EVSPEC_API EVSPEC_HELPER_DLL_IMPORT
  #endif // EVSPEC_DLL_EXPORTS
  #define EVSPEC_LOCAL EVSPEC_HELPER_DLL_LOCAL
#else // EVSPEC_DLL is not defined: this means EVSPEC is a static lib.
  #define EVSPEC_API
  #define EVSPEC_LOCAL
#endif // EVSPEC_DLL