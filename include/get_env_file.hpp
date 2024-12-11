#include <cstdlib> 
#include <string>
#include <stdio.h>
#include <fstream> 
#include <iostream>
#include <regex>

const char* env_file = "../.env";

bool is_valid_env(const char* env_file){
  FILE *fd = fopen(env_file, "r");
  if(!fd){
    std::cerr << "File path not valid: " << env_file;
    return false;
  }
  else return true;
}

const char* get_env_values(const char* env_file){
  if(is_valid_env(env_file)){
    const char* env_file_full_path = std::getenv(env_file);
  }
  struct ValueRegex{
    std::regex clientid{"CLIENT_ID=([^\\s]+)"};
    std::regex client_secret_id{"CLIENT_SECRET=([^\\s]+)"};
    std::regex token{"TOKEN=([^\\s]+)"};
  };
  std::smatch match;
  std::ifstream file(env_file);
}
