# -*- coding: utf-8 -*-
# distutils: language = c++
# cython: embedsignature = True

from cython.operator cimport dereference as deref, preincrement as pinc
from libcpp.memory cimport unique_ptr
cimport numpy as np
import numpy as np

cdef class AMReX:
    """AMReX function wrappers"""

    @staticmethod
    def initialize():
        """Initialize amrex"""
        cdef int argc = 0
        cdef char** argv = NULL
        crx.Initialize(argc, argv, False)

cdef class Box:
    """Rectangular domain on an Integer Lattice

    .. code-block:: python

       # Create a Box instance
       bx = Box((0, 0, 0), (31, 31, 31))
       # Loop over the box
       for i, j, k in bx:
           print(i, j, k)
    """

    @staticmethod
    def new(tuple ilo, tuple ihi, tuple itype=None):
        """Create a new amrex::Box instance

        Args:
            ilo (tuple): Three integers defining the low corner
            ihi (tupe): Three integers defining the high corner
        """
        cdef Box self = Box.__new__(Box)
        cdef crx.IntVect lo = crx.IntVect(ilo[0], ilo[1], ilo[2])
        cdef crx.IntVect hi = crx.IntVect(ihi[0], ihi[1], ihi[2])
        cdef crx.IndexType idxtype
        if itype is None:
            self.bx = crx.Box(lo, hi)
        else:
            idxtype = crx.IndexType(itype[0], itype[1], itype[2])
            self.bx = crx.Box(lo, hi, idxtype)
        return self

    @staticmethod
    cdef wrap(crx.Box bx):
        """Wrap a C++ instance of amrex::Box"""
        cdef Box self = Box.__new__(Box)
        self.bx = bx
        return self

    def grow(Box self, int ng):
        """Grow box by given number of ghost cells"""
        return Box.wrap(self.bx.grow(ng))

    def convert(Box self, CellIndex i, CellIndex j, CellIndex k):
        """Convert a box to a given type"""
        cdef crx.IndexType ityp = crx.IndexType(i, j, k)
        return Box.wrap(self.bx.convert(ityp))

    def surrounding_nodes(Box self, int dir=-1):
        """Convert to nodal box

        If ``dir`` is less than 0 then this method does it for all three
        directions. If ``dir`` is [0, 1, 2] the box is converted to nodal only
        in that direction (i.e., a face box)
        """
        if dir < 0:
            return Box.wrap(self.bx.surroundingNodes())
        else:
            return Box.wrap(self.bx.surroundingNodes(dir))

    def enclosed_cells(Box self, int dir=-1):
        """Convert to a cell centered box

        If ``dir`` is less than 0 then this method does it for all three
        directions. If ``dir`` is [0, 1, 2] the box is converted only in that
        direction.
        """
        if dir < 0:
            return Box.wrap(self.bx.enclosedCells())
        else:
            return Box.wrap(self.bx.enclosedCells(dir))

    def __iter__(Box self):
        cdef const int* lo = self.bx.loVect()
        cdef const int* hi = self.bx.hiVect()
        cdef int i, j, k
        for k in range(lo[2], hi[2]+1):
            for j in range(lo[1], hi[1]+1):
                for i in range(lo[0], hi[0]+1):
                    yield (i, j, k)

    @property
    def num_pts(Box self):
        """Return the number of cells"""
        return self.bx.numPts()

    @property
    def volume(Box self):
        return self.bx.volume()

    @property
    def lo_vect(Box self):
        """Return the low end"""
        return np.array(<int[:crx.AMREX_SPACEDIM]>self.bx.loVect())

    @property
    def hi_vect(Box self):
        """Return the high end"""
        return np.array(<int[:crx.AMREX_SPACEDIM]>self.bx.hiVect())

    @property
    def is_empty(Box self):
        """Flag indicating whether the box is empty"""
        return self.bx.isEmpty()

    @property
    def ok(Box self):
        """Flag indicating if the box is ok"""
        return self.bx.ok()

