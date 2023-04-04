% This function performs fuel weight estimation for loiter % 
% It assumes CONSTANT ALTITUDE and MACH NUMBER for cruise. %
% Hence, L/D is assumed to be constant (for given altitude %
% and mach number.                                         %
% See Raymer Ch.3 equations 3.7 and 3.8                    %
% Outputs:                                                 %
%   Loiter fuel weight fraction                            %
%   Loiter fuel weight                                     %    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function output = LoiterFunction(inputs,Wi)

%% Inputs for loiter fuel computations
time  = inputs.MissionInputs.loiter_time;           % Loiter time [hours]
eta_p  = inputs.PropulsionInputs.eta_p;              % propeller efficiency
c_bhp  = inputs.PropulsionInputs.c_bhp;              % Propeller specific fuel consumption [lb/hr]
Sw      = inputs.GeometryOutput.Sw;                % wing area [ft]
AR        = inputs.GeometryInputs.AR;               % wing aspect ratio
SizingOutput = SizingIterations(inputs)
W = SizingOutput.W4; % weight after descend phase
%%
%% Parasite drag computation
 inputs.Aero.Cdo = ParasiteDragFunction(inputs); % Parasite Drag Coefficient, Cdo
 inputs.Aero.e0  = OswaldEfficiency(inputs);     % Oswald Efficiency Factor, e0
 
%% Additional inputs needed for cruise segment analysis
%  inputs.Aero.V = inputs.PerformanceInputs.Vlt;   % Loiter velocity [knots]
 inputs.Aero.h = inputs.PerformanceInputs.hlt;   % Loiter altitude [ft]
 [~,~,rho] = AtmosphereFunction(inputs.Aero.h); % density at altitude
 inputs.Aero.V     = (1/1.68781)*sqrt((2*W/(rho*Sw))*sqrt(1/(pi*AR*inputs.Aero.e0*3*inputs.Aero.Cdo))); % [ktas]
 V_ft_s =  inputs.Aero.V*1.68781;               % Loiter velocity [ft/s]

%% loiter fuel computation  
  [Cdi,CL]    = InducedDragFunction(inputs,Wi);  % induced drag and lift coefficients 
  CD          = inputs.Aero.Cdo + Cdi;           % total drag coefficient
  LDrat       = CL/CD;                           % lift-to-drag ratio during cruise
  fl          = exp(-time*(inputs.Aero.V)*(c_bhp+0.1)/(325.9*LDrat*(eta_p-0.1)));              % loiter fuel weight fraction
  Wf          = Wi*fl;                           % final aircraft weight after loiter segment
  output.f_lt = Wf/Wi;                           % loiter fuel-weight ratio (for entire segment)
  output.fuel = Wi-Wf;   % total loiter fuel [lbs]
  %this is a comment
  
end




    
