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
clear
clc

%% DESIGN MISSION PARAMETERS
MissionInputs.R           = 726;    % aircraft range [nmi]
MissionInputs.loiter_time = .5;   % loiter time [hours]
%EASA
MissionInputs.pax         = 48;      % number of passengers   

%% ECONOMIC MISSION PARAMETERS
EconMission.range         = 500;    % economic mission length [nmi]

%% PERFORMANCE PARAMETERS
PerformanceInputs.PW   = 2400/41005;      % power-to-weight ratio [lb/hp] this is actually hp/lb
%2400/41005
PerformanceInputs.WS   = 41005/587;        % wing loading [lbs/ft^2]
%41005/587 
PerformanceInputs.V    = 289;       % cruise velocity [knots]
PerformanceInputs.M    = 289/1.038144511790146e+03;     % cruise velocity [Mach]. This needs to be changed to match V at desired altitude.  Can automate this calculation with the AtmosphereFunction
PerformanceInputs.Vlt  = 127.72;       % loiter velocity [knots]
%calcualtion v endurance 
PerformanceInputs.nmax = 3.75;      % maximum load factor
PerformanceInputs.hc   = 19,685;      % cruise altitude [ft]
%https://www.airtahiti.com/en/atr
PerformanceInputs.hlt  = 5000;      % loiter altitude [ft]
%chosen to just be 1/4 
%% GEOMETRY PARAMETERS
GeometryInputs.AR          = 11.08;         % wing aspect ratio
GeometryInputs.WingSweep   = 0;          % wing sweep (LE) [deg]
GeometryInputs.thick2chord = 0.1;       % wing thickness-to-chord ratio
%https://www.researchgate.net/figure/Shape-of-the-ATR-42-wing-airfoil_fig1_288838645
GeometryInputs.TR          = 0.6;        % wing taper ratio
%rough estimate
%% CONFIGURATION PARAMETERS
% These parameters and their default values are listed in the LayoutFunction.m file

%% AERODYNAMIC PARAMETERS
AeroInputs.Clmax   = 1.66;                  % maximum lift coefficient

%% PROPULSION PARAMETERS
PropulsionInputs.num_eng    = 2;           % number of engines
PropulsionInputs.n_rpm      = 1200;        % Rotational rate [rpm] obtained from engine data
%https://www.pwc.ca/en/products-and-services/products/regional-aviation-engines/pw100-150
PropulsionInputs.eta_p      = 0.85;        % Propeller efficiency
PropulsionInputs.c_bhp      = 0.459;        % Propeller specific fuel consumption [lb/hr] 
%https://en.wikipedia.org/wiki/Pratt_%26_Whitney_Canada_PW100
%% PAYLOAD PARAMETERS
PayloadInputs.crewnum    = 3;              % number of crew members (pilots)
PayloadInputs.paxweight  = 240;            % passenger weight (including luggage) [lbs]
PayloadInputs.crewweight = 220;            % crew member weight (including luggage) [lbs]

%paxweight  = 10054.8;      % weight of passengers (including luggage) [lbs] for 726 nmi calc comparison 
paxweight  = PayloadInputs.paxweight*MissionInputs.pax;     % weight of passengers (including luggage) [lbs] use for normal calc
crewweight = PayloadInputs.crewweight*PayloadInputs.crewnum;  % weight of each crew member [lbs]
PayloadInputs.w_payload  = crewweight + paxweight;            % total payload weight
PayloadInputs.w_payload  = 11574;            % total payload weight for max takeoff calculations


%% AGGREGATED INPUTS FOR AIRCRAFT SIZING
inputs.MissionInputs     = MissionInputs;
inputs.EconMission       = EconMission;
inputs.PerformanceInputs = PerformanceInputs;
inputs.GeometryInputs    = GeometryInputs;
inputs.PayloadInputs     = PayloadInputs;
inputs.PropulsionInputs  = PropulsionInputs;
inputs.AeroInputs        = AeroInputs;

%% SIZE AIRCRAFT
   SizingOutput = SizingIterations(inputs);

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
   ReportFunction(FinalOutput);

EconMissionOutput
%reads the econ mission



