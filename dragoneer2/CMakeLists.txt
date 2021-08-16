add_library(dragoneer2 INTERFACE include/dragoneer2.h)

include(cmake/OOP.cmake)

target_include_directories(dragoneer2 INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/include)