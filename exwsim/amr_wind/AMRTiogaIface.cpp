#include <vector>

#include "AMRTiogaIface.h"
#include "amr-wind/CFDSim.H"
#include "amr-wind/overset/TiogaInterface.H"
#include "tioga.h"

namespace exwsim {

AMRTiogaIface::AMRTiogaIface(amr_wind::CFDSim& sim, TIOGA::tioga& tg)
    : m_sim(sim), m_tg(tg)
{}

void AMRTiogaIface::pre_overset_conn_work()
{
    m_sim.overset_manager()->pre_overset_conn_work();
    register_mesh();
}

void AMRTiogaIface::post_overset_conn_work()
{
    m_sim.overset_manager()->post_overset_conn_work();
}

void AMRTiogaIface::register_mesh()
{
    BL_PROFILE("exwsim::AMRTiogaIface::register_mesh");
    auto& mesh = m_sim.mesh();
    const int nlevels = mesh.finestLevel() + 1;
    const int num_ghost = m_sim.pde_manager().num_ghost_state();
    const auto* problo = mesh.Geom(0).ProbLo();

    auto* amr_tg_iface = dynamic_cast<amr_wind::TiogaInterface*>(
        m_sim.overset_manager());
    auto& oinfo = amr_tg_iface->amr_mesh_info();

    m_tg.register_amr_global_data(
        num_ghost, oinfo.int_data.data(), oinfo.real_data.data(), oinfo.ngrids_global);
    m_tg.set_amr_patch_count(oinfo.ngrids_local);

    // Register local patches
    int ilp = 0; // Index of local patch
    auto& ibcell = m_sim.repo().get_int_field("iblank_cell");
    auto& ibnode = m_sim.repo().get_int_field("iblank_node");
    for (int lev=0; lev < nlevels; ++lev) {
        auto& idmap = oinfo.gid_map[lev];
        auto& ibfab = ibcell(lev);
        auto& ibnodefab = ibnode(lev);

        int ii = 0;
        for (amrex::MFIter mfi(ibfab); mfi.isValid(); ++mfi) {
            auto& ib = ibfab[mfi];
            auto& ibn = ibnodefab[mfi];
            m_tg.register_amr_local_data(
                ilp++, idmap[ii++], ib.dataPtr(), ibn.dataPtr());
        }
    }
}

void AMRTiogaIface::register_solution()
{
    int ip_cell = 0;
    int ip_node = 0;

    const int ncell_vars = 3;
    const int nnode_vars = 1;
    auto& repo = m_sim.repo();
    auto& velocity = repo.get_field("velocity");
    auto& pressure = repo.get_field("p");

    // Ensure that ghost cells are consistent
    AMREX_ALWAYS_ASSERT(velocity.num_grow()[0] == pressure.num_grow()[0]);

    const int nlevels = m_sim.mesh().finestLevel() + 1;
    for (int lev = 0; lev < nlevels; ++lev) {
        auto& vel = velocity(lev);
        auto& pres = pressure(lev);

        for (amrex::MFIter mfi(vel); mfi.isValid(); ++mfi) {
            auto& varr = vel[mfi];
            m_tg.register_amr_solution(ip_cell++, varr.dataPtr(), ncell_vars, 0);

            auto& parr = pres[mfi];
            m_tg.register_amr_solution(ip_node++, parr.dataPtr(), 0, nnode_vars);
        }
    }
}

} // namespace exwsim
