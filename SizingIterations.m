
%% Function that sizes the aircraft for the given input parameters
% The approach follows Raymer Ch.6
% The design mission is assumed to be:
%
%              ______cruise_____
%             /                 \ descend
%            /                   \___
%           /climb                \_/ loiter
%          /                        \ 
%_________/                          \_____ 
%taxi & TO                          landing & taxi
%
% Note that no reserve segment is present here. 
% Additional mission segments can be added but this function must be
% changed to accomodate these.
%%
function FinalOutput = SizingIterations(inputs)

%% Start Aircraft Sizing Iterations
TOGW_temp = 41005;        % guess of takeoff gross weight [lbs] 
tolerance = 0.1;         % sizing tolerance [lbs]
diff      = tolerance+1; % initial tolerance gap [lbs]
mbatt_total = 0; %intializing battery [lbs]
mfuel_total = 0; % initialize fuel [lbs]
while diff > tolerance
   inputs.Sizing.Power     = TOGW_temp*inputs.PerformanceInputs.PW; % compute total power (based on P/W)
   inputs.Sizing.TOGW_temp = TOGW_temp;                             % store initial gross weight
   W0                      = TOGW_temp;                             % initial gross weight for current iteration
   inputs.Sizing.W0        = W0;
   eta_batt = inputs.BatteryInputs.eta_e;           %electric propuslion efficiency
   batt_dens = inputs.BatteryInputs.energydensity;      %battery energy density W*hr/kg
   batP_to = inputs.BatteryInputs.batP_to; % portion of battery used in taxi/takeoff
   batP_cl = inputs.BatteryInputs.batP_cl       = 0; % portion of battery used in climb
   batP_dsc = inputs.BatteryInputs.batP_dsc; % portion of battery used in descend
   batP_lnd = inputs.BatteryInputs.batP_lnd; % portion of battery used in landing/taxi
   t_taxi = inputs.BatteryInputs.taxitime; % [hr]
   t_to = inputs.BatteryInputs.totime; % [hr]
   t_cl = inputs.BatteryInputs.cltime; % [hr]
   t_lnd = inputs.BatteryInputs.lndtime; % [hr]
%% Begin estimation of weight components (empty, fuel, and total weights)

% Generate internal layout data
  inputs.LayoutOutput   = LayoutFunction(inputs);

% Generate geometry data
  inputs.GeometryOutput = GeometryFunction(inputs); 
% Compute Empty weight and empty weight fraction
  EmptyWeightOutput     = EmptyWeightFunction(inputs);  
  
% Warm-up and Takeoff segment fuel weight fraction
  WarmupTakeoffOutput = WarmupTakeoffFunction(inputs);
  f_to                = WarmupTakeoffOutput.f_to;   % warm-up and takeoff fuel weight fraction
  mbatt_to            = batP_to*2.20462*(0.1*inputs.Sizing.Power*t_taxi + inputs.Sizing.Power*t_to)/(eta_batt*batt_dens);  
  mbatt_total         = mbatt_total + mbatt_to;
  mfuel_to            = (1-batP_to)*TOGW_temp*(1-f_to); % fuel weight takeoff [lbs]
  mfuel_total         = mfuel_total + mfuel_to;
  W1                  = TOGW_temp - (mfuel_to + mbatt_to);     % aircraft weight after warm-up and takeoff [lbs]
% Climb segment fuel weight fraction
  ClimbOutput         = ClimbFunction(inputs);
  f_cl                = ClimbOutput.f_cl;           % climb fuel weight fraction
  mbatt_cl            = batP_cl*2.20462*(inputs.Sizing.Power*t_cl)/(eta_batt*batt_dens);
  mbatt_total         = mbatt_total + mbatt_cl;
  mfuel_cl            = (1-batP_cl)*W1*(1-f_cl); % fuel weight climb [lbs]
  mfuel_total         = mfuel_total + mfuel_cl;
  W2                  = W1 - (mfuel_cl + mbatt_cl);                    % aircraft weight after climb segment [lbs]
