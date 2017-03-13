%{
Compendium of all plasma tests. You can run the tests by executing
runtests. You must add the package to your path first.

%----------------------------------------------------------------------
Author: Mario Merino
Date: 20130201
%----------------------------------------------------------------------
%}
function tests = plasma_test
    tests = functiontests(localfunctions);
end

%----------------------------------------------------------------------
%----------------------------------------------------------------------
%----------------------------------------------------------------------

function test_species_creation(t)
    testplasma = fluid_plasma.plasma;
    testplasma = fluid_plasma.plasma('ions',fluid_plasma.species);
    testplasma = fluid_plasma.plasma('electrons',{fluid_plasma.species});
    testplasma = fluid_plasma.plasma('electrons',{fluid_plasma.species,fluid_plasma.species});
end
function test_property_changing(t)
    testplasma = fluid_plasma.plasma;
    testplasma.ions = fluid_plasma.species;
    testplasma.electrons = {fluid_plasma.species};
end 
function test_cs_method_calls(t)
    electrons = fluid_plasma.species('label','e','m',0,'q',-1,'thermo_model','isothermal');
    testplasma = fluid_plasma.plasma('electrons',{electrons});
    testplasma.cs(1);
    testplasma.cs({1});
    testplasma.electrons = {electrons,electrons;electrons,electrons};
    testplasma.cs({1,1;1,1});
end 
