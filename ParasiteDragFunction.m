% Function that computes parasite drag coefficient.
% The approach used here is Based on Raymer Ch.12 and uses the Equivalent
% skin friction coefficient to estimate the parasite drag coefficient.
% Other methods that do a more accurate drag-build-up should replace the
% approach used here.

function Cdo = ParasiteDragFunction(inputs,cruiseLoiter)
%% Inputs
  Sw = inputs.GeometryOutput.Sw; % Planform wing area [ft^2]
  
  
% % Equivalent skin friction coefficient (based on Raymer Ch.12 Table 12.3)
% Cfe = 0.0055;    % Light aircraft - SINGLE engine

%%  Gavin's stupid code
%Parasite drag

%reynolds number parameters
rho = 0;
mu = 0;
V = 0;
a = 0;
mach = 0;
if strcmp(cruiseLoiter,"cruise")
    inputs.Aero.h = inputs.PerformanceInputs.hc;       % cruise altitude [ft]
    [a,mu,rho] = AtmosphereFunction(inputs.Aero.h)
    V = inputs.PerformanceInputs.V*1.68781                           %cruise speed [ft/s]
    mach = V/a                                          %mach number
elseif strcmp(cruiseLoiter,"loiter")
    V = inputs.PerformanceInputs.Vlt*1.68781;           % Loiter velocity [ft/s]
    inputs.Aero.h = inputs.PerformanceInputs.hlt;       % Loiter altitude [ft]
    [a,mu,rho] = AtmosphereFunction(inputs.Aero.h)
    mach = V/a                                          %mach number
end
    




%% Fuselage
fuselage_length = inputs.LayoutOutput.lf %[ft]
fuselage_dia = inputs.LayoutOutput.df %[ft]
%fuselage fineness ratio
lamda_f = fuselage_length/fuselage_dia

%wetted area
S_wet_fuse = pi*fuselage_dia*fuselage_length*((1 - 2/lamda_f)^(2/3))*(1 + 1/lamda_f^2)

%fuselage formfactor
FF_fuse = 0.9 + 5/lamda_f^1.5 + lamda_f/400

%Reynolds number for fuselage
Re_f = rho*V*fuselage_length/mu;

%skin friction coefficient fuselage
Cf_fuse = 0.455/(log10(Re_f)^2.58)

CD0_fuse = FF_fuse*Cf_fuse*S_wet_fuse/Sw

%% Nacelles
nace_length = inputs.GeometryOutput.le  %[ft]
nace_dia = inputs.GeometryOutput.de     %[ft]
S_wet_nace = inputs.GeometryOutput.Sweteng

%nacelles (engine) formfactor
FF_nace = 1 + 0.35/(nace_length/nace_dia)
nace_num = 2 %number of nacelles, two engines, not propellers

%interference factor for nacelles
Qn_nace = 1.0   %from Raymer Pg 

%Reynolds number for Nacelles
Re_nace = rho*V*nace_length/mu;

%skin friction coefficient Nacelles
Cf_fuse = 0.455/(log10(Re_nace)^2.58)

CD0_nace = Qn_nace*nace_num*FF_nace*Cf_fuse*S_wet_nace/Sw

%% propellers, see source


%% wings

%Form Factor
%sweep correction factor, assume zero wing sweep
z = (2-mach^2)*cos(0) / sqrt(1- (mach^2) * cos(0)^2)

%wing form factor, from shevell
t_over_c = 0.1      %thickness to chord ratio!!!!!!!!!!!!!!!!!!!
FF_w = 1 + z*(t_over_c) + 100*(t_over_c)^4

%Reynolds number for wing
MAC = inputs.GeometryOutput.MAC;        %mean aerodynamic cord of wing
Re_wing = rho*V*MAC/mu;

%skin friction coefficient wing
Cf_wing = 0.455/(log10(Re_wing)^2.58)

%interference factor for wings
Qn_w = 1.0  

CD0_wing = FF_w*Qn_w*Cf_wing*inputs.GeometryOutput.Swetwing/Sw;

%from Xflir
% CD0_wing = 0.0057;
%% horizontal tail
%interference factor for T-tail
Q_H = 1.04

%sweep correction factor, assume zero wing sweep
z_tailH = (2-mach^2)*cos(0) / sqrt(1- (mach^2) * cos(0)^2)

%tail horizontal form factor, from shevell
t_over_c_tailH = 0.1                              %thickness to chord ratio!!!!!!!!!!!!!!!!!!!
FF_tailH = 1 + z_tailH*(t_over_c_tailH) + 100*(t_over_c_tailH)^4

%Reynolds number for tail horizontal
MAC = inputs.GeometryOutput.MAC;        %mean aerodynamic cord of tail horizontal!!!!!!!!!!
Re_tailH = rho*V*MAC/mu;

%skin friction coefficient wing
Cf_tailH = 0.455/(log10(Re_tailH)^2.58)

CD0_tailH = FF_tailH*Q_H*Cf_tailH*inputs.GeometryOutput.Sh/Sw; %total parasite drag from tail horizontal

%from Xflir
% CD0_tailH = 0.00490;

%% Vertical tail
%interference factor for T-tail
Q_V = 1.04

%sweep correction factor, assume zero wing sweep
z_tailV = (2-mach^2)*cos(0) / sqrt(1- (mach^2) * cos(0)^2)

%tail horizontal form factor, from shevell
t_over_c_tailV = 0.1                              %thickness to chord ratio!!!!!!!!!!!!!!!!!!!
FF_tailV = 1 + z_tailV*(t_over_c_tailV) + 100*(t_over_c_tailV)^4

%Reynolds number for tail horizontal
MAC = inputs.GeometryOutput.MAC;        %mean aerodynamic cord of tail horizontal!!!!!!!!!!
Re_tailV = rho*V*MAC/mu;

%skin friction coefficient wing
Cf_tailV = 0.455/(log10(Re_tailV)^2.58)

CD0_tailV = FF_tailV*Q_V*Cf_tailV*inputs.GeometryOutput.Sv/Sw; %total parasite drag from tail horizontal

%from Xflir
% CD0_tailV = 0.00490;
%% Misc
CD0_strut = 0.05;   %streamlined strut, Raymer Table 12.6 (Causing a BIG Raise in CD0)!!!!!!!!!!

CD0_bogey = 1.40;   %bogey, Only when gear is deployed!!!

%% Parasite Drag coefficient
%Cdo = Cfe*inputs.GeometryOutput.Swet/inputs.GeometryOutput.Sw; 
Cdo = CD0_fuse + CD0_nace + CD0_wing + CD0_strut + CD0_tailH + CD0_tailV %total parasite drag of whole aircraft
end