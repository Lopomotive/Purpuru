/** 
* @brief header file for type casting
*/

#include <cstdint>
#include <experimental/filesystem>
#include <memory> //unique_ptr
#include <variant> //variant
#include <limits>
#include <string>
#include <type_traits>

/**
* @note type convertion may be rewriten depending on situation
*/

/** @note handles double refrence cases */
template <typename T = int, typename = std::enable_if<std::is_integral<std::decay_t<T>>::value>>
constexpr auto intToString(T &&value) -> std::string&{
  return std::to_string(std::forward<T>(std::remove_reference<T>::type::value));
}

/** @note handles normal type cases */

template <typename T = int, typename = std::enable_if<std::is_integral<std::decay_t<T>>::value>>
constexpr auto intToString(T value) -> std::string& {
  return std::to_string(std::forward<int>(value));
}

/** @note c-string convertion might be implemented in the future for mroe case handling*/

/**
* @brief identify integer data type by size and identifier
*/
template<typename T = std::string>
constexpr auto stringToInt(T&& value) -> int{
  /** @brief use a decayed pointer to type to get type info */
  std::unique_ptr<T>
  using integer_variant = 
}

