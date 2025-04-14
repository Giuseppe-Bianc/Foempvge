include(GenerateExportHeader)


add_library(foempvge_lib_core foempvge_lib_core.cpp)



add_library(Foempvge::foempvge_lib_core ALIAS foempvge_lib_core)

target_link_libraries(foempvge_lib_core PRIVATE Foempvge_options Foempvge_warnings)

target_include_directories(foempvge_lib_core ${WARNING_GUARD} PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>)

target_compile_features(foempvge_lib_core PUBLIC cxx_std_20)

set_target_properties(
        foempvge_lib_core
        PROPERTIES VERSION ${PROJECT_VERSION}
        CXX_VISIBILITY_PRESET hidden
        VISIBILITY_INLINES_HIDDEN YES)

generate_export_header(foempvge_lib_core EXPORT_FILE_NAME ${PROJECT_BINARY_DIR}/include/Foempvge/foempvge_lib_core_export.hpp)

if(NOT BUILD_SHARED_LIBS)
    target_compile_definitions(foempvge_lib_core PUBLIC SAMPLE_LIBRARY_STATIC_DEFINE)
endif()
