#include <dpp/dpp.h>
#include "get_env_file.hpp"

//Delete and nullify idiom, continue working on
#ifndef MEMORY_MANAGE
  #define MEMORY_MANAGE
  template <typename T>
  void safe_delete(T*& ptr){
    delete ptr;
    ptr = nullptr;
  }
#endif

//Discord bot MACROS

class BotCreate{
private:
  //Might not need all
  std::string client_id;
  std::string client_secret_id;
  std::string token;
protected:
  dpp::cluster bot;
public:
  explicit BotCreate() :
   client_id(get_env_value("CLIENT_ID")),
   client_secret_id(get_env_value("CLIENT_SECRET_ID")),
   token(get_env_value("TOKEN")), bot(token){
     //Setup placeholder
   }
   int64_t *bot_id = nullptr;
   void BotCheck(int64_t &bot_id_ptr){ 
     
     std::cout << "Bot status: " << &bot << std::endl;
   }
}
