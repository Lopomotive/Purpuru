/**
* @brief header for general types
* @note testing should be highly prioritized 
*/

#include <memory>
#include <type_traits>

/** @brief functional types */
#ifdef FUNCTION_TYPES
  #include <functional>
  /** @note generic_func_ptr_std recommended */
  using generic_func_ptr_std = std::function<void*()>;
  using generic_func_ptr_raw = void*(*)();
#endif

/** @brief common data types OS specific */
#ifdef COMMON_TYPES
  #define
#endif

/** @brief common pointer data types built ontop of COMMON_TYPES*/
#ifdef COMMON_PTR_TYPES

#endif

/** @brief debug macros*/
#ifdef DEBUG
  /** @note debug macros need work (DELETE)*/
  #define LOG(x, fmt, ...)    if(x){printf("%s@%d: " fmt "\n",\
                            __FILE__, __LINE__,__VA_ARGS__);}
  #define TRY(x,s)            if(!(x)){printf("%s@%d: %s",__FILE__, __LINE__,s);}
#endif
