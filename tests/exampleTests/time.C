#include "catch2/catch_all.hpp"
#include "catch2/catch_test_macros.hpp"
#include "fvMesh.H"

using namespace Foam;
extern Time* timePtr;

TEST_CASE("Check time index", "[cavity][serial][parallel]") {
    Time& runTime = *timePtr;
    CAPTURE(runTime.timeIndex());
    REQUIRE(runTime.timeIndex() == 0);
}
