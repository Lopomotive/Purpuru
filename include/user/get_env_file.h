#define GET_ENV_FILE //(DELETE)
#ifdef GET_ENV_FILE
#pragma once

#include <string>
#include <regex>
#include <unordered_map>

#include "file_core.hpp"

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
  ReadEnv(file_t file_);
  ReadEnv(string_or_char_t file);

  /**
  * @brief get env value frome env file 
  */
  void get_env_vales() const;
  [[nodiscard]] std::string get_client_id() const{return client_id;}
  [[nodiscard]] std::string get_client_secret() const{return client_id;}
  [[nodiscard]] std::string get_token() const{return token;}

  ~ReadEnv() = default;
};

#endif
