/**
* @brief version control preprocessors
*/

/** @brief linux version check */
/** @note only operating system currently supported*/
#if defined(__linux__)

  #if defined __x86_64__
    #define LINUX_64
    #define CPU_ARCH_X64 1

    
  #elif defined __x32__
    #define LINUX_32
    #define CPU_ARCH_X32 1

    
  #endif
  #else
    #error "This program is only accesible for linux users"
#endif
