%{
This class defines a plasma made up of a single ion species, and one or
more electron species (each of which is a species). if many, use
cellarray of simple_species objects. 

The class defines methods to calculate cs (sound speed). 

All units need to be given in SI

%----------------------------------------------------------------------
Author: Mario Merino
Date: 20130201
%----------------------------------------------------------------------
%}
classdef plasma < handle
%----------------------------------------------------------------------
    properties % Basic Properties
        ions 
        electrons 
    end
%----------------------------------------------------------------------
    properties (Dependent = true) 
        n_electrons
    end 
%----------------------------------------------------------------------
    methods % Thermodynamics
        function cs = cs(h,ne)
            % Returns the effective sound speed, taking into account the
            % ion temperature and the multiple electron temperatures
            % (see meri13a). As input, ne is a cellarray of the electron
            % densities, (each array in the cell array corresponds to
            % one electron species, in order).
            if ~iscell(ne)
                ne = {ne}; % in case of only one species, when only one density array is provided, it is not necessary to give it like a cell
            end
            n = ne{1}.*0;            
            factors = n;
            for i = 1:h.n_electrons
                n = n + ne{i}; % the summation over all densities
                factors = factors + 1./h.electrons{i}.dh_dn(ne{i}); % the sum of n/(gamma*Te) factors
            end
            cs = sqrt((n.*h.ions.dh_dn(n) + n./factors)/h.ions.m);
        end
    end
%----------------------------------------------------------------------
    methods % Basic object behavior (get/set/save/load/creator/destructor...)
        function h = plasma(varargin)
            % Process varargin and define defaults
            p = inputParser;            
            p.addParameter('ions',fluid_plasma.species('label','ions','m',1,'q',1,'thermo_model','cold'),@(x)isa(x,'fluid_plasma.species'));
            p.addParameter('electrons',{fluid_plasma.species('label','electrons','m',0,'q',-1,'thermo_model','isothermal')},@iscell);
            % Assign 
            p.parse(varargin{:}); % check all, and assign defaults to p.Results as needed.            
            h.ions = p.Results.ions;
            h.electrons = p.Results.electrons;            
        end          
        function v = get.n_electrons(h)
            v = numel(h.electrons);
        end     
    end
%----------------------------------------------------------------------
end

