#include <dpp/dispatcher.h>
#include <concepts>
#include <dpp/dpp.h>
#include <optional>
#include "get_env_file.hpp"
#include "version_control.hpp"

/*https://dpp.dev/coding-standards.html*/

#ifndef MEMORY_MANAGE
  #define MEMORY_MANAGE
  template <typename T>
  void safe_delete(T*& ptr){
    delete ptr;
    ptr = nullptr;
  }
#endif

/*Discord MACROS*/
#ifndef SHARDS
#define SHARDS 20 
#endif

const char* text_limit[256];

#ifdef ERORR_LOGGING
/*https://stackoverflow.com/questions/19415845/a-better-log-macro-using-template-metaprogramming*/
#define LOG(...) LOGWRAPPER(__FILE__, __LINE__, __VA_ARGS__, __TIME__)

#ifndef NOINLINE_ATTRIBUTE
  #ifdef __ICC
    #define NOINLINE_ATTRIBUTE __attribute__(( noinline ))
  #else
    #define NOINLINE_ATTRIBUTE
  #endif // __ICC
#endif 

template <typename T> struct PartTrait {typedef T Type;};

/*Will be worked on*/
namespace user{
  PartTrait<uint64_t>::Type user_id;
  struct UserTokenDump;
  std::string *user_token = nullptr;
}
#endif 

#ifdef REGEX_TYPE
template <typename T>
constexpr bool is_regex_matchable_v = std::is_convertible_v<T, std::string_view>;

template <typename T, typename = void>
struct regex_matchable_type {
    static_assert(sizeof(T) == 0, "T is not regex matchable");
};

template <typename T>
struct regex_matchable_type<T, std::enable_if_t<is_regex_matchable_v<T>>> {
    using type = T;
};

template <typename T>
using regex_matchable_type_t = typename regex_matchable_type<T>::type;

#endif

#ifdef BUFFER_OVERFLOW_CHECK

//This may work but needs to be checked in the future
template<size_t N>
struct compile_time_index {};

template<size_t N>
constexpr compile_time_index<N> index{};

template<typename T, size_t Size>
constexpr bool check_bounds(compile_time_index<0>) {
    return true;
}

//Make this function better
template <typename T, std::size_t Size>
constexpr std::vector<T> convert_to_safe(const std::array<T, Size>& unsafe_buffer){
  static_assert(N > 0, std::runtime_error);
  static_assert(std::is_trivially_copyable_v<T>, std::runtime_error);
  std::vector<T> safeVector(unsafe_buffer.begin(), unsafe_buffer.end());
  return safeVector;;
}
template<typename T, std::size_t Size, typename... Is>
constexpr bool check_bounds(compile_time_index<Size>, compile_time_index<Is...>, bool recreate_buffer) {
    static_assert(Size < sizeof(T), "Index out of bounds");
    if(!recreate_buffer) return check_bounds(compile_time_index<Size + 1>, compile_time_index<Is...>{});
    else{
      
    }
}

#endif
