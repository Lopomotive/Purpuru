#include <stdexcept>
#define CONFIG_PARSE //DELETE
#ifdef CONFIG_PARSE

#pragma once

/**
* @brief toml config parsing lib
*/
#include <toml++/toml.hpp>

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
* @brief class forward declaration
*/
template<typename T, typename E> class ConfigError;
template<typename T> class ConfigResult;
class ConfigValue;
class ConfigLoader;
class ConfigClass;

/** @note ConfigError might be moved to a seperate base class in the future */

/**
* @brief error handling class 
* @note all values are parsed by ConfigResult, class should NOT get values on its own
*/
template <typename T, typename E = std::monostate>
class ConfigError{
protected:
  /**
  * @brief error_type to hold possible error values
  * @note first part of error id is error enum type
  */
  enum error_type{
    GENERIC_ERROR = 1,
    POINTER_ERROR = 2,
    INVALID_INPUT = 3,
    TEMPLATE_ERORR = 4
  };

  /**
  * @brief struct for storing error values
  * @note values are assigned by constructor
  * @note struct may not be needed since copy constructor is probably better for ConfigError
  * @note error_id is dependant on error_type_id
  */
  struct error_info{
    error_type error_type_id;
    uint8_t error_id;
    T value;
    std::string_view error_message;
  };

  error_info info_;

  /** @brief variable to track last error id*/
  static uint8_t last_error_id;

  /**
  * @brief determine error_type
  */
  [[nodiscard]] error_type determine_id() const;

  /**
  * @brief assign error id for error_info struct
  */
  [[nodiscard]] ConfigError& give_id() const;

  /**
  * @brief fetch error id from error_info struct
  */
  [[nodiscard]] error_info  get_id() const;


public:
  /**
  * @note copy constructor may be better then constructor with parameter
  */ 
  explicit ConfigError(T value, std::string_view error_message);

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

  /**
  * @brief termine if it is error_crash or error_fix looking at error_info
  * @note return type might be changed
  */
  [[nodiscard]] error_info see_error() const;

  /**
  * @brief default constructor error
  * @oops might be only included in implementation file
  */
  explicit ConfigError() {
    throw std::runtime_error("Can not construct class without parameters");
    /** @note EXIT_FAILURE might not be appropirate to throw */
    exit(EXIT_FAILURE);
  }
};

/**
* @brief config result handler will catch value errors and parse to ConfigError
* @note adhere to decl_val_t
* @note other classes linked to ConfigResult may be added in the future
*/
template <typename T> 
class ConfigResult{
private:
  /**
  * @brief value for the value given into the constructor and a type specifier if the user does not know
  * @note decl_val_t might be removed in the future or changed to only decay_t<T>
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
};

/**
* @brief change class to take in class parameter instead
*/
template <class T> 
class ConfigResult;

/**
 * @brief Class to hold possible configuration values
 */
class ConfigValue {
public:
    /**
     * @brief Type alias for supported configuration value types
     */
    using config_types = std::variant<bool, std::string_view, file_t, folder_t,
                                     const char*, std::string>;
    using config_map = std::unordered_map<std::string, config_types>;
    /**
     * @brief Default constructor
     */
    ConfigValue() = default;

    /**
     * @brief Constructor taking a configuration value
     */
    template<typename T>
    explicit ConfigValue(T&& value);
    
    /**
     * @brief Copy constructor
     */
    ConfigValue(const ConfigValue&) = default;

    /**
     * @brief Move constructor
     */
    ConfigValue(ConfigValue&&) noexcept = default;

    /**
     * @brief Copy assignment operator
     */
    ConfigValue& operator=(const ConfigValue&) = default;

    /**
     * @brief Move assignment operator
     */
    ConfigValue& operator=(ConfigValue&&) noexcept = default;

    /**
     * @brief Assignment operator for config values
     */
    ConfigValue& operator=(const config_types& value) {
        value_ = value;
        return *this;
    }

    /**
     * @brief Get the stored value
     */
    [[nodiscard]] const config_types& value() const {
        return value_;
    }

    /**
    * @oops what would this be used for?
    */
    template<typename T>
    [[nodiscard]] bool is() const;
    
    template<typename T>
    [[nodiscard]] const T& as() const;

protected:
    config_types value_;
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
  file_t config_path_t;
  
  /** 
  * @take in path and load configurations
  */
  explicit ConfigLoader(file_t path);
  ~ConfigLoader() = default;

  /**
  * @brief prevent copying, allow moving
  * @oops is this needed?
  */
  ConfigLoader(const ConfigLoader&) = delete;
  ConfigLoader& operator=(const ConfigLoader&) = delete;
  ConfigLoader(ConfigLoader&&) noexcept = default;
  ConfigLoader& operator=(ConfigLoader&&) noexcept = default;
};

/**
* @brief class to store all configurations
*/
class ConfigClass : public ConfigLoader{
public:
  virtual ~ConfigClass() = default;  
  class LoggingConfig{
    public:
      /**
      * @brief specifies log path
      */
      static file_t log_path;

      /**
      * @brief set if username should be included in log, recommended setting
      */
      static bool username;
        
      /**
      * @brief set if user id should be included in log
      */
      static bool user_id;

      /**
      * @brief set if user profile picture should be included in log
      */
      static bool user_profile;

      /**
      * @brief set if message should be included in log, recommended setting
      */
      static bool message;

      /**
      * @brief set if message timestamp should be included in log
      */
      static bool message_timestamp;

      /**
      * @brief fetch configuration needed
      */
      [[nodiscard]] ConfigResult<ConfigValue::config_types&> get_value(std::string name) const;

      
      /**
      * @brief validate configurations
      * @note called in constructor by default
      */
      void config_validate() const;

    private:
      /**
      * @brief default configuration value
      * @oops may be moved to implementation file
      */
      const ConfigValue::config_map default_config = {
        {"Log-path", this->log_path},
        {"Username", this->username},
        {"User-ID", this->user_id},
        {"User-profile", this->user_profile},
        {"Message", this->message},
        {"Message-Timestamp", this->message_timestamp}
    };
    /**
    * @brief function for initilizing default values
    * @oops might not be needed
    */
    void initilize_default_config()const;
  };
};

#endif
