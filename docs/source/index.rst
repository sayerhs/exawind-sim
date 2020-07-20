ExaWind Python Simulation Environment
=================================================================

.. only:: html

   :Version: |version|
   :Date: |today|

`ExaWind-Sim <https://github.com/sayerhs/exawind-sim>`_ provides python bindings
to the various solvers available in the `ExaWind <https://github.com/exawind>`_
simulation environment. The python bindings can be built on Linux and MacOS
platforms with Python3.

.. _installation:

Installation
-------------------

**Runtime dependencies**

- ExaWind software environment
- `Python v3.5 or higher <https://www.python.org/>`_
- `NumPy <https://numpy.org>`_
- `pySTK <https://sayerhs.github.io/pystk>`_
- `pyAMReX <https://sayerhs.github.io/pyamrex>`_

**Build time dependencies**

In addition to the runtime dependencies you will need the following packages
installed on your system to build pySTK from source

- `Cython <https://cython.org>`_
- `scikit-build <https://github.com/scikit-build/scikit-build>`_
- `CMake v3.15 or higher <https://cmake.org>`_

Optionally,  you'll also need the following for development and generating
documentation on your own machine

- `pytest <https://docs.pytest.org/en/latest>`_ for running unit tests
- `Sphinx <https://sphinx-doc.org>`_ for generating this documentation

Building from source
~~~~~~~~~~~~~~~~~~~~~

To build from source create a new Python environment (either *virtualenv* or
*conda env*). You can use the :file:`requirements.txt` in the root directory to
install dependencies via :program:`pip`. Currently, installation process
requires AMReX, AMR-Wind, Nalu-Wind, and TIOGA to be installed on your system.
We recommend using `exawind-builder <https:://exawind-builder.readthedocs.io>`_
to install the dependencies and activate the environment prior to executing the
steps described below. Once this step is complete, please execute the following
commands to configure and build the python modules

.. code-block:: bash

   # Clone the git repo
   git clone git@github.com:sayerhs/exawind-sim.git
   cd exawind-sim

   # Install dependencies
   pip install -r requirements.txt

   # Build extensions
   python setup.py install

Building a development version
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you are developing ExaWind-Sim you should install the package in *development mode*
using the following commands instead of `setup.py install`

.. code-block:: bash

   # Build extensions
   python setup.py build_ext --inplace

   # Install package in develoment mode
   pip install -e .

Once the package is installed in *editable mode* or (*development mode*), you
can execute the ``build_ext`` command after editing the Cython files and have the
latest version of the compiled extensions available within your environment.

Common build issues
~~~~~~~~~~~~~~~~~~~

If you are using `Anaconda Python <https://www.anaconda.com/>`_ (or Conda),
please make sure that you install `mpi4py
<https://mpi4py.readthedocs.io/en/stable/>`_ and `netcdf4-python
<https://unidata.github.io/netcdf4-python/netCDF4/index.html>`_ via source and
that the MPI you used to build these packages are consistent with the ones used
to build Trilinos and AMReX. Incompatibilities amongst MPI libraries used to build
Trilinos, AMReX and NetCDF4 can cause spurious memory errors and error messages
when attempting to open Exodus-II databases or executing AMR-Wind.

ExaWind API Reference
----------------------

AMR-Wind interface
~~~~~~~~~~~~~~~~~~~

.. automodule:: exwsim.amr_wind.amr_wind_py
   :members:

Nalu-Wind interface
~~~~~~~~~~~~~~~~~~~

.. automodule:: exwsim.nalu_wind.nalu_wind
   :members:

.. automodule:: exwsim.nalu_wind.time_integrator
   :members:

.. automodule:: exwsim.nalu_wind.realm
   :members:

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