cdef class RealBox:
    """Domain box with dimensions"""

    @staticmethod
    def new(tuple xlo, tuple xhi):
        """Create a new C++ amrex::RealBox instance

        Args:
            xlo (tuple): Coordinates of the lower corner
            xhi (tuple): Coordinates of the upper corner
        """
        cdef RealBox self = RealBox.__new__(RealBox)
        self.rbx = crx.RealBox(xlo[0], xlo[1], xlo[2],
                               xhi[0], xhi[1], xhi[2])
        return self

    @staticmethod
    cdef wrap(crx.RealBox rbx):
        cdef RealBox self = RealBox.__new__(RealBox)
        self.rbx = rbx
        return self

    def length(RealBox self, int dir):
        """Return length in given direction"""
        return self.rbx.length(dir)

    @property
    def ok(RealBox self):
        return self.rbx.ok()

    @property
    def volume(RealBox self):
        return self.rbx.volume()

    @property
    def lo(RealBox self):
        """Return lower corner coordinates as a NumPy array"""
        return np.array(<crx.Real[:crx.AMREX_SPACEDIM]>self.rbx.lo())

    @property
    def hi(RealBox self):
        """Return the upper corner coordinats as a NumPy array"""
        return np.array(<crx.Real[:crx.AMREX_SPACEDIM]>self.rbx.hi())

cdef class Geometry:
    """Rectangular problem domain geometry"""

    def __cinit__(Geometry self):
        self.geom = NULL
        self.owner = False

    def __dealloc__(Geometry self):
        if self.owner and (self.geom is not NULL):
            del self.geom

    @staticmethod
    cdef wrap_instance(crx.Geometry* in_geom, bint owner=False):
        cdef Geometry self = Geometry()
        self.geom = in_geom
        self.owner = owner
        return self

    def period(Geometry self, int dir):
        """Periodic in given direction"""
        return self.geom.period(dir)

    def is_periodic(Geometry self, int dir):
        """Flag indicating whether domain is periodic in given direction"""
        return self.geom.isPeriodic(dir)

    @property
    def prob_domain(Geometry self):
        """Return the RealBox for problem domain"""
        return RealBox.wrap(self.geom.ProbDomain())

    @property
    def prob_lo(Geometry self):
        """Return the low end of the problem domain"""
        return np.array(<crx.Real[:crx.AMREX_SPACEDIM]>self.geom.ProbLo())

    @property
    def prob_hi(Geometry self):
        """Return the high end of the problem domain"""
        return np.array(<crx.Real[:crx.AMREX_SPACEDIM]>self.geom.ProbHi())

    @property
    def prob_size(Geometry self):
        """Return the size of the domain"""
        return self.geom.ProbSize()

    @property
    def cell_size(Geometry self):
        """Return the cell size"""
        return np.array(<crx.Real[:crx.AMREX_SPACEDIM]>self.geom.CellSize())

    @property
    def inv_cell_size(Geometry self):
        """Inverse cell size"""
        return np.array(<crx.Real[:crx.AMREX_SPACEDIM]>self.geom.InvCellSize())

    @property
    def is_all_periodic(Geometry self):
        """Flag indicating if all sides are periodic"""
        return self.geom.isAllPeriodic()

cdef class BoxArray:
    """amrex::BoxArray interface

    .. code-block:: python

       # Create a new BoxArray instance
       bx = Box.new((0,0,0), (127, 127, 127))
       ba = BoxArray.new(ba)

       # Chop up the boxes by setting max grid size
       ba.max_size(64)
    """

    def __cinit__(BoxArray self):
        self.ba = NULL
        self.owner = False

    def __dealloc__(BoxArray self):
        if self.owner and (self.ba is not NULL):
            del self.ba

    @staticmethod
    def new(Box bx):
        cdef BoxArray self = BoxArray()
        self.ba = new crx.BoxArray(bx.bx)
        self.owner = True
        return self

    @staticmethod
    cdef wrap_instance(crx.BoxArray* ba, bint owner=False):
        cdef BoxArray self = BoxArray.__new__(BoxArray)
        self.ba = ba
        self.owner = owner
        return self

    def clear(BoxArray self):
        """Clear the box array"""
        self.ba.clear()

    def resize(BoxArray self, crx.Long blen):
        self.ba.resize(blen)

    def max_size(BoxArray self, int block_size):
        """Set the max grid size and chop up the BoxArray"""
        return BoxArray.wrap_instance(&self.ba.maxSize(block_size))

    def grow(BoxArray self, int n):
        """Grow all boxes by given number of ghost cells"""
        return BoxArray.wrap_instance(&self.ba.grow(n))

    def surrounding_nodes(BoxArray self, int dir=-1):
        """Return a nodal box array"""
        if dir < 0:
            return BoxArray.wrap_instance(&self.ba.surroundingNodes())
        else:
            return BoxArray.wrap_instance(&self.ba.surroundingNodes(dir))

    def enclosed_cells(BoxArray self, int dir=-1):
        """Return a cell-centered box array"""
        if dir < 0:
            return BoxArray.wrap_instance(&self.ba.enclosedCells())
        else:
            return BoxArray.wrap_instance(&self.ba.enclosedCells(dir))

    def __len__(BoxArray self):
        return self.ba.size()

    def __getitem__(BoxArray self, int i):
        return Box.wrap(deref(self.ba)[i])

    @property
    def size(BoxArray self):
        """Number of boxes in this array"""
        return self.ba.size()

    @property
    def capacity(BoxArray self):
        return self.ba.capacity()

    @property
    def empty(BoxArray self):
        """Flag indicating if the BoxArray is empty"""
        return self.ba.empty()

    @property
    def num_pts(BoxArray self):
        return self.ba.numPts()

    @property
    def ok(BoxArray self):
        """Flag indicating if the BoxArray is initialized properly"""
        return self.ba.ok()

    @property
    def is_disjoint(BoxArray self):
        return self.ba.isDisjoint()

