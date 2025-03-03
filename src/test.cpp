#include <cstdio>

// Helper macro to convert a value to a string
#define TOSTRING(x) #x

// Define a macro to emit a compile-time warning with file and line information
#define WARNING(message) \
    _Pragma(TOSTRING(GCC warning message " [File: " __FILE__ ", Line: " TOSTRING(__LINE__) "]"))

// Example usage
WARNING("This is a compile-time warning message.");
int main(){
    return 0;
}
