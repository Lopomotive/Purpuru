//File to read and set program configs(DELETE)
#include <libconfig.h++> //Read config file
#include <regex>
#include <stdexcept>
#include <variant>
#include <filesystem>
#include <ostream>
#include <unordered_map>
#include <sys/stat.h> //For file permission checking

#include "bot_core.hpp" 
#define REGEX_TYPE

#define LINUX  //Will be in other file later

#ifdef LINUX
#include <fcntl.h>
#else 
#error "This program only supports linux for now"
#endif

//Work on comments(DELETE)
/*
* filetype enum identifier to have file type
* FilePerms enum class to match possible enums
*/

enum filetype {
  logging,
  type_unknown
};


std::unordered_map<uint8_t, uint8_t> perm_to_flag = {
    {S_IRUSR, O_RDONLY},         // Owner read
    {S_IWUSR, O_WRONLY},         // Owner write
    {S_IXUSR, O_RDWR},           // Owner exec
    {S_IRWXU, O_RDWR},           // Owner all
    {S_IRGRP, O_RDONLY},         // Group read
    {S_IWGRP, O_WRONLY},         // Group write
    {S_IXGRP, O_RDWR},           // Group exec
    {S_IRWXG, O_RDWR},           // Group all
    {S_IROTH, O_RDONLY},         // Others read
    {S_IWOTH, O_WRONLY},         // Others write
    {S_IXOTH, O_RDWR},           // Others exec
    {S_IRWXO, O_RDWR},           // Others all
    {S_IRWXU | S_IRWXG | S_IRWXO, O_RDWR} // All permissions
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
 typename std::enable_if<std::is_same_v<std::decay_t<T>, const char*> ||
                        std::is_same_v<std::decay_t<T>, std::string>, T
 >;

/*
* check if variable have been initilzied or not
* works by: is_initalized_v
*/
template<typename T>
struct is_initialized {
    template<typename U = T>
    static constexpr bool value = std::is_base_of<std::monostate, U>::value && std::is_lvalue_reference<U>::value;
};

//This is not working for some reason(DELETE)
template<typename T>
inline constexpr bool is_init_v = is_initialized<T>::value;

template <typename T>
std::string_view* get_folder(string_or_char_t<T> folder_path, uint8_t perm_t,
  std::optional<std::shared_ptr<std::unordered_map<std::string, uint8_t>>> map_perm_t){
  //Struct storing error values, may parse differently later
  struct files_not_working{
    std::string_view value = nullptr;
    
  };
  
  auto valid_path = safe_path_convert(folder_path);
  if(std::filesystem::exists(valid_path)){
    std::array<uint8_t, 3> default_flags = {S_IRUSR, S_IWUSR, S_IRGRP}; //Array may change later
    std::shared_ptr<std::unordered_map<std::string_view, uint8_t>> map_perm_tt = nullptr;
    //bool perm_map_included = is_init_v<decltype(map_perm_t)>;
    bool perm_map_included = map_perm_t.has_value();
    if(!map_perm_t.has_value()){
      map_perm_tt = std::make_shared<std::unordered_map<std::string_view, uint8_t>>();
    }
    /*
    * parse through directory files and check perms
    */
    uint8_t flags = 0;
    auto dir_it = std::filesystem::directory_iterator(valid_path);
    for(const auto file_entry : dir_it){
      for(const auto& perm_entry : perm_to_flag){
        if(!perm_map_included){
          struct stat file_perm;
          int result = stat(file_entry.path().c_str(), &file_perm);
          //Continue here
          if(!result){
            if(file_perm.st_mode & file_perm.first){
              
            }
          }
        }
      }
    }
  }
}
  

typedef struct Logging{
  
Logging;
