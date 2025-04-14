add_executable(foempvge main.cpp)


get_target_property(target_name foempvge NAME)
include("${CMAKE_SOURCE_DIR}/cmake/Simd.cmake")
set_simd_instructions(${target_name})

target_link_libraries(
  foempvge
  PRIVATE Foempvge::Foempvge_options
          Foempvge::Foempvge_warnings)

target_link_system_libraries(
  foempvge
  PRIVATE
          CLI11::CLI11
        foempvge_lib)

target_include_directories(foempvge PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include")
