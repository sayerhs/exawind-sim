# -*- coding: utf-8 -*-

import pytest
from exwsim.amrex import amrex

@pytest.fixture(autouse=True, scope='session')
def amrex_init():
    amrex.AMReX.initialize(args=["amrex.verbose=-1"])
    yield
    amrex.AMReX.finalize()
