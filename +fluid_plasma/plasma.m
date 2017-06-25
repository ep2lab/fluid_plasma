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
    methods % General plasma derived properties
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
                factors = factors + 1./h.electrons{i}.dh_dn(ne{i}); % the sum of n/(gamma*Te) factors. Caution: Te must be in J
            end
            cs = sqrt((n.*h.ions.dh_dn(n) + n./factors)/h.ions.m);
        end
        
        function lambdaDe = lambdaDe(h,ne)
            % Debye length 
            const = constants_and_units.constants; 
            n = ne{1}.*0;
            for i = 1:h.n_electrons
                n = n + ne{i}; % the summation over all densities
            end
            lambdaDe = sqrt(const.eps0 * h.cs(ne) / (n * h.q^2));
        end  
    end
%----------------------------------------------------------------------
    methods % Basic object behavior (get/set/save/load/creator/destructor...)
        function h = plasma(varargin)
            % Process varargin and define defaults
            p = inputParser;      
            p.addParameter('library','adim',@(x)any(strcmp(x,{'adim','Xe+','Ar+','H+'}))); 
            % Library of plasmas, to construct default ions and electrons, overriden if given explicitly
            p.KeepUnmatched = true;    
            p.parse(varargin{:}); % check all, and assign defaults to p.Results as needed.            
            library = p.Results.library;
            const =constants_and_units.constants;
            switch library
                case 'adim'                    
                    % Adimensional ions and electrons, assuming me negligible, cold ions and isothermal electrons
                    mi = 1; me = 0; qe = 1;
                    Ti = 0; Te = 1; n = 1;
                    gammai = 1; gammae = 1;
                case 'Xe+'
                    % Xe+ plasma with cold ions and isothermal electrons
                    mi = const.amu2kg(131.29); me = const.me; qe = const.qe;     
                    Ti = 0; Te = const.eV2J(10); n = 1e18;
                    gammai = 1; gammae = 1;
                case 'Ar+'
                    % Ar+ plasma with cold ions and isothermal electrons
                    mi = const.amu2kg(39.948); me = const.me; qe = const.qe;     
                    Ti = 0; Te = const.eV2J(10); n = 1e18;
                    gammai = 1; gammae = 1;
                case 'H+'
                    % H+ plasma with cold ions and isothermal electrons
                    mi = const.amu2kg(1.00794); me = const.me; qe = const.qe; 
                    Ti = 0; Te = const.eV2J(10); n = 1e18;
                    gammai = 1; gammae = 1;
            end
            p.addParameter('ions',fluid_plasma.species('label','ions','m',mi,'q',qe,'n0',n,'T0',Ti,'gamma',gammai),@(x)isa(x,'fluid_plasma.species'));
            p.addParameter('electrons',{fluid_plasma.species('label','electrons','m',me,'q',-qe,'n0',n,'T0',Te,'gamma',gammae)},@iscell);
            % Assign       
            p.KeepUnmatched = false;    
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

