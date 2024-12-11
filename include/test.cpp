#include "get_env_file.hpp"

int main(){
  std::string token = get_env_value("TOKEN");
  std::cout << token;
  return 0;
}
