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

using decl_values = std::variant<int, std::string, double, bool, const char*>;

struct Logging{
  bool username;
  bool user_id;
  bool user_profile;
  bool message;
  bool timestamp;
};

//Better use to filter through things, will probably be moved to core
template <typename T>
bool is_matching(std::regex* regex, regex_matchable_type_t<T> regex_string){  
  std::smatch match;
  if(std::regex_match(regex_string, *regex, match)){
    return true;
  }
  else{
    throw std::runtime_error("Regex invalid");
    return false;
  }
}

//Continue with function
const std::string getconfig_file(){
  //Might use regex here
  const std::filesystem::path directory_path = "../";
  for(const auto& entry :std::filesystem::directory_iterator(directory_path)){
    if(entry.is_regular_file() && entry.path().extension() == ".config"){
      std::string entry_ = entry.path().string();
      return static_cast<std::string>(entry_);
    }
    else{
      uint8_t retry_counter = 4;
      while(retry_counter){
        std::regex config_pattern(R"(.*\.config$)");
        std::smatch match;
        char config_folder[256];
        printf("%c %s Could not find file, input file:"); //Printf works
        scanf("%s",config_folder);
        std::string config_folder_str(config_folder);
        if(config_folder.is_regular_file(), && config_folder.path().extension() == ".config"){
          printf("%s Valid config file");
          return static_cast<std::string>(config_folder);
        }
      }
  }
}

bool is_valid_config_file(const char* filename){
  FILE * file  = fopen(filename, "r");
  if(!file){
    throw std::runtime_error("Invalid config file");
  }
}

//Parse into config file using libconfig
void ConfigFileRead(){
  libconfig::Config cfg;
  cfg.
}
