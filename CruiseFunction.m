% This function estimates fuel weight  for cruise.         % 
% It assumes CONSTANT ALTITUDE and MACH NUMBER for cruise. %
% Hence, L/D is assumed to be constant (for given altitude %
% and mach number).                                        %
% See Raymer Ch.3 equations 3.5 and 3.6                    %
% Outputs:                                                 %
%   Cruise fuel weight fraction                            %
%   Cruise fuel weight                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function output = CruiseFunction(inputs,Wo)

%% Inputs for cruise fuel computations
Range  = inputs.MissionInputs.R;                    % aircraft design range [nmi]
eta_p  = inputs.PropulsionInputs.eta_p;             % propeller efficiency
c_bhp  = inputs.PropulsionInputs.c_bhp;             % specific fuel consumption [lb/hr]
eta_batt = inputs.BatteryInputs.eta_e;           %electric propuslion efficiency
batt_dens = inputs.BatteryInputs.energydensity;      %battery energy density W*hr/kg
percent_bat = inputs.BatteryInputs.batP_cr;         %battery use in cruise (%)
%%
%% Parasite drag computation
 inputs.Aero.Cdo = ParasiteDragFunction(inputs,"cruise");    % Parasite Drag Coefficient, Cdo
 inputs.Aero.e0  = OswaldEfficiency(inputs);        % Oswald Efficiency Factor, e0

%% Additional inputs needed for cruise segment analysis
 inputs.Aero.V = inputs.PerformanceInputs.V;        % cruise velocity [knots]
 inputs.Aero.h = inputs.PerformanceInputs.hc;       % cruise altitude [ft]
 
%% Cruise fuel computation  
   V     = inputs.Aero.V;                           % cruise velocity [knots]
   Wf    = Wo;                                      % initialize aircraft weight for cruise computation [lbs]
  
   segs  = 25;                                      % number of cruise segments
   Range_seg = round(Range/segs);                   % length of each cruise segment [nmi]
   V_ft_s =  V*1.68781;                             % cruise velocity [ft/s]
   fuel_weight = 0;   %Sets up intial values for loop
   batt_weight = 0;   %Sets up intial values for loop
    Wi    = Wo;       %Sets up inial weight for loop
    fuel_weight_seg  = 0;%Sets up intial values for loop
  for i = 1:segs
      Wi = Wi-fuel_weight;                                      % weight at beginning of cruise segment
      [Cdi,CL]    = InducedDragFunction(inputs,Wi); % induced drag and lift coefficients 
      CD          = inputs.Aero.Cdo + Cdi;          % total drag coefficient
      LDrat       = CL/CD;                          % lift-to-drag ratio during segment
      fc          = exp(-Range_seg*c_bhp/(LDrat*eta_p*325.9));    % cruise fuel fraction 
      Wf          = Wi*fc;                          % final aircraft weight after cruise [lbs]
      mbatt_seg = 2.20462*2.725*(Wi/2.205)*(Range_seg/.54)/(eta_p*eta_batt*LDrat*batt_dens); %mass of battery required lb 
      fuel_weight_max = Wi-Wf;                          %weight of fuel
      fuel_weight_seg = (1-percent_bat)*fuel_weight_max;     %weight of fuel used lb
      fuel_weight = fuel_weight+fuel_weight_seg;                      % Fuel total over cruise lb
      batt_weight = percent_bat*mbatt_seg+batt_weight; %weight of batteries in lbs
  end
  output.f_cr     = (Wo-fuel_weight)/Wo;                          % cruise fuel-weight ratio (for entire mission)
  output.fuel     = fuel_weight;                          % total cruise fuel [lbs]
  output.batt     = batt_weight;                    % total battery weight [lbs]
end
  
  
