#include "IOobject.H"
#include "catch2/catch_all.hpp"
#include "catch2/catch_test_macros.hpp"
#include "fvCFD.H"
#include "fvMesh.H"
#include "messageStream.H"
#include "volFields.H"

using namespace Foam;
extern Time* timePtr;
extern argList* argsPtr;

SCENARIO("Check field initialization methods", "[cavity][serial][parallel]") {
    Foam::FatalError.dontThrowExceptions();
    Time& runTime = *timePtr;
    argList& args = *argsPtr;
    #include "createMesh.H"

    CAPTURE(Pstream::myProcNo(), Pstream::nProcs(), mesh.nCells());

    GIVEN("A time object, a mesh, and an initialized field") {

        dimensionedScalar zero("0", dimless, 0.0);
        volScalarField fld
        (
            IOobject
            (
                "fld",
                runTime.timeName(),
                mesh,
                IOobject::NO_READ,
                IOobject::NO_WRITE
            ),
            mesh,
            zero
        );

        THEN("All internal field values are correctly initialized from NO_READ constructor") {
            REQUIRE(fld.internalField() == scalarField(mesh.nCells(), 
                Pstream::myProcNo() == 1 ? 1 : 0));
        }

        WHEN("Field values are changed") {
            fld += 1;
            THEN("All internal field values must be updated") {
                REQUIRE(fld.internalField() == scalarField(mesh.nCells(), 1));
            }
        }
    }
}
