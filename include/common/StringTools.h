/** 
* @brief header file for type casting
* @note header file not finnished
*/

#include <cstdint>
#include <cstdlib>
#include <optional>
#include <experimental/filesystem>
#include <memory> //unique_ptr
#include <random>
#include <variant> //variant
#include <limits>
#include <string>
#include <type_traits>
#include <concepts>
#include <bitset>
#include <bit> //bit_cast
#include <queue>

/**
* @note type convertion may be rewriten depending on situation
*/

/**
* @brief class for representing and handling integer types to help with bitwise truncation
*/
template <typename T>
class integers{
  private:
    using max_size = typename std::conditional<
    std::is_signed<std::decay_t<T>>::value,
    std::intmax_t,
    std::uintmax_t
    >::type;

    using types = typename std::variant<
    uint8_t,
    uint16_t,
    uint32_t,
    uint64_t,
    int8_t,
    int16_t,
    int32_t,
    int64_t
    >;
    /**
    * @brief extract the biggest possible number from types
    * @note only uint32_t for now
    */
    constexpr static size_t max_bit_size = sizeof(uint32_t) * 8;
    
    using bits = std::bitset<max_bit_size>;

    /**
    * @brief stores metadata of truncated bits
    */
    struct TruncatedBits{
      bits value;
      size_t orginal_size;
      size_t position;
      std::string description;
    };

    /** @note this was made by AI and therefore needs to be properly checked */
    [[nodiscard]] TruncatedBits& operator/=(const types& integer) const{
      std::visit([this](auto val, std::string comment) -> TruncatedBits{
        using ValueType = std::decay_t<decltype(val)>;
        constexpr size_t source_bits = sizeof(ValueType) * 8;
        constexpr size_t target_bits = sizeof(T)*8;

        constexpr size_t bit_diff = (source_bits > target_bits) ?
          source_bits - target_bits : 0;

        ValueType mask = ValueType((-1) << target_bits) & val;

        TruncatedBits::value = bits(mask >> target_bits);
        TruncatedBits::original_size = source_bits;
        TruncatedBits::position = target_bits;
        TruncatedBits::description = comment;
      }, integer);
      return *this->TruncatedBits;
    }
    
    /**
    * @brief stores history of truncated bits
    */
    std::queue<TruncatedBits> bit_history;

    /**
    * @brief stores the last full value that was NOT truncated
    */
    std::optional<std::uintmax_t> last_full_value;

    public:

    [[nodiscard]] TruncatedBits createTruncated(const types& integer) {
      TruncatedBits result{};
      result /= integer;
      bit_history.push(result);
      std::visit([this](auto val) {
          last_full_value = val;
      }, integer);
      return result;
    }
    
    /** @brief different truncation recovery methods */
    
    /**
    * @brief return the truncated value in bits
    */
    [[nodiscard]] bits getTruncVal() const{
      return TruncatedBits::value;
    }

    /**
    * @brief get the truncated and original value and force create a type
    * @note not recommended
    * @note not yet implemented
    */
    [[nodiscard]] T returnType() const{
      
    }
 };

/** @note handles double refrence cases */
template <typename T = int, typename = std::enable_if<std::is_integral<std::decay_t<T>>::value>>
constexpr auto intToString(T &&value) -> std::string&{
  /** @note truncation check here*/
  using DecayT = std::decay_t<T>;
  integers<DecayT> handler;

  auto variant_value = integers<DecayT>::type;
  auto truncated = handler.createTruncated(variant_value);

  /**
  * @brief handle truncated bits
  * @note not yet fully implemented
  */
  if constexpr(truncated > 0){
    /** @note template runtime error for now */
    std::runtime_error("Truncation occured!!!");
  }

  /** @return value if no truncation */
  return std::atoi(std::forward<T>(std::remove_reference<T>::type::value));
}


/** @note handles normal type cases */
template <typename T = int, typename = std::enable_if<std::is_integral<std::decay_t<T>>::value>>
constexpr auto intToString(T value) -> std::string&{
  return std::to_string(std::forward<int>(value));
}

/** @note c-string convertion might be implemented in the future for mroe case handling*/

/**
* @brief class for handling truncation between string to integer
* @note truncation has a higher likelyhood of happening in this order
*/
class strings{
  private:
    
};

/**
* @brief identify integer data type by size and identifier
* @note does not currently handle
*/
template<typename T = std::string>
constexpr auto stringToInt(T&& value) -> int{
  return std::stoi(std::forward<T>(std::remove_reference<T>::type::value));
}

