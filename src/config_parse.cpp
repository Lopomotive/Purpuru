#include "../include/config_parse.hpp"
#include <iostream>

int main() {
    LoadConfig loadconfig("../config"); 
    loadconfig.load_from_file();      
    loadconfig.load_from_config();

    Logging logging;
    config_t log_path = logging.get_setting("log-path");
    std::cout << log_path << std::endl;
    return 0;
}
