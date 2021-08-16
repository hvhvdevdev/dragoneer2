add_executable(ex-pet pet.c)

target_link_libraries(ex-pet PRIVATE dragoneer2)

Enable_target_OOP(ex-pet)