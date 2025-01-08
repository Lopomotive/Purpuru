#define CONFIG_PARSE //DELETE
#ifdef CONFIG_PARSE

#pragma once

#include "file_core.h"

#include <any>
#include <unordered_map>
#include <string>
#include <string_view>
#include <variant>
#include <utility>
#include <memory>
#include <vector>
#include <type_traits>
#include <concepts> //concept

/**
* @brief this part is an experimental class exception handling 
* used for analyzing function return values and determining 
* wherever the value is first of a error using a try and catch
* block implementation. If it is an error the get function will be
* called inside ConfigError which will get the errors potential values
* and assign them inside error_info struct. It will then determine if the
* error is fixable or not by calling the error_crash or error_fix function
* that determines if the error can potentially be fixed or if it is fatal.
*
* @usage
* ConfigResult<return_type>(return_value)->ConfigError<return_type or wished for type>
* return ConfigError.error_crash() or return ConfigError.error_fix()
* 
* @note error_fix currently only suggest fixes to the user but does not fix them
* @note this error handling mechanism is currently only implemented for config_parse.h
* but may be implemented as a seperate standalone header in the future
* @note exception handling currently does not work as expected, fix this
*/

/**
* @brief error handling class 
* @note all values are parsed by ConfigResult, class should NOT get values on its own
*/
template <typename T, typename E = std::monostate>
class ConfigError{
private:

  /**
  * @brief struct for storing error values
  * @note values are assigned by constructor
  * @note struct may not be needed since copy constructor is probably better for ConfigError
  */
  struct error_info{
    uint8_t error_id; 
    T value;
    std::string_view error;
  };

  error_info info_;

  /**
  * @brief get function for recieving values and putting them in error_info struct
  * @note function get() called by class constructor
  */
  [[nodiscard]] void get() const;

public:

  /** @note check out these constructors and see which to keep and which to throw away*/

  /**
  * @note copy constructor may be better then constructor with parameter
  */ 
  explicit ConfigError(T value, std::string error_message);

  /**
  * @brief copy constructor
  */
  ConfigError(const ConfigError&) = default;

  /**
  * @brief move constructor
  * @note also how does && work here?
  */
  ConfigError(ConfigError&&) noexcept = default;

  /**
  * @brief copy assignment operator
  */
  ConfigError& operator=(ConfigError&) noexcept = default;
  
  /**
  * @brief function to determine if error is solveable or not
  */
  [[nodiscard]] error_info error_crash() const;
  [[nodiscard]] error_info error_fix() const;
};

/**
* @brief config result handler will catch value errors and parse to ConfigError
* @note adhere to decl_val_t
*/
template <typename T> 
class ConfigResult{
private:

  /** @note im not sure if a concept is needed */
  template <typename value>
  concept decl_val_valid = std::is_destructible<value>::value;

  /**
  * @brief value for the value given into the constructor and a type specifier if the user does not know
  */
  T value;
  using decl_val_t = decltype(std::decay_t<T>());

  mutable ConfigError<T> error_;
public:
  /**
  * @brief make copy constructable
  */
  explicit ConfigResult(const T& value_);
  ~ConfigResult() noexcept = default;
  /**
  * @brief operator to push bad value to ConfigError
  */
  [[nodiscard]] ConfigError<T>& operator->()const{return error_;}

  /**
  * @brief variable to extract declaration type from value
  */
  using value_type = decltype(value);
};

/**
* @brief change class to take in class parameter instead
*/
template <class T> 
class ConfigResult;

/**
* @brief holds possible config values 
*/
class ConfigValue{
public:
  ConfigValue() = default;
};

/**
* @brief class for loading and parsing config file
* @note ConfigLoader should be used for 
*/

/** @note using tomllib C++ to parse .toml config file */

class ConfigLoader{  
protected:
  /**
  * @brief function to load in configurations
  * @note should only be used within the constructor
  */
  [[nodiscard]] ConfigResult<ConfigValue> load_config() const;
public:
  /** 
  * @take in path and load configurations
  */
  explicit ConfigLoader(file_t path);
  ~ConfigLoader() = default;
};

/**
* @brief class to store all configurations
*/
class ConfigClass{
  class LoggingConfig;
}

#endif
