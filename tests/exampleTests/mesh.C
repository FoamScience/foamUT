/*
    This file is not compatible with the Foundation Version of OpenFOAM
    So it's not compiled in Make/files
    It's just here for show unless you add it there
*/

#include "catch2/catch_all.hpp"
#include "catch2/catch_test_macros.hpp"
#include "fvCFD.H"
#include "dynamicFvMesh.H"
#include "messageStream.H"
#include "staticFvMesh.H"
#include "dynamicMotionSolverFvMesh.H"

using namespace Foam;
extern Time* timePtr;
extern argList* argsPtr;

TEST_CASE("Check mesh size", "[cavity][serial][parallel]") {
    Time& runTime = *timePtr;
    argList& args = *argsPtr;
    #include "createMesh.H"

    CAPTURE(Pstream::myProcNo(), Pstream::nProcs(), mesh.nCells());

    // The cavity case has 400 cells, gets split into 4, equally
    if (Pstream::parRun()) {
        REQUIRE(mesh.nCells() == 100);
    } else {
        REQUIRE(mesh.nCells() == 400);
    }
}

TEST_CASE("RTS on mesh classes", "[cavity][serial][parallel]") {
    Time& runTime = *timePtr;
    argList& args = *argsPtr;

    SECTION("The created mesh is a static fvMesh") {
        IStringStream is
        (
            "dynamicFvMesh staticFvMesh;"
        );
        IOdictionary dynamicMeshDict
        (
            IOobject
            (
                "dynamicMeshDict",
                runTime.constant(),
                runTime,
                IOobject::NO_READ,
                IOobject::NO_WRITE,
                false
            ),
            is
        );
        dynamicMeshDict.regIOobject::write();

        #include "createDynamicFvMesh.H"
        REQUIRE(isA<staticFvMesh>(mesh));
    }

    SECTION("The created mesh is not a motion-solved fvMesh") {
        IStringStream is
        (
            "dynamicFvMesh staticFvMesh;"
        );
        IOdictionary dynamicMeshDict
        (
            IOobject
            (
                "dynamicMeshDict",
                runTime.constant(),
                runTime,
                IOobject::NO_READ,
                IOobject::NO_WRITE,
                false
            ),
            is
        );
        dynamicMeshDict.regIOobject::write();

        #include "createDynamicFvMesh.H"
        REQUIRE(isA<dynamicMotionSolverFvMesh>(mesh) == false);
    }
}
