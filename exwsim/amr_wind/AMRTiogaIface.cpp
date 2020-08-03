#include <vector>

#include "AMRTiogaIface.h"
#include "amr-wind/CFDSim.H"
#include "tioga.h"

namespace exwsim {

AMRTiogaIface::AMRTiogaIface(amr_wind::CFDSim& sim, TIOGA::tioga& tg)
    : m_sim(sim), m_tg(tg)
{}

void AMRTiogaIface::register_mesh()
{
    BL_PROFILE("exwsim::AMRTiogaIface::register_mesh");
    auto& mesh = m_sim.mesh();
    const int nlevels = mesh.finestLevel() + 1;
    const int iproc = amrex::ParallelDescriptor::MyProc();
    const int nproc = amrex::ParallelDescriptor::NProcs();
    const int num_ghost = m_sim.pde_manager().num_ghost_state();
    const auto* problo = mesh.Geom(0).ProbLo();

    m_ngrids_global = 0;
    m_ngrids_local = 0;
    for (int lev=0; lev < nlevels; ++lev) {
        m_ngrids_global += mesh.boxArray(lev).size();

        const auto& dmap = mesh.DistributionMap(lev);
        for (long d=0; d < dmap.size(); ++d) {
            if (dmap[d] == iproc) ++m_ngrids_local;
        }
    }

    m_ints.resize(ints_per_grid * m_ngrids_global);
    m_reals.resize(reals_per_grid * m_ngrids_global);
    std::vector<int> lgrid_id(nproc, 0);
    std::vector<std::vector<int>> gid_map(nlevels);

    int igp = 0; // Global index of the grid
    int iix = 0; // Index into the integer array
    int irx = 0; // Index into the real array

    for (int lev=0; lev < nlevels; ++lev) {
        const auto& ba = mesh.boxArray(lev);
        const auto& dm = mesh.DistributionMap(lev);
        const amrex::Real* dx = mesh.Geom(lev).CellSize();

        for (long d=0; d < dm.size(); ++d) {
            m_ints[iix++] = igp;             // Global index of this patch
            m_ints[iix++] = lev;             // Level of this patch
            m_ints[iix++] = dm[d];           // MPI rank of this patch
            m_ints[iix++] = lgrid_id[dm[d]]; // Local ID for this patch

            const auto& bx = ba[d];
            const int* lo = bx.loVect();
            const int* hi = bx.hiVect();

            for (int i = 0; i < AMREX_SPACEDIM; ++i) {
                m_ints[iix + i] = lo[i];
                m_ints[iix + AMREX_SPACEDIM + i] = hi[i];

                m_reals[irx + i] = problo[i] + lo[i] * dx[i];
                m_reals[irx + AMREX_SPACEDIM + i] = dx[i];
            }
            iix += 2 * AMREX_SPACEDIM;
            irx += 2 * AMREX_SPACEDIM;

            if (iproc == dm[d]) {
                gid_map[lev].push_back(igp);
            }

            // Increment global ID counter
            ++igp;
            // Increment local index
            ++lgrid_id[dm[d]];}
    }

    m_tg.register_amr_global_data(
        num_ghost, m_ints.data(), m_reals.data(), m_ngrids_global);
    m_tg.set_amr_patch_count(m_ngrids_local);

    // Register local patches
    int ilp = 0; // Index of local patch
    auto& ibcell = m_sim.repo().get_int_field("iblank_cell");
    auto& ibnode = m_sim.repo().get_int_field("iblank_node");
    for (int lev=0; lev < nlevels; ++lev) {
        auto& idmap = gid_map[lev];
        auto& ibfab = ibcell(lev);
        auto& ibnodefab = ibnode(lev);

        // Reset iblanks to 1 before registering with TIOGA
        ibfab.setVal(1);
        ibnodefab.setVal(1);
        int ii = 0;
        for (amrex::MFIter mfi(ibfab); mfi.isValid(); ++mfi) {
            auto& ib = ibfab[mfi];
            auto& ibn = ibnodefab[mfi];
            m_tg.register_amr_local_data(
                ilp++, idmap[ii++], ib.dataPtr(), ibn.dataPtr());
        }
    }
}

} // namespace exwsim
