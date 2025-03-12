/**
* @brief header file to define and handle the core communication
* protocol between the bot and client
*/
#include "include.h"

#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/socket.h>

#define DEAFULT_BUFFSIZE 1024;

namespace cli{

  class Socket{
    public:
      //I do not think this is right, check it (DELETE)
      enum class Protocol : uint8_t { TCP, UDP };
      enum class StreamType : uint8_t { DATA, CONTROL };

      uint8_t SOCKET;
      sockaddr_in addr;

      [[nodiscard]] sockaddr_in& PrintSocketInfo() const;
      
    public:
      explicit Socket(Protocol protocol, StreamType stream_type)
        : protoc(static_cast<uint8_t>(protocol)), stream(static_cast<uint8_t>(stream_type)) {}
    private:
      uint8_t protoc;
      uint8_t stream;
  };

  //Check this part out, im tired but maybe use something different then enum classes
  class Communication{
    /**
    * @brief Supported ports and communication protocals for bot
    */
    enum class SupportedPorts{
      
    };

    enum class SupportedCommunication{
      
    };
  };

  class Host{
    public:
      enum class HOST_STATUS{
        
      };
  };
}
