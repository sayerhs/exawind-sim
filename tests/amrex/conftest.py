# -*- coding: utf-8 -*-

import pytest
from exwsim.amrex import amrex

@pytest.fixture(autouse=True, scope='session')
def amrex_init():
    amrex.AMReX.initialize(args=["amrex.verbose=-1"])
    yield
    amrex.AMReX.finalize()

@pytest.fixture(scope='module')
def boxarr():
    """BoxArray for MultiFab creation"""
    bx = amrex.Box.new((0, 0, 0), (63, 63, 63))
    ba = amrex.BoxArray.new(bx)
    ba.max_size(32)
    return ba

@pytest.fixture(scope='module')
def distmap(boxarr):
    """DistributionMapping for MultiFab creation"""
    dm = amrex.DistributionMapping.new(boxarr)
    return dm
