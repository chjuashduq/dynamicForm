cmake_minimum_required(VERSION 3.19)
project(DynamicFormQML LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Widgets Quick Qml QuickControls2 QuickWidgets Sql)
# [新增] 1. 查找 Felgo Hot Reload 模块
find_package(FelgoHotReload REQUIRED)
qt_standard_project_setup()

qt_add_executable(DynamicFormQML
    main.cpp
    mainwindow.h
    mainwindow.cpp
    mainwindow.ui
    mysql/MySqlConnectionManager/MySqlConnectionManager.h
    mysql/MySqlHelper/MySqlHelper.h
    mysql/MySqlConnectionManager/MySqlConnectionManager.cpp
    mysql/MySqlHelper/MySqlHelper.cpp
    utils/FileHelper.h
    utils/FileHelper.cpp
    generator/CodeGenerator.h
    generator/CodeGenerator.cpp
)

# 添加 include 路径，让 #include "MySqlHelper.h" 可以找到
target_include_directories(DynamicFormQML PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}       # 项目根目录
    ${CMAKE_CURRENT_SOURCE_DIR}/mysql/MySqlConnectionManager
    ${CMAKE_CURRENT_SOURCE_DIR}/mysql/MySqlHelper
)

# 设置构建类型为 Debug
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose the type of build." FORCE)
    # Set the possible values of build type for cmake-gui
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release")
endif()

# 添加资源
qt_add_resources(RESOURCES resources.qrc)
target_sources(DynamicFormQML PRIVATE ${RESOURCES})

target_link_libraries(DynamicFormQML
    PRIVATE Qt6::Core Qt6::Widgets Qt6::Quick Qt6::Qml Qt6::QuickControls2 Qt6::QuickWidgets Qt6::Sql
    PRIVATE FelgoHotReload
)
