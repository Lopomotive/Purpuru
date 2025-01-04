#include "../include/get_env_file.hpp"
#define GET_ENV_FILE

int main(){
  file_t env_file = "/..env";
  ReadEnv readenv(env_file);
  readenv.get_env_values();
  return 0;
}
