
%% Function that computes the fuel and takeoff weight for different economic missions
% The approach is similar to the aircraft sizing routine, but with the
% exception that the empty weight of the aircraft is fixed (already known)
% The economic mission is assumed to be:
%
%              ______cruise_____
%             /                 \ descend
%            /                   \___
%           /climb                \_/ loiter
%          /                        \ 
%_________/                          \_____ 
%taxi & TO                          landing & taxi
%
% Additional mission segments can be added but this function must be
% changed to accomodate these.
function output = EconMissionFunction(inputs)

inputs.MissionInputs.R = inputs.EconMission.range;

%% Start Aircraft Sizing Iterations
TOGW_temp = 41005;      % guess of takeoff gross weight [lbs] 
tolerance = 0.001;       % sizing tolerance
diff      = tolerance+1; % initial tolerance gap
mbatt_total = 0;
while diff > tolerance
   inputs.Sizing.TOGW_temp = TOGW_temp;             % store initial gross weight
   W0                      = TOGW_temp;             % initial gross weight for current iteration [lbs]
%% Begin estimation of weight components (empty, fuel, and total weights)

  WarmupTakeoffOutput = WarmupTakeoffFunction(inputs);
  f_to                = WarmupTakeoffOutput.f_to;   % warm-up and takeoff fuel weight fraction
  W1                  = TOGW_temp*f_to;             % aircraft weight after warm-up and takeoff [lbs]
% Climb segment fuel weight fraction
  ClimbOutput         = ClimbFunction(inputs);
  f_cl                = ClimbOutput.f_cl;           % climb fuel weight fraction
  W2                  = W1*f_cl;                    % aircraft weight after climb segment [lbs]
% Cruise segment fuel weight fraction
  CruiseOutput        = CruiseFunction(inputs,W2);
  f_cr                = CruiseOutput.f_cr;          % cruise fuel weight fraction
  mbatt_cruise        = CruiseOutput.batt;          % cruise battery weight [lbc]
  mbatt_total         = mbatt_total + mbatt_cruise; %total battery weight [lbs]
  W3                  = W2*f_cr+mbatt_total;        % aircraft weight after cruise segment [lbs]
% Descend fuel weight fraction (including descend segment as well)
  DescendOutput       = DescendFunction(inputs);
  f_dsc               = DescendOutput.f_dsc;    % landing and taxi fuel weight segment
  W4                  = W3*f_dsc;                   % aircraft weight after landing & taxi segment [lbs]
% Loiter segment fuel weight fraction
  LoiterOutput        = LoiterFunction(inputs,W4);
  f_lt                = LoiterOutput.f_lt;          % loiter fuel weight segment

  mbatt_loiter        = LoiterOutput.batt;          % loiter battery weight [lbc]
  mbatt_total         = mbatt_total + mbatt_loiter; %total battery weight [lbs]
  W5                  = W4*f_lt+mbatt_total;        % aircraft weight after loiter segment [lbs]
% Landing and taxi fuel weight fraction (including descend segment as well)
  LandingTaxiOutput   = LandingTaxiFunction(inputs);
  f_lnd               = LandingTaxiOutput.f_lnd;    % landing and taxi fuel weight segment
  W6                  = W5*f_lnd;                   % aircraft weight after landing & taxi segment [lbs]

%% Compute new weights based on results of current iteration  
% Total fuel weight fraction (including trapped fuel of 6%)  
% Based on Raymer Ch.3 Eq. 3.11
  FWF       = 1.06*(1- f_to*f_cl*f_cr*f_dsc*f_lt*f_lnd);  % Fuel weight fraction 
  Wfuel     = 0.8*FWF*TOGW_temp;                    % Total fuel weight [lbs] (Overestimates - used scaling factor)
  
% Aircraft Takeoff Gross Weight Weight (TOGW) [lbs]: Wempty+Wpayload+Wfuel  
  TOGW      = inputs.EmptyWeight.We + inputs.PayloadInputs.w_payload + Wfuel+mbatt_total;  
  
% Compute convergence criteria & set-up for next iteration   
  diff      = abs(TOGW_temp - TOGW);
  TOGW_temp = TOGW;                  
  mbatt_final = mbatt_total;
  mbatt_total = 0;
end
TOGW = TOGW_temp;     % Aircraft takeoff gross weight [lbs]

%% OUTPUTS
inputs.EmptyWeight.We
output=inputs;
output.Wfuel = Wfuel; % mission fuel weight [lbs]
output.Wto   = TOGW;  % mission takeoff gross weight [lbs]
output.EmptyWeight.We = inputs.EmptyWeight.We;
output.TOGW        = TOGW;
output.Wfuel       = Wfuel;
output.W4          = W4;
output.batt        = mbatt_final;

