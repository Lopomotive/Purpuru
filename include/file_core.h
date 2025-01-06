/**
* @brief macro file for handling file operations
*/

#define FILE_CORE //(DELETE)
#ifdef FILE_CORE

/** @note header only file*/

#pragma once

#include <variant>
#include <string>
#include <memory>
#include <type_traits>
#include <filesystem>
#include <string_view> //may not need

#include <fcntl.h>
#include <unistd.h>

using string_or_char_t = std::variant<std::string_view, std::string, const char*>;

/**
* @brief file_t type to only hold valid files
* @usage file_t file = "file.conf"
*/
class file_t{
private:
  std::filesystem::path path;
  string_or_char_t file;
public:
  file_t() = default;

  explicit file_t(const string_or_char_t& file_path) noexcept{
    *this =file_path;
  }

  /**
  * @brief converts string_or_char_t custom type to path
  * @return std::filesystem::path var
  */
  inline std::filesystem::path& operator=(const string_or_char_t file_path){
    path = std::visit([](const auto& value) -> std::filesystem::path {
      return std::filesystem::path(value);
    }, file_path);
    file = file_path;
    if(std::filesystem::is_regular_file(path)){
      return path;
    }
    throw std::runtime_error("File does not exist");
  }
};

/**
* @brief folder_t type to only hold valid folder
*/
struct folder_t{
  string_or_char_t folder;
  folder_t() = default;

  explicit folder_t(const string_or_char_t folder_) noexcept : folder(folder_){}

  /**
  * @brief operator to check that folder is vali
  * @note visit functionality should probably be seperate
  */
  string_or_char_t operator=(const string_or_char_t& folder_path) {
    // Convert string_or_char_t to std::filesystem::path
    auto path = std::visit([](const auto& value) -> std::filesystem::path {
        return std::filesystem::path(value);
    }, folder_path);

    if (std::filesystem::is_directory(path)) {
        folder = folder_path; 
    } else {
        throw std::runtime_error("Directory does not exist");
    }
    return folder;
  }
};

#endif
