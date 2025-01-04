#ifndef CONFIG_PARSE_HPP
#define CONFIG_PARSE_HPP

#include <any>
#include <unordered_map>
#include <string>
#include <iostream>
#include <fstream>
#include <sstream>
#include <variant>
#include <optional>
#include <memory>
#include <vector> // Add this include for std::vector

/**
 * @brief Alias for handling string-like types.
 */
using string_or_char_t = std::variant<std::string, std::string_view, const char*>;

/**
 * @brief Result class for catching and processing results
 */
template <typename T>
class Result {
    // Placeholder implementation for Result
};

/**
 * @brief Base class for configuration components
 */
class ConfigBase {
public:
    virtual void load_from_config(const std::unordered_map<std::string, std::string>& settings) = 0;
    virtual ~ConfigBase() = default;
};

/**
 * @brief Class for variable config_t type
 */
class config_t {
public:
    std::any value;

    config_t() = default;

    template <typename T>
    config_t(T val) : value(val) {}

    /**
     * @brief Operator to assign value to config_t
     */
    template <typename T>
    config_t& operator=(T val) {
        value = val;
        return *this;
    }

    /**
     * @brief Helper to update the value from a string
     * @note will be worked on further
     */
    void update_from_string(const std::string& str) {
        try {
            if constexpr (std::is_same_v<std::string, std::decay_t<decltype(value)>>) {
                value = str;
            } else if constexpr (std::is_same_v<int, std::decay_t<decltype(value)>>) {
                value = std::stoi(str);
            } else if constexpr (std::is_same_v<bool, std::decay_t<decltype(value)>>) {
                value = (str == "true" || str == "1");
            } else if constexpr (std::is_same_v<double, std::decay_t<decltype(value)>>) {
                value = std::stod(str);
            }
        } catch (...) {
            std::cerr << "Error parsing value: " << str << std::endl;
        }
    }

    /**
     * @brief Extract value of a specific type
     */
    template <typename T>
    T get_value() const {
        if (auto val = std::any_cast<T>(&value)) {
            return *val;
        }
        throw std::bad_any_cast();
    }
};

/**
 * @brief Logging configuration class
 */
class Logging : public ConfigBase {
private:
    config_t log_path = std::string("default");
    config_t username = true;
    config_t user_id = true;
    config_t user_profile = true;
    config_t message = true;
    config_t message_timestamp = true;

    std::unordered_map<std::string, config_t*> settings = {
        {"log-path", &log_path},
        {"username", &username},
        {"user-id", &user_id},
        {"user-profile", &user_profile},
        {"message", &message},
        {"message-timestamp", &message_timestamp}
    };

public:
    config_t get_setting(const std::string& key) const {
        for (const auto& [setting_key, setting_value] : settings) {
            if (setting_key == key) {
                return *setting_value;
            }
        }
        return config_t();
    }

    void load_from_config(const std::unordered_map<std::string, std::string>& section) override {
        for (auto& [key, value_ptr] : settings) {
            if (section.find(key) != section.end()) {
                value_ptr->update_from_string(section.at(key));
            }
        }
    }
};

/**
 * @brief Class to load configurations
 */
class LoadConfig {
private:
    std::unordered_map<std::string, std::unordered_map<std::string, std::string>> config_data;
    std::vector<std::shared_ptr<ConfigBase>> config_classes; // Correct declaration
    string_or_char_t file;

public:
    explicit LoadConfig(string_or_char_t file_) : file(std::move(file_)) {
        config_classes.emplace_back(std::make_shared<Logging>());
    }

    void load_from_file() {
        std::ifstream config_file(std::visit([](auto&& arg) -> const char* {
            if constexpr (std::is_same_v<std::decay_t<decltype(arg)>, const char*>) return arg;
            else if constexpr (std::is_same_v<std::decay_t<decltype(arg)>, std::string>) return arg.c_str();
            else if constexpr (std::is_same_v<std::decay_t<decltype(arg)>, std::string_view>) return arg.data();
        }, file));

        if (!config_file.is_open()) {
            std::cerr << "Error opening configuration file." << std::endl;
            return;
        }

        std::string line;
        std::string current_section;
        while (std::getline(config_file, line)) {
            if (line.empty() || line[0] == '#') continue;

            if (line[0] == '[') {
                current_section = line.substr(1, line.find(']') - 1);
                continue;
            }

            size_t delimiter_pos = line.find('=');
            if (delimiter_pos != std::string::npos) {
                std::string key = line.substr(0, delimiter_pos);
                std::string value = line.substr(delimiter_pos + 1);
                config_data[current_section][key] = value;
            }
        }
    }

    void load_from_config() {
        for (const auto& config_class : config_classes) {
            for (const auto& [section, settings] : config_data) {
                config_class->load_from_config(settings);
            }
        }
    }
};

std::ostream& operator<<(std::ostream& os, const config_t& cfg) {
    try {
        if (auto val = std::any_cast<std::string>(&cfg.value)) {
            os << *val;
        } else if (auto val = std::any_cast<int>(&cfg.value)) {
            os << *val;
        } else if (auto val = std::any_cast<double>(&cfg.value)) {
            os << *val;
        } else if (auto val = std::any_cast<bool>(&cfg.value)) {
            os << (*val ? "True" : "False");
        } else {
            os << "Unknown type";
        }
    } catch (...) {
        os << "Error extracting value";
    }
    return os;
}

#endif

