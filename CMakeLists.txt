cmake_minimum_required(VERSION 3.19)

project(dragoneer2
        LANGUAGES C
        VERSION 0.0.1)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

add_subdirectory(dragoneer2)
add_subdirectory(examples)
add_subdirectory(tests)