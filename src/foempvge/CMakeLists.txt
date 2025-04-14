add_executable(foempvge main.cpp)

target_link_libraries(
  foempvge
  PRIVATE Foempvge::Foempvge_options
          Foempvge::Foempvge_warnings)

target_link_system_libraries(
  foempvge
  PRIVATE
          CLI11::CLI11
          fmt::fmt
          spdlog::spdlog)

target_include_directories(foempvge PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include")
