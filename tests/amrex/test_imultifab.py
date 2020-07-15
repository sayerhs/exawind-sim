# -*- coding: utf-8 -*-

import itertools
import numpy as np
import pytest
from exwsim.amrex import amrex

@pytest.fixture(params=list(itertools.product([1,3],[0,1])))
def intfab(boxarr, distmap, request):
    """MultiFab for tests"""
    num_components = request.param[0]
    num_ghost = request.param[1]
    mfab = amrex.IMultiFab.new(boxarr, distmap, num_components, num_ghost)
    mfab.set_val(0, 0, num_components, num_ghost)
    return mfab

def test_ifab(intfab):
    assert(intfab.is_cell_centered)
    assert(all(not intfab.is_nodal(i) for i in [-1, 0, 1, 2]))

    for i in range(intfab.num_comp):
        intfab.set_val(-10 * (i+1), i, 1)
    for i in range(intfab.num_comp):
        assert(intfab.max(i) == (-10 * (i + 1)))
        assert(intfab.min(i) == (-10 * (i + 1)))

    intfab.plus(20, 0, intfab.num_comp)
    for i in range(intfab.num_comp):
        np.testing.assert_allclose(intfab.max(i), 20 - (10 * (i + 1)))
        np.testing.assert_allclose(intfab.min(i), 20 - (10 * (i + 1)))

    intfab.mult(10, 0, intfab.num_comp)
    for i in range(intfab.num_comp):
        np.testing.assert_allclose(intfab.max(i), 10 * (20 - (10 * (i + 1))))
        np.testing.assert_allclose(intfab.min(i), 10 * (20 - (10 * (i + 1))))

@pytest.mark.parametrize("nghost", [0, 1])
def test_intfab_ops(boxarr, distmap, nghost):
    src = amrex.MultiFab.new(boxarr, distmap, 3, nghost)
    dst = amrex.MultiFab.new(boxarr, distmap, 1, nghost)

    src.set_val(10, 0, 1)
    src.set_val(20, 1, 1)
    src.set_val(30, 2, 1)
    dst.set_val(0.0, 0, 1)

    dst.add(src, 2, 0, 1, nghost)
    dst.subtract(src, 1, 0, 1, nghost)
    dst.multiply(src, 0, 0, 1, nghost)
    dst.divide(src, 1, 0, 1, nghost)
    np.testing.assert_allclose(dst.min(0), 5)
    np.testing.assert_allclose(dst.max(0), 5)
