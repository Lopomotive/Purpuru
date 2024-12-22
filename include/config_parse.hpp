//File to read and set program configs(DELETE)
#include <libconfig.h++> //Read config filej
#include <regex>
#include <variant>
#include <filesystem>
#include <ostream>
#include <unordered_map>

using decl_values = std::variant<int, std::string, double, bool, const char*>;

struct Logging{
  bool username;
  bool user_id;
  bool user_profile;
  bool message;
  bool timestamp;
};

//Better use to filter through things, will probably be moved to core
using regex_t = //Regex variable
bool is_matching(std::regex* regex, ){
  
}

std::string getconfig_file(){
  //Might use regex here
  const std::filesystem::path directory_path = "../";
  for(const auto& entry :std::filesystem::directory_iterator(directory_path)){
    if(entry.is_regular_file() && entry.path().extension() == ".config"){
      return static_cast<std::string>entry;
    }
    else{
      uint8_t retry_counter = 4;
      while(retry_counter){
        std::regex config_pattern(R"(.*\.config$)");
        std::smatch match;
        std::string config_folder;
        printf("%c %s", "Could not find file, input file:"); //Printf works
        scanf("%s", config_folder);
        if()
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
