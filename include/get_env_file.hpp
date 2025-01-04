#define GET_ENV_FILE //(DELETE)
#ifdef GET_ENV_FILE

#include <string>
#include <fstream>
#include <regex>
#include <unordered_map>
#include <memory>

#define FILE_CORE
#include "file_core.hpp"

/**
* @brief macro env error handling
*/

//Maybe need to split it into more functions

class ReadEnv{
private:
  std::regex clientid{"CLIENT_ID=([^\\s]+)"};
  std::regex client_secret_id{"CLIENT_SECRET=([^\\s]+)"};
  std::regex token_reg{"TOKEN=([^\\s]+)"};
  std::smatch match;
  file_t file;
  std::string client_id;
  std::string client_secret;
  std::string token;
public:
  std::vector<std::pair<std::regex, std::string*>> keys = {
    {clientid, &client_id},
    {client_secret_id, &client_secret},
    {token_reg, &token}
  };
  ReadEnv(file_t file_)noexcept : file(file_){} 
  /**
  * @brief gets env values from env file and emplaces them in env_values map
  */
  void get_env_values(){
    std::ifstream env_file(file.path);
    std::string line;
    while(std::getline(env_file, line)){
      for(const auto& [regex, value] : keys){
        if(std::regex_search(line, match, regex) && match.size() > 1){
          *value = match[1].str();
        }
      }
    }
  }
  [[nodiscard]] std::string get_client_id() const{return client_id;}
  [[nodiscard]] std::string get_client_secret() const{return client_secret;}
  [[nodiscard]]std::string get_token()const{return token;}
  
 ~ReadEnv() = default;
};

#endif
