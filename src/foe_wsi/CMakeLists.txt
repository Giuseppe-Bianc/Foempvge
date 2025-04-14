include(GenerateExportHeader)


add_library(foe_wsi foe_wsi.cpp)



add_library(Foempvge::foe_wsi ALIAS foe_wsi)

# Retrieve the target name
get_target_property(target_name foe_wsi NAME)
include("${CMAKE_SOURCE_DIR}/cmake/Simd.cmake")
set_simd_instructions(${target_name})


target_link_libraries(foe_wsi
        PRIVATE
        Foempvge::Foempvge_options
        Foempvge::Foempvge_warnings
        PUBLIC
        glfw
        Foempvge::foempvge_lib_core
)

target_include_directories(foe_wsi
        ${WARNING_GUARD} PUBLIC
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>
        "${CMAKE_BINARY_DIR}/configured_files/include"
)
if (Vandior_BUILD_FUZZ_TESTS)
    target_link_libraries(foe_wsi PRIVATE -fsanitize=fuzzer-no-link)
    target_compile_options(foe_wsi PRIVATE -fsanitize=fuzzer-no-link)
endif ()

target_compile_features(foe_wsi PUBLIC cxx_std_${CMAKE_CXX_STANDARD})


set_target_properties(
        foe_wsi
        PROPERTIES VERSION ${PROJECT_VERSION}
        CXX_VISIBILITY_PRESET hidden
        VISIBILITY_INLINES_HIDDEN YES)

generate_export_header(foe_wsi EXPORT_FILE_NAME ${PROJECT_BINARY_DIR}/include/Foempvge/foe_wsi_export.hpp)

if(NOT BUILD_SHARED_LIBS)
    target_compile_definitions(foe_wsi PUBLIC SAMPLE_LIBRARY_STATIC_DEFINE)
endif()
