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
        thermo_model % Any from those listed in valid_thermo_model
        thermo_model_data % structure with thermodynamic data. Varies with model        
    end
%----------------------------------------------------------------------
    properties (Hidden = true, Constant = true) 
        valid_thermo_model = {'cold','isothermal','polytropic'} 
        default_thermo_model_data = struct(... % library for reseting data upon model change
            'cold',struct('n0',1,'T0',0,'gamma',1),...
            'isothermal',struct('n0',1,'T0',1,'gamma',1),...
            'polytropic',struct('n0',1,'T0',1,'gamma',1.2));
        conditions_thermo_model_data = struct(... % Use "v." for properties in the corresponding default_thermo_model_data structure
            'cold',{{'v.n0 > 0','v.T0 == 0'}},...
            'isothermal',{{'v.n0 > 0','v.T0 > 0','v.gamma == 1'}},...
            'polytropic',{{'v.n0 > 0','v.T0 > 0','v.gamma > 1'}});
    end
%----------------------------------------------------------------------
methods % Thermodynamics
        function T = T(h,n)
            % Temperature as a function of n
            k = h.thermo_model_data;
            switch h.thermo_model
                case 'cold'
                    T = n*0 + 0;
                case 'isothermal'
                    T = n*0 + k.T0;
                case 'polytropic'
                    T = k.T0*((n/k.n0).^(k.gamma-1)); 
            end
        end
        function h = h(h_,n)
            % barotropy as function of n
            k = h_.thermo_model_data;
            switch h_.thermo_model
                case 'cold'
                    h = n*0 +0;
                case 'isothermal'
                    h = k.T0*log(n/k.n0);
                case 'polytropic'
                    h = k.T0*( k.gamma / (k.gamma-1))*((n/k.n0).^(k.gamma-1) -1); 
            end
        end      
        function dh_dn = dh_dn(h_,n)
            % derivative of h(n)
            k = h_.thermo_model_data;
            switch h_.thermo_model
                case 'cold'
                    dh_dn = n*0;
                case 'isothermal'
                    dh_dn = k.T0./n;
                case 'polytropic'
                    dh_dn = k.T0*k.gamma* (n/k.n0).^(k.gamma-2) /k.n0; 
            end
        end   
        function d2h_dn2 = d2h_dn2(h_,n)
            % derivative of h(n)
            k = h_.thermo_model_data;
            switch h_.thermo_model
                case 'cold'
                    d2h_dn2 = n*0;
                case 'isothermal'
                    d2h_dn2 = -k.T0./n.^2;
                case 'polytropic'
                    d2h_dn2 = k.T0*k.gamma*(k.gamma-2)* (n/k.n0).^(k.gamma-3) /k.n0^2; 
            end
        end  
        function n = n(h_,h)
            % inverse of the barotropy function: given h, returns n
            k = h_.thermo_model_data;
            switch h_.thermo_model
                case 'cold'
                    error('species:cold:h_1','In the cold species, you cannot use the inverse of the barotropy function, n, to calculate the density');
                case 'isothermal'
                    n = k.n0*exp(h/k.T0);
                case 'polytropic'
                    n = k.n0*((k.gamma-1)/k.gamma *h/k.T0 + 1).^(1/(k.gamma-1));
                    if ~isreal(n)
                        n = 0;
                    end 
            end
        end       
    end
%----------------------------------------------------------------------    
    methods (Access = 'protected', Hidden = true) % internal methods
        function result = is_valid_thermo_model_data(h,v)
            if ~isstruct(v)
                result = false;
                return;
            end
            result = true; % to start with
            dmd_fieldnames = fieldnames(h.default_thermo_model_data.(h.thermo_model));
            v_fieldnames = fieldnames(v);
            result = result && (length(v_fieldnames) == length(dmd_fieldnames)); % check both lengths coincide
            for i = 1:length(v_fieldnames)
                if ~result % avoid extra checking if already false.
                    return;
                end
                result = result && (ismember(v_fieldnames{i}, dmd_fieldnames)); % check field exist in default_thermo_model_data
                result = result && (isa(v.(v_fieldnames{i}), class(h.default_thermo_model_data.(h.thermo_model).(v_fieldnames{i})))); % check whatever you set here is the same class as it should
            end
            % Model-specific checks
            for i = 1:length(h.conditions_thermo_model_data.(h.thermo_model))
                condition = h.conditions_thermo_model_data.(h.thermo_model){i};                
                assert(eval(condition))
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
            p.addParameter('thermo_model','cold',@(x)ismember(x,h.valid_thermo_model));                        
            % Assign to object
            p.KeepUnmatched = true;
            p.parse(varargin{:});            
            h.m = p.Results.m;
            h.q = p.Results.q;
            h.thermo_model = p.Results.thermo_model;
            h.label = p.Results.label;
            p.KeepUnmatched = false;            
            % Deal with thermo_model_data
            p.addParameter('thermo_model_data',h.default_thermo_model_data.(h.thermo_model),@isstruct);                         
            p.parse(varargin{:}); % check all, and assign defaults to p.Results as needed.            
            h.thermo_model_data = p.Results.thermo_model_data;
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
        function set.thermo_model(h,v)
            assert(ismember(v,h.valid_thermo_model));       
            % do the assign and check data
            h.thermo_model = v;            
            if ~h.is_valid_thermo_model_data(h.thermo_model_data)
                h.thermo_model_data = h.default_thermo_model_data.(h.thermo_model);
            end
        end             
        function set.thermo_model_data(h,v)
            assert(h.is_valid_thermo_model_data(v)); % assert validity of structure
            fn = fieldnames(v);
            h.thermo_model_data = h.default_thermo_model_data.(h.thermo_model); % clear
            for i = 1:length(fn) % this way it will be in the same order, and it will not complain about basic properties being set last during the partial assignments
                h.thermo_model_data.(fn{i}) = v.(fn{i});
            end
        end        
    end 
%----------------------------------------------------------------------    
end

