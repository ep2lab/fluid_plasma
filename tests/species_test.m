%{
Compendium of all species tests. You can run the tests by executing
runtests. You must add the package to your path first.

%----------------------------------------------------------------------
Author: Mario Merino
Date: 20130201
%----------------------------------------------------------------------
%}
function tests = species_test
    tests = functiontests(localfunctions);
end

%----------------------------------------------------------------------
%----------------------------------------------------------------------
%----------------------------------------------------------------------
 
function test_species_creation(t)
    testspecies = fluid_plasma.species;
    testspecies = fluid_plasma.species('label','my_electrons','m',12,'q',-4);
end
function test_cold_species_creation(t)
    testspecies = fluid_plasma.species('thermo_model','cold');
    testspecies = fluid_plasma.species('thermo_model','cold','thermo_model_data',struct('n0',22));
end
function test_isothermal_species_creation(t)
    testspecies = fluid_plasma.species('thermo_model','isothermal');
    testspecies = fluid_plasma.species('thermo_model','isothermal','thermo_model_data',struct('T0',33,'n0',22));
end
function test_polytropic_species_creation(t)
    testspecies = fluid_plasma.species('thermo_model','polytropic');
    testspecies = fluid_plasma.species('thermo_model','polytropic','thermo_model','polytropic','thermo_model_data',struct('gamma',1.3,'T0',9,'n0',2));
end
function test_property_changing(t)
    testspecies = fluid_plasma.species;
    testspecies.q = -2;
    testspecies.thermo_model = 'polytropic';
    testspecies.thermo_model_data.T0 = 23;
end
function test_calling_thermodynamic_methods(t)    
    testspecies = fluid_plasma.species;
    testspecies.thermo_model = 'cold';
    testspecies.h(rand(3,4,2));
    testspecies.T(rand(4,7,3));
    testspecies.dh_dn(rand(4,7,3));
    testspecies.d2h_dn2(rand(4,7,3)); 
    thermo_models = {'isothermal','polytropic'};
    for i_model = 1:length(thermo_models)
        testspecies.thermo_model = thermo_models{i_model};
        testspecies.h(rand(3,4,2));
        testspecies.T(rand(4,7,3));
        testspecies.dh_dn(rand(4,7,3));
        testspecies.d2h_dn2(rand(4,7,3));
        testspecies.n(rand(4,7,3));    
    end    
end




