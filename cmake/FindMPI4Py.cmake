# Find mpi4py installation
#

set(_TMP_PY_OUT)
set(_TMP_PY_RETVAL)

exec_program("${PYTHON_EXECUTABLE}"
  ARGS "-c 'import mpi4py; print(mpi4py.__version__)'"
  OUTPUT_VARIABLE _TMP_PY_OUT
  RETURN_VALUE _TMP_PY_RETVAL)

set(MPI4PY_VERSION_FOUND FALSE)
if (_TMP_PY_RETVAL)
  set(_TMP_PY_OUT)
else()
  set(MPI4PY_VERSION_FOUND TRUE)
endif()
set(MPI4PY_VERSION "${_TMP_PY_OUT}" CACHE STRING "mpi4py version")

exec_program("${PYTHON_EXECUTABLE}"
  ARGS "-c 'import mpi4py; print(mpi4py.get_include())'"
  OUTPUT_VARIABLE _TMP_PY_OUT
  RETURN_VALUE _TMP_PY_RETVAL)

set(MPI4PY_INCLUDE_FOUND FALSE)
if (NOT _TMP_PY_RETVAL AND EXISTS "${_TMP_PY_OUT}")
  set(MPI4PY_INCLUDE_FOUND TRUE)
else()
  set(_TMP_PY_OUT)
endif()
set(MPI4PY_INCLUDE_DIR "${_TMP_PY_OUT}" CACHE PATH "mpi4py include directories")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MPI4Py DEFAULT_MSG
  MPI4PY_VERSION MPI4PY_INCLUDE_DIR
  MPI4PY_VERSION_FOUND MPI4PY_INCLUDE_FOUND)
