/**
* @brief header file for deducing and storing information about the client
* such as OS, Ip, etc
* @note header only file
*/
#include <memory>
#include <functional> //std::hash
#include <memory>
#include <type_traits>
#include <unordered_map>
#include <atomic>
#include <variant>

#include "../common/types.h"
#define 

/** @note function pointer should be replaced by header common/types.h
in the future */
using func_ptr = std::function<void*()>;
/**
* @brief continue developing this
*/
#define IP_DISCARD(x) //(DELETE)
#ifdef IP_DISCARD
#endif

/** @note better naming needed, should be on by default */
#define ASSESMENT(bool_type) //(DELETE)
#ifdef ASSESMENT

#endif


namespace client_info {
  /**
  * @brief class for asserting the status of other classes
  */
  template <typename T = std::monostate, class Class_obj>
  class StatusAssesment{
    private:
      
  };
  
  /**
  * @brief class containing information about id
  * @note ID class can not be used directly
  */
  template <typename Derived>
  class ID{
  private:
    uint8_t id_num;
    /** @brief atomic counter to generate unique ID's */
    static std::atomic<uint8_t> id_counter;
  public:
    /** @error check this error */
    explicit ID() : id_num(id_counter++){}
    
    /** @brief make class moveable only */
    ID(ID&&) = default;
    ID(ID&) = delete;

    ID& operator=(ID&&) noexcept = default;
    ID& operator=(const ID&) = delete;
    
    /** @brief function to fetch ID */
    [[nodiscard]] uint8_t GetId() noexcept{
      return id_num;
    }

    /** @brief derived function*/
    [[nodiscard]] Derived& returnDerived() const{
      return static_cast<Derived&>(*this);
    }

    /** @brief Enable hashing for ID */
    bool operator==(const ID& other) const noexcept {
      return id_num == other.id_num;
    }
  };

  template <typename Derived>
  std::atomic<uint8_t> ID<Derived>::id_counter = 0;

  // Specialize std::hash for ID
  // See how this code works (DELETE)
  template <typename Derived>
  struct std::hash<ID<Derived>> {
    std::size_t operator()(const ID<Derived>& id) const noexcept {
      return std::hash<uint8_t>{}(id.GetId());
    }
  };
  
  /**
  * @brief information about the current clients connected to the server
  */
  class ClientStack : ID<ClientStack>{
    private:
      std::unique_ptr<std::unordered_map<ID<ClientStack>,std::string>> stack;
    public:
      /** @brief operator overload for -> arthemetic*/

      
      ClientStack() : stack(std::make_unique<std::unordered_map<ID<ClientStack>,
                            std::string>>()){}
      
      void AddClient(const std::string& client_name){
        stack->emplace(*this, client_name);
      }

      /** @brief delete stack from memory stack */
      void DeleteStack(){
        
      }

      /** @brief why does this not work */
      void RemoveClient(const std::string& client_name) noexcept{
        stack.erase(stack.find(client_name));
      }
      
      [[nodiscard]] const stack-t> GetStack()
      const noexcept {
        return stack;
      }
  };

  class IP{      
    private:
      uint8_t address;
    public:
      /** 
      * @brief give ip from current client
      * @brief
      */
      [[nodiscard]] uint8_t GetIp() const;
    void DiscardIp();
  };

  /**
  * @brief status of client
  * @note client callback meassurements need to be added
  */
  class ClientStatus{
    private:
      enum class StatusEnum{
        Offline = 0,
        NotResponding = 1,
        Callback = 2,
        
      };
    public:
      /** @brief client callback */
      void ClientCallback(func_ptr function){
        
      }
  };
}