cdef class DistributionMapping:
    """amrex::DistributionMapping instance

    .. code-block:: python

       # Create a new BoxArray instance
       bx = Box.new((0,0,0), (127, 127, 127))
       ba = BoxArray.new(ba)

       # Chop up the boxes by setting max grid size
       ba.max_size(64)

       # Create a distribution map based on the boxarray
       dm = DistributionMapping.new(ba)
    """

    def __cinit__(DistributionMapping self):
        self.dm = NULL
        self.owner = False

    def __dealloc__(DistributionMapping self):
        if self.owner and (self.dm is not NULL):
            del self.dm

    @staticmethod
    def new(BoxArray ba, int nprocs=0):
        cdef DistributionMapping self = DistributionMapping.__new__(DistributionMapping)
        if nprocs < 1:
            self.dm = new crx.DistributionMapping(deref(ba.ba))
        else:
            self.dm = new crx.DistributionMapping(deref(ba.ba), nprocs)

        self.owner = True
        return self

    @staticmethod
    cdef wrap_instance(crx.DistributionMapping* dm, bint owner=False):
        cdef DistributionMapping self = DistributionMapping.__new__(DistributionMapping)
        self.dm = dm
        self.owner = owner
        return self

    def __len__(DistributionMapping self):
        return self.dm.size()

    def __getitem__(DistributionMapping self, int i):
        return deref(self.dm)[i]

    @property
    def processor_map(DistributionMapping self):
        result = np.empty((self.size,),dtype=np.int)
        cdef int i
        cdef np.int64_t[:] rview = result
        cdef const crx.Vector[int]* pm = &self.dm.ProcessorMap()
        for i in range(self.dm.size()):
            rview[i] = <int>deref(pm)[i]
        return result

    @property
    def size(DistributionMapping self):
        return self.dm.size()

    @property
    def capacity(DistributionMapping self):
        return self.dm.capacity()

    @property
    def empty(DistributionMapping self):
        return self.dm.empty()

