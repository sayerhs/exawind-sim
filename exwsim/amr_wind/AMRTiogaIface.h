#ifndef AMRTIOGAIFACE_H
#define AMRTIOGAIFACE_H

#include <vector>

namespace amr_wind {
class CFDSim;
}

namespace TIOGA {
class tioga;
}

namespace exwsim {

class AMRTiogaIface
{
public:
    AMRTiogaIface(amr_wind::CFDSim&, TIOGA::tioga& tg);

    void pre_overset_conn_work();

    void post_overset_conn_work();

    void register_mesh();

    void register_solution();

    void update_solution();

private:
    amr_wind::CFDSim& m_sim;
    TIOGA::tioga& m_tg;
};

} // namespace exwsim

#endif /* AMRTIOGAIFACE_H */
