cmake_minimum_required(VERSION 3.19)
project(DynamicFormQML LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 添加MSVC编译器标志
if(MSVC)
    add_compile_options(/Zc:__cplusplus)
endif()

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Widgets Quick Qml QuickControls2 QuickWidgets)

qt_standard_project_setup()

qt_add_executable(DynamicFormQML
    main.cpp
    mainwindow.h
    mainwindow.cpp
    mainwindow.ui
)

# 添加资源
qt_add_resources(RESOURCES resources.qrc)
target_sources(DynamicFormQML PRIVATE ${RESOURCES})

target_link_libraries(DynamicFormQML
    PRIVATE Qt6::Core Qt6::Widgets Qt6::Quick Qt6::Qml Qt6::QuickControls2 Qt6::QuickWidgets
)

# 可选：不生成独立控制台窗口
set_target_properties(DynamicFormQML PROPERTIES WIN32_EXECUTABLE OFF)
