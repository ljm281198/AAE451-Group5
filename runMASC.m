%% MATLAB AIRCRAFT SIZING CODE (MASC) - GA AIRCRAFT (AV GAS)
%This sizing routing size a General Aviation aircraft for a set of given  %  
% input parameters It largely based on Raymer's aircraft sizing approach- %
% equations and tables are referenced throughout the code.                %              %  
% Note 1:                                                                 % 
% This code does not have an engine-deck generation. Power is  obtained   % 
% from the P/W parameter and the engine sized accordingly. This is a      % 
% simplified way to get engine information and may need to be changed     % 
% according to desired studies/analyses.                                  % 
% Note 2:                                                                 % 
% The cabin (fuselage) layout is computed based on a series of parameters %
% that are listed in LayoutFunction.m. These must be changed if alternate % 
% cabin layout configurations are desired.                                % 
% Parithi Govindaraju - January 2016                                      %
% Brandonn Sells - EDITED JANUARY 2019                                    %

%% HOUSEKEEPING
clear all
clc

%% DESIGN MISSION PARAMETERS
MissionInputs.R           = 726;    % aircraft range [nmi]
MissionInputs.loiter_time = 0.5;   % loiter time [hours]
MissionInputs.pax         = 48;      % number of passengers   

%% ECONOMIC MISSION PARAMETERS
EconMission.range         = 500;    % economic mission length [nmi]

%% PERFORMANCE PARAMETERS
PerformanceInputs.PW   = 2400/41005;      % power-to-weight ratio [lb/hp]
PerformanceInputs.WS   = 41005/587;        % wing loading [lbs/ft^2]
PerformanceInputs.V    = 289;       % cruise velocity [knots]
PerformanceInputs.M    = 289/1.0381445e3;     % cruise velocity [Mach]. This needs to be changed to match V at desired altitude.  Can automate this calculation with the AtmosphereFunction
PerformanceInputs.Vlt  = 127.72;       % loiter velocity [knots]
PerformanceInputs.nmax = 3.75;      % maximum load factor
PerformanceInputs.hc   = 19685;      % cruise altitude [ft]
PerformanceInputs.hlt  = 5000;      % loiter altitude [ft]

%% GEOMETRY PARAMETERS
GeometryInputs.AR          = 11.08;         % wing aspect ratio
GeometryInputs.WingSweep   = 0;          % wing sweep (LE) [deg]
GeometryInputs.thick2chord = 0.1;       % wing thickness-to-chord ratio
GeometryInputs.TR          = 0.6;        % wing taper ratio
        
%% CONFIGURATION PARAMETERS
% These parameters and their default values are listed in the LayoutFunction.m file

%% AERODYNAMIC PARAMETERS
AeroInputs.Clmax   = 1.6;                  % maximum lift coefficient

%% PROPULSION PARAMETERS
PropulsionInputs.num_eng    = 2;           % number of engines
PropulsionInputs.n_rpm      = 1200;        % Rotational rate [rpm] obtained from engine data
PropulsionInputs.eta_p      = 0.75;        % Propeller efficiency
PropulsionInputs.c_bhp      = 0.5;        % Propeller specific fuel consumption [lb/hr] 

%% PAYLOAD PARAMETERS
PayloadInputs.crewnum    = 2;              % number of crew members (pilots)
PayloadInputs.paxweight  = 200;            % passenger weight (including luggage) [lbs]
PayloadInputs.crewweight = 180;            % crew member weight (including luggage) [lbs]

paxweight  = PayloadInputs.paxweight.*MissionInputs.pax;      % weight of passengers (including luggage) [lbs]
crewweight = PayloadInputs.crewweight*PayloadInputs.crewnum;  % weight of each crew member [lbs]
PayloadInputs.w_payload  = crewweight + paxweight;            % total payload weight
PayloadInputs.w_payload  = 11574; % economy
PayloadInputs.w_payload  = 10919; % full range
%% BATTERY PARAMETERS
BatteryInputs.energydensity = 450; % battery energy density [Wh/kg]
BatteryInputs.eta_e         = 0.931; % battery electric efficiency
BatteryInputs.batP_to       = 0; % portion of battery used in taxi/takeoff
BatteryInputs.batP_cl       = 0; % portion of battery used in climb
BatteryInputs.batP_cr       = 0; % portion of battery used in cruise
BatteryInputs.batP_dsc      = 0; % portion of battery used in descend
BatteryInputs.batP_lt       = 0; % portion of battery used in loiter
BatteryInputs.batP_lnd      = 0; % portion of battery used in landing/taxi
BatteryInputs.taxitime      = 10/60; % [hr]
BatteryInputs.totime        = 1/60; % [hr]
BatteryInputs.cltime        = 24/60; % [hr]
BatteryInputs.lndtime       = 10/60; % [hr]

%% AGGREGATED INPUTS FOR AIRCRAFT SIZING
inputs.MissionInputs     = MissionInputs;
inputs.EconMission       = EconMission;
inputs.PerformanceInputs = PerformanceInputs;
inputs.GeometryInputs    = GeometryInputs;
inputs.PayloadInputs     = PayloadInputs;
inputs.PropulsionInputs  = PropulsionInputs;
inputs.AeroInputs        = AeroInputs;
inputs.BatteryInputs     = BatteryInputs;

%% SIZE AIRCRAFT
   SizingOutput = SizingIterations(inputs);
SizingOutput.Cdoloiter
SizingOutput.Cdocruise
SizingOutput.Vloiter %ktas
%% ECONOMIC MISSION ANALYSIS
   EconMissionOutput = EconMissionFunction(SizingOutput);
   
%% PERFORMANCE ANALYSIS
   PerformanceOutput = PerformanceFunction(SizingOutput);
   
%% ACQUISITION COST ANALYSIS
%    AqCostOutput = AcquisitionCostFunction(SizingOutput);
   
%% OPERATING COST ANALYSIS  
%    OpCostOutput = OperatingCostFunction(SizingOutput,AqCostOutput,EconMissionOutput);
  
%% DISPLAY RESULTS
   FinalOutput              = SizingOutput;
%    FinalOutput.AqCostOutput = AqCostOutput;
%    FinalOutput.OpCostOutput = OpCostOutput;
  fprintf('%s \n','Final Aircraft')
   ReportFunction(FinalOutput);
   fprintf('%s \n','Economic Mission')
ReportFunction(EconMissionOutput);



