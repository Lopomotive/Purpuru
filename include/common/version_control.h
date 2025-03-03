/*Macro for C++ version controll*/
#pragma once 


/** @note add more (DELETE) */
#if __cplusplus == 201703L
  #define CPP_VERSION_17
#elif __cplusplus == 202002L
  #define CPP_VERSION_20
#elif __cpluscplus > 202002L
  #define CPP_VERSION_23_OR_LATER
#else 
  #error "Version not valid, need to be atleast C++17"
#endif 
