# -*- coding: utf-8 -*-

import numpy as np
from exwsim.amrex import amrex

def test_amrex_base():
    """Test basic AMReX operations"""
    bx = amrex.Box.new((0, 0, 0), (127, 127, 127))
    np.testing.assert_allclose(bx.lo_vect, [0, 0, 0])
    np.testing.assert_allclose(bx.hi_vect, [127, 127, 127])
    ba = amrex.BoxArray.new(bx)
    ba.max_size(64)
    assert(ba.size == 8)
    dm = amrex.DistributionMapping.new(ba)
    assert(dm.size == 8)

    mfab = amrex.MultiFab.new(ba, dm, 1, 0)
    mfab.set_val(1.0, 0, 1)
    mfab.plus(10.0, 0, 1)
    assert(mfab.num_comp == 1)
    np.testing.assert_allclose(mfab.max(0), 11.0)
    np.testing.assert_allclose(mfab.min(0), 11.0)
    for mfi in mfab:
        bx = mfi.tilebox()
        marr = mfab.array(mfi)
        for i, j, k in bx:
            marr[i, j, k, 0] = 5.0
    np.testing.assert_allclose(mfab.max(0), 5.0)
    np.testing.assert_allclose(mfab.min(0), 5.0)
