/*Macro for C++ version controll*/
#pragma once 

#if __cplusplus == 201703L
  #define CPP_VERSION "C++17"
#elif __cplusplus == 202002L
  #define CPP_VERSION "C++20"
#elif __cpluscplus > 202002L
  #define CPP_VERSION "C++23 or later"
#else 
  #error "Version not valid, need to be atleast C++17"
#endif 
