/**
* @brief this header file may or may not be needed
* and will basically only be a more advanced alias for #if defined()
*/
#include <type_traits>
#include <variant>

//----------------

/** @note develop further if needed here */
template <typename T = std::monostate>
#define DEFINED(T)

//-----------------
