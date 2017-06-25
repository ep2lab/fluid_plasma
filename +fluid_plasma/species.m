%----------------------------------------------------------------------
%{
This class defines a single species of a plasma: ions and electrons and
neutrals.

basic properties are label (the name of the species), m (mass), q
(charge), and thermo_model (can be cold, isothermal, polytropic). The
different thermo models require additional parameters in
thermo_model_data. 

The class defines methods to calculate Temperature, barotropy, density,
and derivatives of these functions (see methods section).

All units are expected in SI.

%----------------------------------------------------------------------
Author: Mario Merino
Date: 20130201
%----------------------------------------------------------------------
%}
%----------------------------------------------------------------------
classdef species < handle
%----------------------------------------------------------------------
    properties % Basic Properties
        label % species name
        m % mass
        q % electric charge 
        n0 % reference density
        T0 % reference temperature, in J
        gamma % polytropic cooling exponent
    end 
%----------------------------------------------------------------------    
    methods % General species properties at the 0 state
        function vth0 = vth0(h)
            % thermal velocity (excluding numerical factors) 
            vth0 = sqrt(h.T0 / h.m); % caution: T0 must be in J
        end 
        function omegap0 = omegap0(h)
            % Plasma frequency
            const = constants_and_units.constants; 
            omegap0 = sqrt(h.n0*h.q^2 / (h.m*const.eps0));
        end
        function omegac0 = omegac0(h,B0)
            % signed cyclotron frequency at magnetic field B0 
            omegac0 = h.q .* B0 / h.m;
        end
        function larmor0 = larmor0(h,B0)
            % thermal velocity Larmor radius at magnetic field B0 
            larmor0 = h.vth0 / h.omegac0(B0);
        end
    end
%----------------------------------------------------------------------    
    methods % Electron properties at the 0 state        
        function CoulombLog = CoulombLog(h)
            % Coulomb logarithm, to be used with electrons only.
            if ~any(regexpi(h.label,'electron'))
                error('This property is only available for electron species')
            end
            const = constants_and_units.constants; 
            CoulombLog = 9+0.5*log(1e18/h.n0 * const.J2eV(h.T0)^3); % caution: T0 must be in J
        end 
        function nuei0 = nuei0(h) 
            % Coulomb collisions, to be used with electrons only. From expression 11.22, p 172 of GOLD95        
            const = constants_and_units.constants; 
            nuei0 = sqrt(2) * h.n0 * h.q^4 * h.CoulombLog /...
                    (12 * pi^(3/2) * const.eps0^2 * sqrt(h.m) * h.T0^(3/2)); % caution: T0 must be in J
        end
        function Hall0 = Hall0(h)
            % Hall parameter, to be used with electrons only 
            Hall0 = h.omegac0 / h.nuei0; 
        end 
    end
%----------------------------------------------------------------------
    methods % Thermodynamics
        function T = T(h,n)
            % Temperature as a function of n 
            switch h.gamma
                case 1
                    T = n*0 + h.T0;
                otherwise
                    T = h.T0*((n/h.n0).^(h.gamma-1)); 
            end
        end
        function h = h(h_,n)
            % barotropy as function of n
            switch h_.gamma
                case 1
                    h = h_.T0*log(n/h_.n0);
                otherwise
                    h = h_.T0*( h_.gamma / (h_.gamma-1))*((n/h_.n0).^(h_.gamma-1) -1); 
            end
        end      
        function dh_dn = dh_dn(h_,n)
            % derivative of h(n)  
            switch h_.gamma
                case 1
                    dh_dn = h_.T0./n;
                otherwise
                    dh_dn = h_.T0*h_.gamma* (n/h_.n0).^(h_.gamma-2) /h_.n0; 
            end
        end   
        function d2h_dn2 = d2h_dn2(h_,n)
            % derivative of h(n)
            switch h_.gamma
                case 1
                    d2h_dn2 = -h_.T0./n.^2;
                otherwise
                    d2h_dn2 = h_.T0*h_.gamma*(h_.gamma-2)* (n/h_.n0).^(h_.gamma-3) /h_.n0^2; 
            end
        end  
        function n = n(h_,h)
            % inverse of the barotropy function: given h, returns n 
            switch h_.gamma
                case 1
                    if h_.T0 == 0 
                        error('species:cold:h_1','If the species is cold, you cannot use the inverse of the barotropy function to calculate the density'); 
                    end
                    n = h_.n0*exp(h/h_.T0);
                otherwise
                    n = h_.n0*((h_.gamma-1)/h_.gamma *h/h_.T0 + 1).^(1/(h_.gamma-1));
                    if ~isreal(n)
                        n = 0;
                    end 
            end
        end       
    end 
%----------------------------------------------------------------------
    methods % Basic object behavior (get/set/save/load/creator/destructor...)
        function h = species(varargin)            
            % Process varargin and define defaults
            p = inputParser;                        
            p.addParameter('label','species',@ischar);
            p.addParameter('m',1,@isnumeric);
            p.addParameter('q',1,@isnumeric);
            p.addParameter('n0',1,@isnumeric); % default: cold species
            p.addParameter('T0',0,@isnumeric);
            p.addParameter('gamma',1,@isnumeric);
            % Assign to object 
            p.parse(varargin{:});     
            h.label = p.Results.label;    
            h.m = p.Results.m;
            h.q = p.Results.q; 
            h.n0 = p.Results.n0; 
            h.T0 = p.Results.T0; 
            h.gamma = p.Results.gamma;
        end        
        function set.label(h,v)
            assert(ischar(v));
            h.label = v;
        end  
        function set.m(h,v)
            assert(isscalar(v) && v >= 0);
            h.m = v;            
        end   
        function set.q(h,v)            
            assert(isscalar(v) && isreal(v));
            h.q = v;           
        end   
    end 
%----------------------------------------------------------------------    
end

