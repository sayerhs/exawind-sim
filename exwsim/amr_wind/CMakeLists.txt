add_amr_wind_module(amr_wind_py)

target_sources(amr_wind_py PRIVATE
  AMRTiogaIface.cpp)
target_include_directories(amr_wind_py PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR})
