# 1. Minimum required CMake version and project declaration
cmake_minimum_required(VERSION 3.10)
project(OpenGLProject VERSION 1.0 LANGUAGES C CXX)

# 2. C++ Standard settings
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 3. Enable compile_commands.json for Neovim (clangd)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# 4. Find system packages (Installed via RPM)
find_package(glfw3 REQUIRED)

# 5. Add local header search path (fixes 'glad/glad.h file not found')
include_directories(include)

# 6. Define executable source files (Include glad.c so GLAD gets compiled)
add_executable(${PROJECT_NAME} 
    source/main.cpp
    source/glad.c
)

# 7. Link required libraries to the target
target_link_libraries(${PROJECT_NAME} PRIVATE
    glfw
    ${CMAKE_DL_LIBS} # Dynamic loading library required by GLAD on Linux
)
