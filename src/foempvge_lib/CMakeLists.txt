include(GenerateExportHeader)


add_library(foempvge_lib foempvge_lib.cpp)



add_library(Foempvge::foempvge_lib ALIAS foempvge_lib)

target_link_libraries(foempvge_lib PRIVATE Foempvge_options Foempvge_warnings)

target_include_directories(foempvge_lib ${WARNING_GUARD} PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
                                                                  $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>)

target_compile_features(foempvge_lib PUBLIC cxx_std_20)

set_target_properties(
  foempvge_lib
  PROPERTIES VERSION ${PROJECT_VERSION}
             CXX_VISIBILITY_PRESET hidden
             VISIBILITY_INLINES_HIDDEN YES)

generate_export_header(foempvge_lib EXPORT_FILE_NAME ${PROJECT_BINARY_DIR}/include/Foempvge/foempvge_lib_export.hpp)

if(NOT BUILD_SHARED_LIBS)
  target_compile_definitions(foempvge_lib PUBLIC SAMPLE_LIBRARY_STATIC_DEFINE)
endif()