cdef class MultiFab:
    """amrex::MultiFab interface

    .. code-block:: python

       # Create a new BoxArray instance
       bx = Box.new((0,0,0), (127, 127, 127))
       ba = BoxArray.new(ba)

       # Chop up the boxes by setting max grid size
       ba.max_size(64)

       # Create a distribution map based on the boxarray
       dm = DistributionMapping.new(ba)

       # Create a MultiFab instance
       num_components = 3
       num_ghost = 0
       mfab = MultiFab.new(ba, dm, num_components, num_ghost)
       # Initialize the field to [10.0, 20.0, 30.0]
       mfab.set_val(10.0, 0, 1)
       mfab.set_val(20.0, 1, 1)
       mfab.set_val(30.0, 2, 1)

       # Perform some operations
       mfab.plus(10.0, 0, 1)
       mfab.mult(2.0, 1, 1)
       mfab.plus(5.0, 2, 1)

       # Looping
       for mfi in mfab:
           bx = mfi.tilebox()
           marr = mfab.array(mfi)

           for i, j, k in bx:
               mar[i, j, k, 0] = 10.0 * i
               mar[i, j, k, 1] = 10.0 * j
               mar[i, j, k, 2] = 10.0 * k
    """

    def __cinit__(MultiFab self):
        self.mfab = NULL
        self.owner = False

    def __dealloc__(MultiFab self):
        if self.owner and (self.mfab is not NULL):
            del self.mfab

    @staticmethod
    def new(BoxArray ba, DistributionMapping dm, int ncomp, int nghost):
        cdef MultiFab self = MultiFab.__new__(MultiFab)
        self.mfab = new crx.MultiFab(deref(ba.ba), deref(dm.dm), ncomp, nghost)
        self.owner = True
        return self

    @staticmethod
    cdef wrap_instance(crx.MultiFab* mfab, bint owner=False):
        cdef MultiFab self = MultiFab.__new__(MultiFab)
        self.mfab = mfab
        self.owner = owner
        return self

    def __iter__(MultiFab self):
        cdef MFIter pymfi = MFIter.new_real(self.mfab)
        cdef crx.MFIter* mfi = pymfi.mfi

        while mfi.isValid():
            yield pymfi
            pinc(deref(mfi))

    def array(MultiFab self, MFIter mfi):
        return Array4Real.wrap_instance(self.mfab.array(deref(mfi.mfi)))

    @property
    def num_comp(MultiFab self):
        return self.mfab.nComp()

    @property
    def size(MultiFab self):
        return self.mfab.size()

    def is_cell_centered(MultiFab self):
        return self.mfab.is_cell_centered()

    def is_nodal(MultiFab self, int dir=-1):
        if dir < 0:
            return self.mfab.is_nodal()
        else:
            return self.mfab.is_nodal(dir)

    def set_val(MultiFab self, crx.Real val, int start_comp, int num_comp, int num_ghost=0):
        """Initialize field to a given value"""
        self.mfab.setVal(val, start_comp, num_comp, num_ghost)

    def min(MultiFab self, int ncomp=0, int nghost=0):
        """Return the minimum value for a given component"""
        return self.mfab.min(ncomp, nghost)

    def max(MultiFab self, int ncomp=0, int nghost=0):
        """Return the maximum value for a given component"""
        return self.mfab.max(ncomp, nghost)

    def abs(MultiFab self, int comp, int ncomp):
        """x[:, comp:comp+ncomp] = abs(x[:, comp:comp+ncomp])"""
        self.mfab.abs(comp, ncomp)

    def plus(MultiFab self, crx.Real val, int comp, int ncomp):
        """x[:, comp:comp+ncomp] += val"""
        self.mfab.plus(val, comp, ncomp)

    def mult(MultiFab self, crx.Real val, int comp, int ncomp):
        """x[:, comp:comp+ncomp] *= val"""
        self.mfab.mult(val, comp, ncomp)

    def invert(MultiFab self, crx.Real val, int comp, int ncomp):
        """x[:, comp:comp+ncomp] = (val / x[:, comp:comp+ncomp])"""
        self.mfab.invert(val, comp, ncomp)

    def set_boundary(MultiFab self, crx.Real val):
        self.mfab.setBndry(val)

    def add(MultiFab self, MultiFab src,
            int scomp=0, int dcomp=0, int ncomp=1, int nghost=0):
        """dst[:, dcomp:dcomp+ncomp] += src[:, scomp:scomp+ncomp]"""
        crx.MultiFab.Add(
            deref(self.mfab), deref(src.mfab),
            scomp, dcomp, ncomp, nghost)

    def copy(MultiFab self, MultiFab src,
            int scomp=0, int dcomp=0, int ncomp=1, int nghost=0):
        """dst[:, dcomp:dcomp+ncomp] = src[:, scomp:scomp+ncomp]"""
        crx.MultiFab.Copy(
            deref(self.mfab), deref(src.mfab),
            scomp, dcomp, ncomp, nghost)

    def swap(MultiFab self, MultiFab src,
             int scomp=0, int dcomp=0, int ncomp=1, int nghost=0):
        crx.MultiFab.Swap(
            deref(self.mfab), deref(src.mfab),
            scomp, dcomp, ncomp, nghost)

    def subtract(MultiFab self, MultiFab src,
             int scomp=0, int dcomp=0, int ncomp=1, int nghost=0):
        """dst[:, dcomp:dcomp+ncomp] -= src[:, scomp:scomp+ncomp]"""
        crx.MultiFab.Subtract(
            deref(self.mfab), deref(src.mfab),
            scomp, dcomp, ncomp, nghost)

    def multiply(MultiFab self, MultiFab src,
                 int scomp=0, int dcomp=0, int ncomp=1, int nghost=0):
        """dst[:, dcomp:dcomp+ncomp] *= src[:, scomp:scomp+ncomp]"""
        crx.MultiFab.Multiply(
            deref(self.mfab), deref(src.mfab),
            scomp, dcomp, ncomp, nghost)

    def divide(MultiFab self, MultiFab src,
                 int scomp=0, int dcomp=0, int ncomp=1, int nghost=0):
        """dst[:, dcomp:dcomp+ncomp] /= src[:, scomp:scomp+ncomp]"""
        crx.MultiFab.Divide(
            deref(self.mfab), deref(src.mfab),
            scomp, dcomp, ncomp, nghost)

    def saxpy(MultiFab self, crx.Real aval, MultiFab src,
               int scomp=0, int dcomp=0, int ncomp=1, int nghost=0):
        """dst[:, dcomp:dcomp+ncomp] += aval *src[:, scomp:scomp+ncomp]"""
        crx.MultiFab.Saxpy(
            deref(self.mfab), aval, deref(src.mfab),
            scomp, dcomp, ncomp, nghost)

    def xpay(MultiFab self, crx.Real aval, MultiFab src,
              int scomp=0, int dcomp=0, int ncomp=1, int nghost=0):
        """dst[:, dcomp:dcomp+ncomp] = src[:, scomp:scomp+ncomp] + aval * dst[:, dcomp:dcomp+ncomp]"""
        crx.MultiFab.Xpay(
            deref(self.mfab), aval, deref(src.mfab),
            scomp, dcomp, ncomp, nghost)

    def lin_comb(MultiFab self, crx.Real aval, MultiFab x, int xcomp,
                 crx.Real bval, MultiFab y, int ycomp,
                 int dcomp, int ncomp, int nghost=0):
        """dst = a * x + b * y"""
        crx.MultiFab.LinComb(deref(self.mfab),
                             aval, deref(x.mfab), xcomp,
                             bval, deref(y.mfab), ycomp,
                             dcomp, ncomp, nghost)

