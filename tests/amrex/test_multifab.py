# -*- coding: utf-8 -*-

import itertools
import numpy as np
import pytest
from exwsim.amrex import amrex

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

@pytest.fixture(params=list(itertools.product([1,3],[0,1])))
def mfab(boxarr, distmap, request):
    """MultiFab for tests"""
    num_components = request.param[0]
    num_ghost = request.param[1]
    mfab = amrex.MultiFab.new(boxarr, distmap, num_components, num_ghost)
    mfab.set_val(0.0, 0, num_components)
    return mfab

def test_mfab_simple(mfab):
    assert(mfab.is_cell_centered)
    assert(all(not mfab.is_nodal(i) for i in [-1, 0, 1, 2]))

    for i in range(mfab.num_comp):
        mfab.set_val(-10 * (i + 1), i, 1)
    mfab.abs(0, mfab.num_comp)
    for i in range(mfab.num_comp):
        assert(mfab.max(i) == (10 * (i + 1)))
        assert(mfab.min(i) == (10 * (i + 1)))

    mfab.plus(20.0, 0, mfab.num_comp)
    for i in range(mfab.num_comp):
        np.testing.assert_allclose(mfab.max(i), 20.0 + (10 * (i + 1)))
        np.testing.assert_allclose(mfab.min(i), 20.0 + (10 * (i + 1)))

    mfab.mult(10.0, 0, mfab.num_comp)
    for i in range(mfab.num_comp):
        np.testing.assert_allclose(mfab.max(i), 10.0 * (20.0 + (10 * (i + 1))))
        np.testing.assert_allclose(mfab.min(i), 10.0 * (20.0 + (10 * (i + 1))))
    mfab.invert(10.0, 0, mfab.num_comp)
    for i in range(mfab.num_comp):
        np.testing.assert_allclose(mfab.max(i), 1.0 / (20.0 + (10 * (i + 1))))
        np.testing.assert_allclose(mfab.min(i), 1.0 / (20.0 + (10 * (i + 1))))

@pytest.mark.parametrize("nghost", [0, 1])
def test_mfab_ops(boxarr, distmap, nghost):
    src = amrex.MultiFab.new(boxarr, distmap, 3, nghost)
    dst = amrex.MultiFab.new(boxarr, distmap, 1, nghost)

    src.set_val(10.0, 0, 1)
    src.set_val(20.0, 1, 1)
    src.set_val(30.0, 2, 1)
    dst.set_val(0.0, 0, 1)

    dst.add(src, 2, 0, 1, nghost)
    dst.subtract(src, 1, 0, 1, nghost)
    dst.multiply(src, 0, 0, 1, nghost)
    dst.divide(src, 1, 0, 1, nghost)
    np.testing.assert_allclose(dst.min(0), 5.0)
    np.testing.assert_allclose(dst.max(0), 5.0)

    dst.xpay(2.0, src, 0, 0, 1, nghost)
    dst.saxpy(2.0, src, 1, 0, 1, nghost)
    np.testing.assert_allclose(dst.min(0), 60.0)
    np.testing.assert_allclose(dst.max(0), 60.0)

    dst.lin_comb(6.0, src, 1,
                 1.0, src, 2, 0, 1, nghost)
    np.testing.assert_allclose(dst.min(0), 150.0)
    np.testing.assert_allclose(dst.max(0), 150.0)
