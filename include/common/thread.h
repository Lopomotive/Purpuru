/**
* @brief thread macro
* @note specific thread implementations should not be implemented here as of right now
*/

/** @brief dependant on OS header file */
#include "OS.h"

#ifndef THREAD_H
#define THREAD_H

#if !defined(__STCPP_THREADS)

  #error "Threading is not supported"

#endif

/** @brief check for cpu features */ 
#if defined CPU_FEATURE

#endif

/** @brief check thread count*/
#if defined(LINUX_64) || (LINUX_32)
  #include <unistd.h>
  #define GET_HARDWARE_THREADS() \
    (uint8_t)sysconf(_SC_NPPROCESSORS_ONLN)
#endif

/** @brief get cpu features */
#define 

/** @note dive deeper into this */
#define GET_RECOMMENDED_THREADS() \


//--------------------------------------

// @brief below are placeholders
#define HAS_SSE2() (defined(CPU_HAS_SSE2) && CPU_HAS_SSE2)
#define HAS_AVX() (defined(CPU_HAS_AVX) && CPU_HAS_AVX)
#define HAS_AVX2() (defined(CPU_HAS_AVX2) && CPU_HAS_AVX2)
#define HAS_AVX512() (defined(CPU_HAS_AVX512) && CPU_HAS_AVX512)

// Get recommended thread count based on CPU architecture
#define GET_RECOMMENDED_THREADS() \
    (HAS_AVX512() ? GET_HARDWARE_THREADS() * 2 : \
     HAS_AVX2() ? GET_HARDWARE_THREADS() * 2 : \
     HAS_AVX() ? GET_HARDWARE_THREADS() : \
     GET_HARDWARE_THREADS())
