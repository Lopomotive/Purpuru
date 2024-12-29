/*
* @brief Rewritten version of config_parse (DELETE)
* @self First read cppfs and take inspiration
*/
#ifdef CONFIG_PARSE_HPP
#define CONFIG_PARSE_HPP

#include <regex>
#include <variant>
#include <stdexcept>
#include <variant>
#include <filesystem>
#include <unordered_map>

template <typename T>
constexpr bool defined(T& t){
  #ifdef t
  return true;
}

#if defined(LIBCONFIG)
#include <liboconfig.h++>
#endif

/**
* @brief config parsing only currently supports linux filesystem
*/
#define LINUX
#if defined(LINUX)
#include <sys/stat.h>
#endif

if defined(PERMISSION_ERRORS)
//Work on tommorow to get custom permission errors that are more specific
struct permission_errors{
  
};
#endif

template <typename T> //Delete?(DELETE)
class ParseConfig;
class Folder;
/**
* @brief 
*/
//Continue this
class FileTypes{
public:
  virtual enum filetype{
    config,
    data,
    cache,
    logging, 
    type_unknown
  };
  ~FileTypes() noexcept = default;
  ~FileTypes() noexcept = 0;
  static filetype detect_filetype(const std::string_view, filetype) = 0;
  static const inline std::unordered_map<std::string_view, filetype> extension_map = {
  {".conf", config},
  {".data", data},
  {".cache", cache},
  {".log", logging}
  };
};

constexpr std::unordered_map<uint8_t, uint8_t> perm_to_flag = {
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
/*
* @brief perm_t variable only being able to store valid permissions inside perm_to_flag
*/
//Note: Improve perm_t class tommorow, only skeleton for now(DELETE)
//Maybe use for const loop instead for better parsing?(DELETE)
class perm_t{
private:
  uint8_t value;
  
  explicit perm_t(uint8_t perm) : value(perm){
    if(perm_to_flag.find(perm) == perm_to_flag.end(perm)){
      throw(std::invalid_argument("Invalid permission value"));
    }
  }
  
  operator uint8_t() const {return value;}
  perm_t& operator=(uint8_t perm){
    if(perm_to_flag.find(perm) == perm_to_flag.end(perm)){
      throw(std::invalid_arument("Invalid ")) 
    }
  }
  value = perm;
  return *this;

  bool operator==(const perm_t& other) const {
      return value == other.value;
  }
}

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
  static std::filesystem::path convert(const std::string& sv){
    return std::filesystem::path(sv);
  }
};

template <typename T>
auto safe_path_convert(const T& value) ->
    typename std::enable_if<path_converter<T>::is_convertible, std::filesystem::path>::type {
    return path_converter<T>::convert(value);
}

/**
* @brief string_or_char_t variable to accept both types
* @note both string_or_char_t types are not needed, type overloading?(DELETE)
*/
template <typename T>
using string_or_char_t =
 typename std::enable_if<std::is_same_v<std::decay_t<T>, const char*> ||
                         std::is_same_v<std::decay_t<T>, std::string_view ||
                        std::is_same_v<std::decay_t<T>,T>::type;
 >;
 using string_or_char_t = std::variant<std::string, std::string_view, const char*>;

/**
* @breif check if variable have been initilzied or not
* works by: is_initalized_v
*/
template<typename T>
struct is_initialized {
    template<typename U = T>
    static constexpr bool value = std::is_base_of<std::monostate, U>::value && std::is_lvalue_reference<U>::value;
};

template<typename T>
inline constexpr bool is_init_v = is_initialized<T>::value;

template <typename T, typename D>
class is_same_eval{

};

/**
* @brief function to check if path/dir is valid with is_valid_path
* @param string_or_char_t variable can be both string or char
*/

//Might be able to shorten this down or add something(DELETE)
bool check_valid_path_fs(string_or_char_t path_){
  auto path = safe_convert_to_path(path_);
  if(!std::filesystem::exists(path) || !std::filesystem::is_directory(path)){
    throw(std::runtime_error("Invalid folder path:" + path.string()));
  }
  return true;
}

//Might be able to shorten this down or add something(DELETE)
bool check_valid_path_sys(string_or_char_t path){
  struct stat sb;
  if(!path.c_str(), &sb == 0 && !S_ISDIR(sb.st_mode)){
    throw(std::runtime_error("Invalid folder path:" + path.string()));
  }
  return true;
}

template <typename T>
constexpr bool is_valid_path(string_or_char_t<T> path) {
    return check_valid_path_fs(path) && check_valid_path_sys(path);
}

/*
* @brief folder class handling folder data type 
* @type file_t type 
*/
class FilesMetaData{
private:
  /**
  * @brief struct for handling metadata
  * @param folder for storing all files metadata
  */
  struct meta_data{
    std::string_view file_name;
    uint8_t perm;
  };
  string_or_char_t dir_path;
  std::shared_ptr<std::vector<meta_data>> folder = std::make_shared<std::vector<meta_data>>();
public:
  [[nodiscard]] const std::shared_ptr<std::vector<meta_data>>& getFolder() const {return folder;}
  [[nodiscard]] const perm_t getFolderPermission() const {return perm;}
  [[nodiscard]] const perm_t getFilepermission() const {return perm;}
  explicit FolderMetaData(string_or_char_t dir_path_) : dir_path(dir_path_){
    if(!is_valid_path(dir_path)){
      exit(EXIT_FAILURE); //Might change this later
    }
  }
  FolderMetaData() noexcept{
    std::runtime_error("Cannot construct without path argument");
  }
  ~FolderMetaData() noexcept = default;
protected:
  folder_meta_data& operator()(const meta_data& new_data){
    folder->push_back(new_data);
    return *this;
  }
};


perm_t check_permission()

class File : public FolderMetaData{
public:
  explicit File(const string_or_char_t& filePath)
    : FileMetaData(filePath){}
  [[nodiscard]] uint8_t getFilePermission(const std::string_view& fileName) const {
    
  }
}

template <> 
class ParseConfig{
private:
  
}

#endif
