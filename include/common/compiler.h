/**
* @brief general file for compilers
* @note only gcc is currently fully supported, other compilers supported
* by linux may or may not work 
*/

#include "OS.h"

/** @brief get the compiler optimization level */
// In compiler.h
#if defined(__GNUC__)
    #if defined(__OPTIMIZE_SIZE__)
        #define OPTIMIZATION_LEVEL "-Os"
    #elif defined(__OPTIMIZE__)
        #define OPTIMIZATION_LEVEL "-O2"
    #else
        #define OPTIMIZATION_LEVEL "-O0"
        #warning "No optimization currently available on GNU (using -Os)"
    #endif
#else
    #define OPTIMIZATION_LEVEL "Unknown"
#endif

/** @note Only Linux is currently supported */
#if defined(__linux__) && defined(__x86_64__)
  #if defined(__GNUC__)
    /** @note Make more here */
    #if defined(__OPTIMIZE__)
      #if defined(__OPTIMIZE_SIZE__)
        #warning "No optimization currently available on GNU (using -Os)"
      #endif
    #endif
  #endif
#endif
