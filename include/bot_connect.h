/**
* @brief header file for checking and establishing connection with discord client
* @note may replace some features of bot_core.h
* @note use the openssl libary for encrypted communication
*/
#include <dpp/dpp.h>
#include "bot_core.h" //bot core utils

/**
* @note take inspiration from:
* https://github.com/brainboxdotcc/triviabot
*/

class BotConnect : core::Bot{
  private:
    /** @note add more later */
    enum class ConnectStatus{
      OK,
      CONNECTION_FAILED,
      HOST_NOT_FOUND,
      
    };
  public:
    inline virtual void StartBot();
    BotConnect(dpp::cluster* cluster);
};

class ConnectionStatus{
  dpp::cluster bot();
};

class DiscordEstablish{
  
};
