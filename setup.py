# -*- coding: utf-8 -*-

"""\
ExaWind Modeling and Simulation Environment
============================================
"""

import os
from pathlib import Path
from skbuild import setup

VERSION = "0.0.1"

classifiers = [
    "Development Status :: 3 -Alpha",
    "License :: OSI Approved :: Apache Software License",
    "Operating System :: POSIX",
    "Operating System :: POSIX :: Linux",
    "Operating System :: MacOS :: MacOS X",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: Implementation :: CPython",
    "Topic :: Scientific/Engineering :: Physics"
    "Topic :: Scientific/Engineering :: Visualization",
    "Topic :: Utilities",
]

dependencies = [
    "tioga",
    "trilinos",
    "nalu-wind",
    "amr-wind",
    "openfast",
]

def cmake_prefix_path():
    """Create CMake prefix path"""
    def root_dir(dname):
        """Return root dir variable"""
        key = dname.replace("-", "_").upper() + "_ROOT_DIR"
        return os.environ.get(key, None)

    paths = []
    exw_dir = os.environ.get("EXAWIND_INSTALL_DIR", None)
    for dep in dependencies:
        pth = root_dir(dep)

        if pth is not None:
            paths.append(pth)
            continue

        if (exw_dir is not None) and (Path(exw_dir) / dep).exists():
            paths.append(str(Path(exw_dir) / dep))
        else:
            print("Cannot find package: %s"%dep)

    return "-DCMAKE_PREFIX_PATH=" + ";".join(paths) if paths else ""

setup(
    name="exawind-sim",
    version=VERSION,
    url="https://github.com/sayerhs/py-exawind",
    license="Apache License, Version 2.0",
    description="ExaWind Modeling and Simulation Environment",
    long_description=__doc__,
    author="Shreyas Ananthan",
    maintainer="Shreyas Ananthan",
    platforms="any",
    classifiers=classifiers,
    include_package_data=True,
    packages=[
        'exwsim',
    ],
    cmake_args = [
        cmake_prefix_path(),
    ]
)
