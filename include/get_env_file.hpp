#include <cstdlib> 
#include <string>
#include <stdio.h>
#include <fstream> 
#include <iostream>
#include <regex>
#include <unordered_map>
#include <memory>

const char* env_file = "../.env";

bool is_valid_env(const char* env_file){
  FILE *fd = fopen(env_file, "r");
  if(!fd ){
    std::cerr << "File path not valid: " << env_file;
    return false;
  }
  else{
    return true;
  }
}

std::string get_env_value( std::string value){
  if(!is_valid_env(env_file)){
    return "";
  }
  struct ValueRegex{
    std::regex clientid{"CLIENT_ID=([^\\s]+)"};
    std::regex client_secret_id{"CLIENT_SECRET=([^\\s]+)"};
    std::regex token{"TOKEN=([^\\s]+)"};
  };

  ValueRegex valueregex;
  
  std::smatch match;
  std::ifstream file(env_file);
  std::unordered_map<std::string, std::string> env_values = {
      {"CLIENT_ID", "Placeholder"},
      {"CLIENT_SECRET_ID", "Placeholder"},
      {"TOKEN", "Placeholder"},
  };
  std::string line;
  //Improve this, not following DRY
  while(std::getline(file, line)){
    if(std::regex_match(line, match, valueregex.clientid)){
      env_values["CLIENT_ID"] = match[1];
    }
    else if(std::regex_match(line, match, valueregex.client_secret_id)){
      env_values["CLIENT_SECRET_ID"] = match[1];
    }
    else if(std::regex_match(line, match, valueregex.token)){
      env_values["TOKEN"] = match[1];
    }
  }
  return env_values[value];
}
