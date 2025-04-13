include(cmake/SystemLink.cmake)
include(cmake/LibFuzzer.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)


macro(Foempvge_supports_sanitizers)
  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)
    set(SUPPORTS_UBSAN ON)
  else ()
    set(SUPPORTS_UBSAN OFF)
  endif ()

  if ((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
  else ()
    set(SUPPORTS_ASAN ON)
  endif ()
endmacro()

macro(Foempvge_setup_options)
  option(Foempvge_ENABLE_HARDENING "Enable hardening" ON)
  option(Foempvge_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    Foempvge_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    Foempvge_ENABLE_HARDENING
    OFF)

  Foempvge_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR Foempvge_PACKAGING_MAINTAINER_MODE)
    option(Foempvge_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(Foempvge_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(Foempvge_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(Foempvge_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(Foempvge_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(Foempvge_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(Foempvge_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(Foempvge_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(Foempvge_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(Foempvge_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(Foempvge_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(Foempvge_ENABLE_PCH "Enable precompiled headers" OFF)
    option(Foempvge_ENABLE_CACHE "Enable ccache" OFF)
  else()
    option(Foempvge_ENABLE_IPO "Enable IPO/LTO" ON)
    option(Foempvge_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    option(Foempvge_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(Foempvge_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(Foempvge_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(Foempvge_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(Foempvge_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(Foempvge_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(Foempvge_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(Foempvge_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    option(Foempvge_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(Foempvge_ENABLE_PCH "Enable precompiled headers" OFF)
    option(Foempvge_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if (NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      Foempvge_ENABLE_IPO
      Foempvge_WARNINGS_AS_ERRORS
      Foempvge_ENABLE_USER_LINKER
      Foempvge_ENABLE_SANITIZER_ADDRESS
      Foempvge_ENABLE_SANITIZER_LEAK
      Foempvge_ENABLE_SANITIZER_UNDEFINED
      Foempvge_ENABLE_SANITIZER_THREAD
      Foempvge_ENABLE_SANITIZER_MEMORY
      Foempvge_ENABLE_UNITY_BUILD
      Foempvge_ENABLE_CLANG_TIDY
      Foempvge_ENABLE_CPPCHECK
      Foempvge_ENABLE_COVERAGE
      Foempvge_ENABLE_PCH
      Foempvge_ENABLE_CACHE)
  endif()

  Foempvge_check_libfuzzer_support(LIBFUZZER_SUPPORTED)
  if(LIBFUZZER_SUPPORTED AND (Foempvge_ENABLE_SANITIZER_ADDRESS OR Foempvge_ENABLE_SANITIZER_THREAD OR Foempvge_ENABLE_SANITIZER_UNDEFINED))
    set(DEFAULT_FUZZER ON)
  else ()
    set(DEFAULT_FUZZER OFF)
  endif ()

  option(Foempvge_BUILD_FUZZ_TESTS "Enable fuzz testing executable" ${DEFAULT_FUZZER})

endmacro()

macro(Foempvge_global_options)
  include(cmake/Simd.cmake)
  check_all_simd_features()
  print_simd_support()

  if(Foempvge_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    Foempvge_enable_ipo()
  endif()

  Foempvge_supports_sanitizers()

  if(Foempvge_ENABLE_HARDENING AND Foempvge_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR Foempvge_ENABLE_SANITIZER_UNDEFINED
       OR Foempvge_ENABLE_SANITIZER_ADDRESS
       OR Foempvge_ENABLE_SANITIZER_THREAD
       OR Foempvge_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else ()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message("${Foempvge_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${Foempvge_ENABLE_SANITIZER_UNDEFINED}")
    Foempvge_enable_hardening(Foempvge_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(Foempvge_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(Foempvge_warnings INTERFACE)
  add_library(Foempvge_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  Foempvge_set_project_warnings(
    Foempvge_warnings
    ${Foempvge_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  if(Foempvge_ENABLE_USER_LINKER)
    include(cmake/Linker.cmake)
    Foempvge_configure_linker(Foempvge_options)
  endif()

  include(cmake/Sanitizers.cmake)
  Foempvge_enable_sanitizers(
    Foempvge_options
    ${Foempvge_ENABLE_SANITIZER_ADDRESS}
    ${Foempvge_ENABLE_SANITIZER_LEAK}
    ${Foempvge_ENABLE_SANITIZER_UNDEFINED}
    ${Foempvge_ENABLE_SANITIZER_THREAD}
    ${Foempvge_ENABLE_SANITIZER_MEMORY})

  set_target_properties(Foempvge_options PROPERTIES UNITY_BUILD ${Foempvge_ENABLE_UNITY_BUILD})

  if(Foempvge_ENABLE_PCH)
    target_precompile_headers(
      Foempvge_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(Foempvge_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    Foempvge_enable_cache()
  endif()

  include(cmake/StaticAnalyzers.cmake)
  if(Foempvge_ENABLE_CLANG_TIDY)
    Foempvge_enable_clang_tidy(Foempvge_options ${Foempvge_WARNINGS_AS_ERRORS})
  endif()

  if(Foempvge_ENABLE_CPPCHECK)
    Foempvge_enable_cppcheck(${Foempvge_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()

  if(Foempvge_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    Foempvge_enable_coverage(Foempvge_options)
  endif()

  if(Foempvge_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(Foempvge_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(Foempvge_ENABLE_HARDENING AND NOT Foempvge_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR Foempvge_ENABLE_SANITIZER_UNDEFINED
       OR Foempvge_ENABLE_SANITIZER_ADDRESS
       OR Foempvge_ENABLE_SANITIZER_THREAD
       OR Foempvge_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    Foempvge_enable_hardening(Foempvge_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

endmacro()
