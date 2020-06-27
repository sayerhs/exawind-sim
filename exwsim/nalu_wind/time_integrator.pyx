# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

cdef class TimeIntegrator:
    """Nalu-Wind TimeIntegrator interface"""

    @staticmethod
    cdef wrap_instance(_TI* ti_in):
        cdef TimeIntegrator obj = TimeIntegrator.__new__(TimeIntegrator)
        obj.ti = ti_in
        return obj

    @property
    def time_step(TimeIntegrator self):
        """Return the timestep"""
        return self.ti.get_time_step()

    @property
    def current_time(TimeIntegrator self):
        """Return the current time"""
        return self.ti.get_current_time()

    @property
    def is_fixed_timestep(TimeIntegrator self):
        """Flag indicating whether it is fixed timestepping"""
        return self.ti.get_is_fixed_time_step()
