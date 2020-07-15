# -*- coding: utf-8 -*-

import numpy as np
from exwsim.amrex import amrex

def test_pp():
    """Test ParmParse interface"""
    # populate data
    pp = amrex.ParmParse("test")
    pp.add("int_val", 10)
    pp.add("real_val", 20.0)
    pp.add("string_val", "my string")

    pp.add_arr("int_arr", [10, 20, 30])
    pp.add_arr("real_arr", [100.0, 200.0, 300.0])
    pp.add_arr("str_arr", "abc def ghi".split())

    vnames = """int_val real_val string_val int_arr real_arr str_arr""".split()
    for vv in vnames:
        assert(pp.query(vv))

    assert(pp.get("int_val") == "10")
    np.testing.assert_allclose(pp.get_int("int_val"), 10)
    np.testing.assert_allclose(pp.get_real("real_val"), 20.0)
    assert(pp.get("string_val") == "my string")

    np.testing.assert_allclose(
        pp.get_int("int_arr"), [10, 20, 30])
    np.testing.assert_allclose(
        pp.get_real("real_arr"), [100.0, 200.0, 300.0])

    assert(pp.query("int_val") == "10")
    np.testing.assert_allclose(pp.query_int("int_val"), 10)
    np.testing.assert_allclose(pp.query_real("real_val"), 20.0)
    assert(pp.query("string_val") == "my string")

    np.testing.assert_allclose(
        pp.query_int("int_arr"), [10, 20, 30])
    np.testing.assert_allclose(
        pp.query_real("real_arr"), [100.0, 200.0, 300.0])
