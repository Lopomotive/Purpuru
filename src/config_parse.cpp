#include <cstdint>
#include <stdexcept>
#include <cstdlib>
#include <cerrno>
#include <stdlib.h>
#include <string>

/**
* @brief will determine a better way to not have to
* mention ConfigErrror<T, E>::type in function
*/
using meta = std::monostate;

/**
* @brief 
*/
template<typename T, typename E>
uint8_t ConfigError<T, E>::last_error_id = 0;

/**
* @brief determine id from testing T value
* @return value from error_type
* @oops this is so painful to do so im just going to return TEMPLATE_ERROR for now
*/
template <typename T, typename E>
typename ConfigError<T, E>::error_type ConfigError<T, E>::determine_id() const{
  return ConfigError<T,E>::error_type::TEMPLATE_ERROR;
}
/**
* @brief combine error_type with the regular given id
* 
*/

template <typename T, typename E>
void ConfigError<T, E>::give_id() const{
  std::string error_id;
  /** @note check to make sure that this specific id is special in the class */
  if(this->last_error_id != ConfigError::last_error_id){
    /** @note will be replaced by intToString */
    error_id = std::to_string(last_error_id + determine_id());
  }
  else{
    /** @note will be replaced by stringToInt */
    error_id = std::to_string(++last_error_id + determine_id());
  }
  uint8_t current_id = std::atoi(error_id.c_str());
  info_.error_id = current_id;
  
  ConfigError::last_error_id = current_id;
}

/**
* @oops should be a way to determine typename ConfigError<T, E>::type so it dosent have to be
* declared like that, using meta is placeholder for this
*/
template <typename T, typename E>
uint8_t ConfigError<T, E>::get_id() const{
  return info_.error_id;
}


/**
* @brief constructor to populate error_info struct
*/

template<typename T, typename E>
ConfigError<T, E>::ConfigError(T value, std::string_view error_message) :
  info_{determine_id(), get_id(), std::move(value), std::move(error_message)} {
    give_id();
    printf("Error: Assigning appropirate id: %hhu", get_id());
  }

/**
* @oops is not implemented yet
*/
template<typename T, typename E>
typename ConfigError<T, E>::error_info ConfigError<T, E>::error_crash() const{
  
}

/**
* @oops is not implemented yet
*/
template <typename T, typename E>
typename ConfigError<T, E>::error_info ConfigError<T, E>::error_fix() const{
  
}

template <typename T>
ConfigResult<T>::ConfigResult(const T& value_) : value(value_), error_(value_, "") {}

ConfigLoader::ConfigLoader(file_t path) : config_path_t(std::move(path)) {
  static_config_path_t = config_path_t;
}

/** @note if this works it works */
ConfigResult<ConfigValue> ConfigLoader::load_config() const {
    try {
        toml::table tbl = toml::parse_file(config_path_t);
        return ConfigResult<ConfigValue>(ConfigValue(tbl));
    }
    catch (const std::exception& e) {
        return ConfigResult<ConfigValue>(ConfigValue(e.what()));
    }
}
ConfigResult<ConfigValue> ConfigClass::LoggingConfig::load_config() const {
    toml::table tbl = toml::parse_file(static_config_path_t);
    auto logging = tbl["Logging"];

    if (!logging.is_table()) {
        throw std::runtime_error("Logging section is missing or invalid.");
    }

    for (auto& [name, value] : config_options) {
        const auto& toml_value = logging[name];
        if (!toml_value) {
            continue;
        }

        std::visit([&toml_value](auto&& arg) {
            using T = std::decay_t<decltype(arg)>;  // Deduce the type
            if constexpr (std::is_same_v<T, file_t*>) {
                if (toml_value.is_string()) {
                    *arg = toml_value.as_string()->get();
                }
            } else if constexpr (std::is_same_v<T, bool*>) {
                if (toml_value.is_boolean()) {
                    *arg = toml_value.as_boolean()->get();
                }
            } else {
            }
        }, value);
    }

    return ConfigResult<ConfigValue>(ConfigValue(config_options));  // Return the result with config options
}
