% Function that estimates the Oswald Efficiency Factor
% Simplest approach presented in Raymer Ch.12 Section 12.6.
% Recommended to modify for more accuracy between different designs.
function e0 = OswaldEfficiency(inputs)

%% Inputs
TR     = inputs.GeometryInputs.TR;               % wing taper ratio
df     = inputs.LayoutOutput.df;                 % fuselage diameter [ft]
AR     = inputs.GeometryInputs.AR;               % wing aspect  ratio
Lambda = inputs.GeometryInputs.WingSweep*pi/180; % wing sweep [rad]
b      = inputs.GeometryOutput.b;                % wing span [ft]
Cdo    = inputs.Aero.Cdo;                        % Parasite drag coefficient
%%
%%

% e0 = 1.78*(1-0.045*AR^0.68)-0.64; % eqn 12.48 Raymer
e0 = 0.9912 - 0.02*(100*Cdo) - 0.0804*(AR/12) + 0.0026*(100*Cdo)^2 - 0.0831*(100*Cdo)*(AR/12) + 0.0432*(AR/12)^2; % Shevell empirical fit fr
e0 = 0.92;
% lecture
end