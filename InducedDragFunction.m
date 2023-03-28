%% Fuction that computes Induced drag coefficient

function [Cdi,CL] = InducedDragFunction(inputs,Wi)

%% Inputs
  Sw = inputs.GeometryOutput.Sw; % Planform wing area [ft^2]
  AR = inputs.GeometryInputs.AR; % Wing Aspect ratio
  e0 = inputs.Aero.e0;           % Oswald Efficiency Factor
  V  = inputs.Aero.V;            % Velocity [knots]
  h  = inputs.Aero.h;            % Altitude [ft]
%%

% Units conversion [knots -> ft/sec]

  v = V*1.68781;
% Atmosphere at loiter altitude (speed of sound, viscosity, density)
  [a,mu,rho] = AtmosphereFunction(h);

% Dynamic pressure
  q = 0.5*rho*v^2;

%%  Gavin's stupid code
%Parasite drag

%reynolds number
Re = 1111; %!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%skin friction coefficient
Cf = 0.455/(lon10(Re)^2.58

%Fuselage
fuselage_length = 1 %!!!!!!!!!!!!!!!!!!!!!!!!!!!!
fuselage_dia = 1 %!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%fuselage fineness ratio
lamda_f = fuselage_length/fuselage_dia

%wetted area
S_wet_fuse = pi*fuselage_dia*fuselage_length*((1 - 2/lamda_f)^(2/3))*(1 + 1/lamda_f^2)

%fuselage formfactor
FF_fuse = 0.9 + 5/lamda_f^1.5 + lamda_f/400
 
%Nacelles
nace_length = 1 %!!!!!!!!!!!!!!!!!!!!!!!!!!!!
nace_dia = 1 %!!!!!!!!!!!!!!!!!!!!!!!!!!!!
S_wet_nace = pi*nace_dia*nace_length

%nacelles formfactor
FF_nace = 1 + 0.35/(nace_length/nace_dia)
nace_num = 8 %number of nacelles

%wings
%wetted area
S_w = 54    %planform area!!!!!!!!!
S_wet_wing = S_w*2*1.02

%Form Factor
%sweep correction factor, assume zero wing sweep
mach = 0.6      %!!!!!!!!!
z = (2-mach^2)*cos(0) / sqrt(1- (mach^2) * cos(0)^2)

%wing form factor, from shevell
t_over_c = 0.1      %thickness to chord ratio!!!!!!!!
FF_w = 1 + z(t_over_c) + 100(t_over_c)^4



  

%% Lift Coefficient for flight conditions
  CL = Wi/q/Sw;

% Induced Drag Coefficient 
  Cdi = CL^2./(pi*AR*e0);    
  
end
  