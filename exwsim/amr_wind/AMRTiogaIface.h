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

    void register_mesh();

private:
    amr_wind::CFDSim& m_sim;
    TIOGA::tioga& m_tg;

    std::vector<int> m_ints;
    std::vector<double> m_reals;

    int m_ngrids_global;
    int m_ngrids_local;

    static constexpr int ints_per_grid{10};
    static constexpr int reals_per_grid{6};
};

} // namespace exwsim

#endif /* AMRTIOGAIFACE_H */
