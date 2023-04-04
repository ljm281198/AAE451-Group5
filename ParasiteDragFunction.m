% Function that computes parasite drag coefficient.
% The approach used here is Based on Raymer Ch.12 and uses the Equivalent
% skin friction coefficient to estimate the parasite drag coefficient.
% Other methods that do a more accurate drag-build-up should replace the
% approach used here.

function Cdo = ParasiteDragFunction(inputs)
%% Inputs
  Sw = inputs.GeometryOutput.Sw; % Planform wing area [ft^2]
  
% % Equivalent skin friction coefficient (based on Raymer Ch.12 Table 12.3)
% Cfe = 0.0055;    % Light aircraft - SINGLE engine

%%  Gavin's stupid code
%Parasite drag

%reynolds number
Re = 1111; %!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%skin friction coefficient
Cf = 0.455/(lon10(Re)^2.58

%% Fuselage
fuselage_length = 1 %!!!!!!!!!!!!!!!!!!!!!!!!!!!!
fuselage_dia = 1 %!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%fuselage fineness ratio
lamda_f = fuselage_length/fuselage_dia

%wetted area
S_wet_fuse = pi*fuselage_dia*fuselage_length*((1 - 2/lamda_f)^(2/3))*(1 + 1/lamda_f^2)

%fuselage formfactor
FF_fuse = 0.9 + 5/lamda_f^1.5 + lamda_f/400

CD0_fuse = FF_fuse*Cf*S_wet_fuse/Sw

%% Nacelles
nace_length = 1 %!!!!!!!!!!!!!!!!!!!!!!!!!!!!
nace_dia = 1 %!!!!!!!!!!!!!!!!!!!!!!!!!!!!
S_wet_nace = pi*nace_dia*nace_length

%nacelles (engine) formfactor
FF_nace = 1 + 0.35/(nace_length/nace_dia)
nace_num = 2 %number of nacelles, two engines, not propellers

%interference factor for nacelles
Qn_nace = 1.0   %from Raymer Pg 

CD0_nace = nace_num*FF_nace*Cf*S_wet_nace/Sw

%% propellers, see source


%% wings
%wetted area
S_wet_wing = Sw*2*1.02



%Form Factor
%sweep correction factor, assume zero wing sweep
mach = 0.6      %!!!!!!!!!
z = (2-mach^2)*cos(0) / sqrt(1- (mach^2) * cos(0)^2)

%wing form factor, from shevell
t_over_c = 0.1      %thickness to chord ratio!!!!!!!!
FF_w = 1 + z(t_over_c) + 100(t_over_c)^4


%interference factor for wings
Qn_w = 1.0  

CD0_wing = FF_w*Qn_w*Cf*S_wet_wing/Sw;

%interference factor for T-tail
Q_H = 1.04 

Q_V


%% Misc

CD0_leak = 0.08*CD0_comp

CD0_strut = 0.05;   %streamlined strut, Raymer Table 12.6

CD0_bogey = 1.40;   %bogey, Only when gear is deployed!!!

% Parasite Drag coefficient
%Cdo = Cfe*inputs.GeometryOutput.Swet/inputs.GeometryOutput.Sw; 
Cdo = CD0_fuse + CD0_nace + CD0_wing + CD0_leak + CD0_strut; %missing tails and effects of wing mounted props
end