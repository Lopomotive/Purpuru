#include "../include/config_parse.h"

#include <cstdint>
#include <stdexcept>
#include <cerrno>

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
  return ConfigError<T,E>::error_type::TEMPLATE_ERORR; //placeholder
}
/**
* @brief combine error_type with the regular given id
* 
*/

template <typename T, typename E>
ConfigError<T, E>& ConfigError<T, E>::give_id() const{
  std::string error_id;
  /** @note check to make sure that this specific id is special in the class */
  if(last_error_id != ConfigError::last_error_id){
    error_id = itoa(this->last_error_id + determine_id());
    this->last_error_id++;
  }
  else{
    last_error_id++;
    error_id = itoa(this->last_error_id + determine_id());
  }
  uint8_t id = stoi(error_id);
  return id;
}

/**
* @oops should be a way to determine typename ConfigError<T, E>::type so it dosent have to be
* declared like that, using meta is placeholder for this
*/
template <typename T, typename E>
typename ConfigError<T, E>::error_info ConfigError<T, E>::get_id() const{
  return ConfigError::error_info::error_id;
}


/**
* @brief constructor to populate error_info struct
*/

template<typename T, typename E>
ConfigError<T, E>::ConfigError(T value, std::string_view error_message) :
  info_{determine_id(), get_id(), std::move(value), std::move(error_message)} {
    give_id();
    printf("Error: Assigning appropirate id: %s", get_id());
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

//Continue here

template <typename T>
ConfigResult<T>::ConfigResult(const T& value_) : value(value_), error_(value_, "") {}

ConfigLoader::ConfigLoader(file_t path) : config_path_t(std::move(path)) {}

/** @note needs testing */
ConfigResult<ConfigValue> ConfigClass::LoggingConfig::load_config() const{
  /** @note use static_cast to convert config_path_t to static? */
  toml::table tbl = toml::parse_file(config_path_t);

  auto logging_config_node = tbl["Logging"];
  if(!logging_config_node){
    throw std::runtime_error("Missing logging section");
  }

  for(auto& [name, value] : default_config){
    value = tbl.value<std::decay_t<value>>(name);
  }
}
