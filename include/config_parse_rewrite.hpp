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
  static std::filesystem::path convert(const std::string& sv){
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

//Might be redudant, will probably make better later(DELETE)
template <typename T, typename D>
class is_same_eval{

};
/*
*  @brief class for handling potential errors instead of simply using a try block
*/
class catch_file_system_errors{
  private:
    struct FolderResult{

    };
};

/*
* @brief Folder class da
*
*/
template <typename T>
class Folder {
private:
    std::string_view folder;
    std::vector<T> valid_files;

public:
    explicit Folder(std::string_view folder, std::vector<T> valid_files)
        : folder(folder), valid_files(valid_files) {}

    // Add methods to access folder and valid files
    [[nodiscard]] const std::string_view& getFolder() const { return folder; }
    [[nodiscard]] const std::vector<T>& getValidFiles() const { return valid_files; }
};

template <typename T>
Folder<std::string_view> get_folder(string_or_char_t<T> folder_path, uint8_t perm_t,
                 std::optional<std::shared_ptr<std::unordered_map<std::string, uint8_t>>> map_perm_t) {
    auto valid_path = safe_path_convert(folder_path);

    if (!std::filesystem::exists(valid_path)) {
      throw std::runtime_error("File not found");
    }

    std::shared_ptr<std::unordered_map<std::string, uint8_t>> map_perm_tt =
        map_perm_t.has_value() ? *map_perm_t : std::make_shared<std::unordered_map<std::string, uint8_t>>();

    const uint8_t default_permissions = S_IRUSR | S_IWUSR | S_IRGRP;
    std::vector<std::string_view> valid_config_files;

    for (const auto& file_entry : std::filesystem::directory_iterator(valid_path)) {
        uint8_t flags = 0;
        struct stat file_perm;
        int perm_valid = stat(file_entry.path().c_str(), &file_perm);

        if (!perm_valid) {
            for (const auto& [perm_flag, open_flag] : perm_to_flag) {
                if (file_perm.st_mode & perm_flag) {
                    flags |= perm_flag;
                    const auto& current_file = file_entry.path().filename().string();

                    if (!map_perm_t.has_value()) {
                        map_perm_tt->insert({current_file, flags});
                    } else {
                        auto it = map_perm_tt->find(current_file);
                        if (it == map_perm_tt->end() || it->second != flags) {
                            map_perm_tt->operator[](current_file) = default_permissions;
                            chmod(current_file.c_str(), default_permissions);
                        }
                    }

                    valid_config_files.push_back(current_file);
                }
            }
        }
    }

    return Folder<std::string_view>(valid_path.string(), valid_config_files);
}

