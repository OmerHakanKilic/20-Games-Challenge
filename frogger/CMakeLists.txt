cmake_minimum_required(VERSION 3.10)
project(Frogger VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find raylib installed on the system
find_package(raylib REQUIRED)

add_executable(Frogger source/main.cpp)

# Link the imported target provided by find_package
target_link_libraries(Frogger PRIVATE raylib)
