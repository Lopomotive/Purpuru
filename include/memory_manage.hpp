/*This file will be used to safely manage memory using most metaprogramming*/
#include <concepts>

template <typename T>
concept ptr_val = require(T*t){
  
}