cdef class IMultiFab:
    """AMReX IMultiFab wrapper"""

    def __cinit__(IMultiFab self):
        self.mfab = NULL
        self.owner = False

    def __dealloc__(IMultiFab self):
        if self.owner and (self.mfab is not NULL):
            del self.mfab

    @staticmethod
    def new(BoxArray ba, DistributionMapping dm, int ncomp, int nghost):
        cdef IMultiFab self = IMultiFab.__new__(IMultiFab)
        self.mfab = new crx.iMultiFab(deref(ba.ba), deref(dm.dm), ncomp, nghost)
        self.owner = True
        return self

    @staticmethod
    cdef wrap_instance(crx.iMultiFab* mfab, bint owner=False):
        cdef IMultiFab self = IMultiFab.__new__(IMultiFab)
        self.mfab = mfab
        self.owner = owner
        return self

    def __iter__(IMultiFab self):
        cdef MFIter pymfi = MFIter.new_int(self.mfab)
        cdef crx.MFIter* mfi = pymfi.mfi

        while mfi.isValid():
            yield pymfi
            pinc(deref(mfi))

    def array(IMultiFab self, MFIter mfi):
        return Array4Int.wrap_instance(self.mfab.array(deref(mfi.mfi)))

    @property
    def num_comp(IMultiFab self):
        return self.mfab.nComp()

    @property
    def size(IMultiFab self):
        return self.mfab.size()

    def is_cell_centered(IMultiFab self):
        return self.mfab.is_cell_centered()

    def is_nodal(IMultiFab self, int dir=-1):
        if dir < 0:
            return self.mfab.is_nodal()
        else:
            return self.mfab.is_nodal(dir)

    def set_val(IMultiFab self, int val, int start_comp, int num_comp, int num_ghost=0):
        """Initialize field to a given value"""
        self.mfab.setVal(val, start_comp, num_comp, num_ghost)

    def min(IMultiFab self, int ncomp=0, int nghost=0):
        """Return the minimum value for a given component"""
        return self.mfab.min(ncomp, nghost)

    def max(IMultiFab self, int ncomp=0, int nghost=0):
        """Return the maximum value for a given component"""
        return self.mfab.max(ncomp, nghost)

    def plus(IMultiFab self, int val, int comp, int ncomp):
        self.mfab.plus(val, comp, ncomp)

    def mult(IMultiFab self, int val, int comp, int ncomp):
        self.mfab.mult(val, comp, ncomp)

    def invert(IMultiFab self, int val, int comp, int ncomp):
        self.mfab.invert(val, comp, ncomp)

    def set_boundary(IMultiFab self, int val):
        self.mfab.setBndry(val)

    def add(IMultiFab self, IMultiFab src,
            int scomp=0, int dcomp=0, int ncomp=1, int nghost=0):
        crx.iMultiFab.Add(
            deref(self.mfab), deref(src.mfab),
            scomp, dcomp, ncomp, nghost)

    def copy(IMultiFab self, IMultiFab src,
            int scomp=0, int dcomp=0, int ncomp=1, int nghost=0):
        crx.iMultiFab.Copy(
            deref(self.mfab), deref(src.mfab),
            scomp, dcomp, ncomp, nghost)

    def subtract(IMultiFab self, IMultiFab src,
             int scomp=0, int dcomp=0, int ncomp=1, int nghost=0):
        crx.iMultiFab.Subtract(
            deref(self.mfab), deref(src.mfab),
            scomp, dcomp, ncomp, nghost)

    def multiply(IMultiFab self, IMultiFab src,
                 int scomp=0, int dcomp=0, int ncomp=1, int nghost=0):
        crx.iMultiFab.Multiply(
            deref(self.mfab), deref(src.mfab),
            scomp, dcomp, ncomp, nghost)

    def divide(IMultiFab self, IMultiFab src,
                 int scomp=0, int dcomp=0, int ncomp=1, int nghost=0):
        crx.iMultiFab.Divide(
            deref(self.mfab), deref(src.mfab),
            scomp, dcomp, ncomp, nghost)

