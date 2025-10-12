#include "catch2/catch_all.hpp"
#include "catch2/catch_test_macros.hpp"


TEST_CASE("No case tagged so no time object needed", "[serial]") {
    REQUIRE(true);
}

TEST_CASE("another no case tagged test") {
    REQUIRE(true);
}
