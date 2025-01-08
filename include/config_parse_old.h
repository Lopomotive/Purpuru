#define CONFIG_PARSE //(DELETE)
#ifdef CONFIG_PARSE

#pragma once

#include "file_core.h"

#include <iostream> //cerr
#include <any>
#include <unordered_map>
#include <string>
#include <variant>
#include <memory> 
#include <vector> 

/**
* @brief alias for handling string-like types
*/
using string_or_char_t = std::variant<std::string_view, std::string, const char*>;

/**
 * @brief Result template for error handling
 * @tparam T The success type
 * @tparam E The error type (defaults to std::string)
 */
template<typename T, typename E = std::string>
class Result {
    std::variant<T, E> data;
public:
  /**
  * @brief custom variable types to handle in result
  */  
  explicit Result(T value);
  explicit Result(E error);
  [[nodiscard]] bool is_ok() const;
  [[nodiscard]] bool is_error() const;
  [[nodiscard]] const T& value() const;
  [[nodiscard]] const E& error() const;
};

/**
 * @brief Enumeration for configuration options
 */
enum class ConfigOption {
    Username,
    UserId,
    UserProfile,
    Message,
    MessageTimestamp
};

class ConfigValue {
public:
    using variant_t = std::variant<bool, std::string, int64_t, double>;

    template<typename T>
    explicit ConfigValue(T&& val);

    template<typename T>
    [[nodiscard]] Result<T> as() const noexcept;

    template<typename T>
    [[nodiscard]] bool is() const noexcept;

private:
    variant_t value_;
};

class IConfig {
public:
    virtual ~IConfig() = default;
    
    [[nodiscard]] virtual Result<ConfigValue> 
    get(ConfigOption option) const = 0;
    
    virtual Result<void> 
    set(ConfigOption option, const ConfigValue& value) = 0;
    
    [[nodiscard]] virtual bool has(ConfigOption option) const = 0;

protected:
    IConfig() = default;
    IConfig(const IConfig&) = default;
    IConfig& operator=(const IConfig&) = default;
};


/** @note more classes for respective configuration will be added later*/

/**
* @class configuration class for storing logging
*/
class LoggingConfig final : public IConfig {
public:
    //Fix this
    explicit LoggingConfig(file_t path = "logs");
    ~LoggingConfig() override = default;

    // IConfig interface implementation
    [[nodiscard]] Result<ConfigValue> get(ConfigOption option) const override;
    Result<void> set(ConfigOption option, const ConfigValue& value) override;
    [[nodiscard]] bool has(ConfigOption option) const override;

    // Specialized getters
    [[nodiscard]] const file_t& log_path() const noexcept;
    [[nodiscard]] bool username_enabled() const noexcept;
    [[nodiscard]] bool user_id_enabled() const noexcept;
    [[nodiscard]] bool user_profile_enabled() const noexcept;
    [[nodiscard]] bool message_enabled() const noexcept;
    [[nodiscard]] bool message_timestamp_enabled() const noexcept;

private:
    struct LoggingData {
        file_t log_path;
        bool username{true};
        bool user_id{false};
        bool user_profile{false};
        bool message{true};
        bool message_timestamp{true};
    };

    LoggingData data_;
    mutable std::unordered_map<ConfigOption, ConfigValue> cache_;
};


/**
 * @brief class for loading and parsing configuration files
 * @note supports both single file and directory-based configurations
 */
class ConfigLoader {
public:
    explicit ConfigLoader(file_t path);
    ~ConfigLoader() = default;

    ConfigLoader(const ConfigLoader&) = delete;
    ConfigLoader& operator=(const ConfigLoader&) = delete;
    ConfigLoader(ConfigLoader&&) noexcept = default;
    ConfigLoader& operator=(ConfigLoader&&) noexcept = default;

    // Core functionality
    Result<void> load();
    Result<void> save() const;
    
    // Configuration access
    template<typename T>
    [[nodiscard]] Result<std::shared_ptr<T>> get_config() const;
    
    [[nodiscard]] Result<bool> has_config() const;

private:
    file_t config_path_;
    std::vector<std::unique_ptr<IConfig>> configs_;
    
    Result<void> load_single_config(const file_t& path);
    Result<void> load_directory(const folder_t& dir);
};
 
#endif
