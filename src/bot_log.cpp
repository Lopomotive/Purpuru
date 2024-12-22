#include "../include/bot_log.hpp"
#include <cstdint>

int main(int16_t argv, char* argc[]){
  std::string log_folder = get_log_directory<std::string>(); //Type need spec?
  SearcForFile(log_folder);
  return 0;
}
