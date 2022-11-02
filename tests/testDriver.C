#include "catch2/catch_all.hpp"

#include "argList.H"
// In case you're wondering why this include?
// Because Extend has time class in foamTime.H and the others have it at Time.H
#include "subCycleTime.H"

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

// Global vars all compelation units share
using namespace Foam;
Time* timePtr;      // A single time object
argList* argsPtr;   // Some forks want argList access at createMesh.H

int main(int argc, char *argv[])
{
    // Split argv into:
    // doctest_argv --- foam_argv

    // Find position of separator "---"
    int sepIdx = argc-1;
    for(int i = 1; i<argc; i++)
    {
        if (strcmp(argv[i], "---") == 0) sepIdx = i;
    }

    // Figure out argc for each part
    int doctestArgc = (sepIdx == argc-1) ? argc : sepIdx;
    int foamArgc = (sepIdx == argc-1) ? 1 : argc - sepIdx;

    // Prepare argv for doctestArgv
    char*  doctestArgv[doctestArgc];
    for(int i = 0; i<doctestArgc; i++)
    {
        doctestArgv[i] = argv[i];
    }
    
    // Prepare argv for OpenFOAM
    char*  foamArgv[foamArgc];
    foamArgv[0] = argv[0];
    for(int i = 1; i<foamArgc; i++)
    {
        foamArgv[i] = argv[doctestArgc+i];
    }
    
    // Overwrite argv and argc for Foam include files
    argc = foamArgc;
    for(int i = 1; i<foamArgc; i++)
    {
       argv[i] = foamArgv[i];
    }

    // Sane OpenFOAM settings; optimized for unit testing
    // Ignore warnings
    Foam::Warning.level = -1;
    //Foam::Warning().stdStream().setstate(std::ios_base::failbit);
    // Typically you want exceptions so the other tests continue to run;
    // because a FATAL ERROR will exit/abort
    // But **while writing the test itself** you'll want to turn this off so you
    // can see the errors you're getting and act accordingly
    Foam::FatalError.throwExceptions();

    // Create a doctest session and run it
    //const auto& err = doctest::Context(doctestArgc, doctestArgv).run();
    // Grab a catch session
    Catch::Session session;
    auto result = session.applyCommandLine(doctestArgc, doctestArgv);

    if (result != 0) return result;

    const auto& reporters = session.configData().reporterSpecifications;
    if (reporters.size() != 0) {
        Pout.stdStream().setstate(std::ios_base::failbit);
        Info().stdStream().setstate(std::ios_base::failbit);
        Warning().stdStream().setstate(std::ios_base::failbit);
    }

    //argList::noBanner();
    #include "setRootCase.H"
    #include "createTime.H"
    argsPtr = &args;
    timePtr = &runTime;

    auto ret = session.run();
    if (ret != 0)  abort();
    return 0;
}

// ************************************************************************* //