cdef class MFIter:
    """MFIter wrapper"""

    def __cinit__(MFIter self):
        self.mfi = NULL
        self.owner = False

    def __dealloc__(MFIter self):
        if self.owner and (self.mfi is not NULL):
            del self.mfi

    @staticmethod
    cdef new_real(crx.MultiFab* mfab):
        cdef MFIter self = MFIter.__new__(MFIter)
        self.mfi = new crx.MFIter(deref(mfab))
        self.owner = True
        return self

    @staticmethod
    cdef new_int(crx.iMultiFab* mfab):
        cdef MFIter self = MFIter.__new__(MFIter)
        self.mfi = new crx.MFIter(deref(mfab))
        self.owner = True
        return self

    @staticmethod
    cdef wrap_instance(crx.MFIter* mfi, bint owner=False):
        cdef MFIter self = MFIter.__new__(MFIter)
        self.mfi = mfi
        self.owner = owner
        return self

    def tilebox(MFIter self):
        return Box.wrap(self.mfi.tilebox())

    def validbox(MFIter self):
        return Box.wrap(self.mfi.validbox())

    def fabbox(MFIter self):
        return Box.wrap(self.mfi.fabbox())

    def growntilebox(MFIter self):
        return Box.wrap(self.mfi.growntilebox())

    @property
    def is_valid(MFIter self):
        return self.mfi.isValid()

    @property
    def length(MFIter self):
        return self.mfi.length()

cdef class Array4Real:

    @staticmethod
    cdef wrap_instance(crx.Array4[crx.Real] arr):
        cdef Array4Real self = Array4Real.__new__(Array4Real)
        self.arr = arr
        return self

    def __getitem__(Array4Real self, tuple key):
        cdef int i = key[0]
        cdef int j = key[1]
        cdef int k = key[2]
        cdef int n = key[3]
        return self.arr(i, j, k, n)

    def __setitem__(Array4Real self, tuple key, crx.Real val):
        cdef int i = key[0]
        cdef int j = key[1]
        cdef int k = key[2]
        cdef int n = key[3]
        cdef crx.Real* data = self.arr.ptr(i, j, k, n)
        data[0] = val

    @property
    def size(Array4Real self):
        return self.arr.size()

    @property
    def num_comp(Array4Real self):
        return self.arr.nComp()

cdef class Array4Int:

    @staticmethod
    cdef wrap_instance(crx.Array4[int] arr):
        cdef Array4Int self = Array4Int.__new__(Array4Int)
        self.arr = arr
        return self

    def __getitem__(Array4Int self, tuple key):
        cdef int i = key[0]
        cdef int j = key[1]
        cdef int k = key[2]
        cdef int n = key[3]
        return self.arr(i, j, k, n)

    def __setitem__(Array4Int self, tuple key, int val):
        cdef int i = key[0]
        cdef int j = key[1]
        cdef int k = key[2]
        cdef int n = key[3]
        cdef int* data = self.arr.ptr(i, j, k, n)
        data[0] = val

    @property
    def size(Array4Int self):
        return self.arr.size()

    @property
    def num_comp(Array4Int self):
        return self.arr.nComp()
