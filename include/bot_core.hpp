#include <dpp/dpp.h>
#include <optional>
#include "get_env_file.hpp"
#include "version_control.hpp"

/*https://dpp.dev/coding-standards.html*/

#ifndef MEMORY_MANAGE
  #define MEMORY_MANAGE
  template <typename T>
  void safe_delete(T*& ptr){
    delete ptr;
    ptr = nullptr;
  }
#endif

/*Discord MACROS*/
#ifndef SHARDS
#define SHARDS 20 
#endif

const char* text_limit[256];

/*https://stackoverflow.com/questions/19415845/a-better-log-macro-using-template-metaprogramming*/
#define LOG(...) LOGWRAPPER(__FILE__, __LINE__, __VA_ARGS__, __TIME__)

#ifndef NOINLINE_ATTRIBUTE
  #ifdef __ICC
    #define NOINLINE_ATTRIBUTE __attribute__(( noinline ))
  #else
    #define NOINLINE_ATTRIBUTE
  #endif // __ICC
#endif 

template <typename T> struct PartTrait {typedef T Type;};

/*Will be worked on*/
namespace user{
  PartTrait<uint64_t>::Type user_id;
  struct UserTokenDump;
  std::string *user_token = nullptr;
}

class BotCreate{
private:
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
   }
}
