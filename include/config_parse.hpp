//File to read and set program configs(DELETE)
#include <libconfig.h++> //Read config filej
#include <regex>
#include <stdexcept>
#include <variant>
#include <filesystem>
#include <ostream>
#include <unordered_map>

#include "bot_core.hpp" 
#define REGEX_TYPE

/*
*
*/

enum filetype {
  logging,
  type_unknown
};

enum perms{
  no_perms = 0,
  owner_read = 0400,
  owner_write = 0200,
  owner_exe = 0100,
  owner_all = 0700,

  group_read = 040,
  group_write = 020,
  group_exe = 010,
  group_all = 070,

  others_read = 04,
  others_write = 02,
  others_exe = 01,
  others_all = 07,

  all_all =  0777
};

typedef std::filesystem::path path_t;
template <typename T>
constexpr bool is_string = std::is_same_v<T, std::string>;

template <typename T>
struct path_converter{
  
};

template<>
struct path_converter<std::string_view> {
    static constexpr bool is_convertible = true;
    static std::filesystem::path convert(std::string_view sv) {
        return std::filesystem::path(sv);
    }
};

template<>
struct path_converter<std::string>{
  static constexpr bool is_convertible = true;
  static std::filesystem::path convert(std::string sv){
    return std::filesystem::path(sv);
  }
};

template <typename T>
auto safe_path_convert(const T& value) -> 
    typename std::enable_if<path_converter<T>::is_convertible, std::filesystem::path>::type {
    return path_converter<T>::convert(value);
}

template <typename T> 
using string_or_char_t =
 typename std::enable_if<std::is_same_v<std::decay_t<T>, const char> ||
                        std::is_same_v<std::decay_t<T>, std::string>, T
 >;

template <typename T>
std::string_view* get_folder(string_or_char_t<T> folder_path){
  using type = T;
  auto valid_path = path_converter<decltype(folder_path)>::type;
  FILE * file_it = fopen()
}
  

typedef struct Logging{
  
Logging;
