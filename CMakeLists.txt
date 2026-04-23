cmake_minimum_required(VERSION 4.1)
project(diffkit LANGUAGES C CXX OBJCXX VERSION 1.0)

set(CMAKE_WARN_DEPRECATED OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_SUPPRESS_DEVELOPER_WARNINGS ON)

set(CMAKE_BUILD_TYPE Release)
set(CPM_DOWNLOAD_VERSION 0.42.0)

set(CMAKE_CXX_SCAN_FOR_MODULES OFF)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CPM_SOURCE_CACHE "${CMAKE_SOURCE_DIR}/.cpm")
file(MAKE_DIRECTORY ${CPM_SOURCE_CACHE})

if(NOT EXISTS "${CMAKE_BINARY_DIR}/cmake/CPM.cmake")
  file(DOWNLOAD
    https://github.com/cpm-cmake/CPM.cmake/releases/download/v${CPM_DOWNLOAD_VERSION}/CPM.cmake
    "${CMAKE_BINARY_DIR}/cmake/CPM.cmake"
  )
endif()
include(${CMAKE_BINARY_DIR}/cmake/CPM.cmake)

CPMAddPackage(
  NAME saucer
  VERSION 8.0.5
  GIT_REPOSITORY "https://github.com/saucer/saucer"
)

set(APP_NAME "DiffKit")
set(MACOSX_BUNDLE_ICON_FILE include/icon.icns)
set(APP_ICON "${CMAKE_SOURCE_DIR}/include/icon.icns")
set_source_files_properties(${APP_ICON} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")

file(GLOB_RECURSE SOURCES "src/*.cc" "src/*.c")
add_executable(${PROJECT_NAME} MACOSX_BUNDLE ${SOURCES} ${APP_ICON})

if(APPLE)
  file(GLOB PLATFORM_SOURCES "src/lib/*.mm")
else()
  file(GLOB PLATFORM_SOURCES "src/lib/*.cc")
endif()

target_sources(${PROJECT_NAME} PRIVATE ${PLATFORM_SOURCES})
target_include_directories(${PROJECT_NAME} PRIVATE "include")

file(READ "${CMAKE_SOURCE_DIR}/src/scripts/inject.js" INJECT_JS)
configure_file("${CMAKE_SOURCE_DIR}/include/scripts.h.in" "${CMAKE_BINARY_DIR}/generated/scripts.h" @ONLY)
target_include_directories(${PROJECT_NAME} PRIVATE "${CMAKE_BINARY_DIR}/generated")

target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_23)
target_compile_options(${PROJECT_NAME} PRIVATE
  $<$<PLATFORM_ID:Darwin>:-Wno-deprecated-declarations>
  $<$<PLATFORM_ID:Darwin>:-Wno-deprecated-enum-enum-conversion>
  $<$<PLATFORM_ID:Darwin>:-Wno-deprecated-anon-enum-enum-conversion>
)

set_target_properties(${PROJECT_NAME} PROPERTIES
  CXX_STANDARD 23
  CXX_EXTENSIONS OFF
  CXX_STANDARD_REQUIRED ON
  MACOSX_BUNDLE TRUE
  MACOSX_BUNDLE_BUNDLE_NAME "${APP_NAME}"
  MACOSX_BUNDLE_GUI_IDENTIFIER "com.diffkit.app"
  MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_VERSION}"
  MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}"
  MACOSX_BUNDLE_ICON_FILE "icon.icns"
  MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/Info.plist.in"
  OUTPUT_NAME "${APP_NAME}"
)

target_link_libraries(${PROJECT_NAME} PRIVATE saucer::saucer saucer::private)