% Cruise segment fuel weight fraction
  CruiseOutput        = CruiseFunction(inputs,W2);
  f_cr                = CruiseOutput.f_cr;          % cruise fuel weight fraction
  mbatt_cr            = CruiseOutput.batt;          % cruise battery weight [lbc]
  mbatt_total         = mbatt_total + mbatt_cr; %total battery weight [lbs]
  mfuel_cr            = W2*(1-f_cr); % fuel weight cruise [lbs]
  mfuel_total         = mfuel_total + mfuel_cr;
  W3                  = W2*f_cr+mbatt_total;        % aircraft weight after cruise segment [lbs]
% Descend fuel weight fraction (including descend segment as well)
  DescendOutput       = DescendFunction(inputs);
  f_dsc               = DescendOutput.f_dsc;    % landing and taxi fuel weight segment
  mbatt_dsc           = 0;
  mbatt_total         = mbatt_total + mbatt_dsc;
  mfuel_dsc            = W3*(1-f_dsc);     % fuel weight descend [lbs]
  mfuel_total         = mfuel_total + mfuel_dsc;
  W4                  = W3*f_dsc;                   % aircraft weight after landing & taxi segment [lbs]
% Loiter segment fuel weight fraction
  LoiterOutput        = LoiterFunction(inputs,W4);
  f_lt                = LoiterOutput.f_lt;          % loiter fuel weight segment

  mbatt_lt            = LoiterOutput.batt;          % loiter battery weight [lbc]
  mbatt_total         = mbatt_total + mbatt_lt; %total battery weight [lbs]
  mfuel_lt            = W4*(1-f_lt); % fuel weight loiter [lbs]
  mfuel_total         = mfuel_total + mfuel_lt;
  W5                  = W4*f_lt+mbatt_total;        % aircraft weight after loiter segment [lbs]
% Landing and taxi fuel weight fraction (including descend segment as well)
  LandingTaxiOutput   = LandingTaxiFunction(inputs);
  f_lnd               = LandingTaxiOutput.f_lnd;    % landing and taxi fuel weight segment
  mbatt_lnd           = batP_lnd*2.20462*(0.1*inputs.Sizing.Power*t_lnd)/(eta_batt*batt_dens);
  mbatt_total         = mbatt_total + mbatt_cl;
  mfuel_lnd           = (1-batP_lnd)*W5*(1-f_lnd); % fuel weight climb [lbs]
  mfuel_total         = mfuel_total + mfuel_lnd;
  W6                  = W5 - (mfuel_lnd + mbatt_lnd);  % aircraft weight after landing & taxi segment [lbs]             

%% Compute new weights based on results of current iteration  
% Total fuel weight fraction (including trapped fuel of 5%)

%   FWF       = 1.06*(1- f_to*f_cl*f_cr*f_dsc*f_lt*f_lnd);  % Fuel weight fraction 
%   Wfuel     = FWF*TOGW_temp;                        % Total fuel weight [lbs] (Overestimates - used scaling factor)
  Wfuel = 1.06*mfuel_total;
% Aircraft Takeoff Gross Weight Weight (TOGW) [lbs]: Wempty+Wpayload+Wfuel  
  TOGW      = EmptyWeightOutput.We + inputs.PayloadInputs.w_payload + Wfuel+mbatt_total;  
  
% Compute convergence criteria & set-up for next iteration   
  diff      = abs(TOGW_temp - TOGW);
  TOGW_temp = TOGW;                  
  TOGW      = 0; 
  mbatt_final = mbatt_total;
  mbatt_total = 0;
end

% EmptyWeightOutput
TOGW = TOGW_temp;                  % Aircraft takeoff gross weight [lbs]
EWF  = EmptyWeightOutput.We/TOGW;  % Empty weight fraction

%% Aggregate results
FinalOutput             = inputs;
FinalOutput.EmptyWeight = EmptyWeightOutput;
FinalOutput.TOGW        = TOGW;
FinalOutput.Wfuel       = Wfuel;
FinalOutput.Power       = inputs.Sizing.Power;
FinalOutput.W4          = W4;
FinalOutput.batt        = mbatt_final;

inputs.Aero.Cdo = ParasiteDragFunction(inputs);
FinalOutput.Cdo = inputs.Aero.Cdo;
end