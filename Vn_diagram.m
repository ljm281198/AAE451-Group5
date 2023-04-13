function Vn_diagram(FinalOutput,PerformanceInputs,AeroInputs,inputs)
W_0 = FinalOutput.EmptyWeight.We;
TOGW = FinalOutput.TOGW;
Sw = FinalOutput.Sw; % Planform wing area [ft^2]


%n_plus for Part 25 regulations
n_plus = 2.1 + 24000/(W_0 + 10000)
if n_plus < 2.5
    n_plus = 2.5
end

Ve = linspace(0,320,320);
plot(Ve, n_plus*ones(1,length(Ve)),"--")
hold on

%n_minus
h_cruise = PerformanceInputs.hc;
V_cruise = PerformanceInputs.V;
V_cruise = TAS_to_EAS(V_cruise,h_cruise);

V_dive = V_cruise/0.8;    
% n_minus =                         %wait for email
% if n_minus > -1.0
%     n_minus = -1.0

%% n_plus_stall, n_minus_stall
% n_plus_stall
n_plus_stall = (0.00237691267925741/2) * (1.688)^2 * (Ve.^2 * AeroInputs.Clmax)/(FinalOutput.TOGW/Sw);
plot(Ve, n_plus_stall,"--")

% n_minus_stall
n_minus_stall = (0.00237691267925741/2) * (1.688)^2 * (Ve.^2 * AeroInputs.Clmax_minus)/(FinalOutput.TOGW/Sw);
plot(Ve, n_minus_stall,"--")

%% plot V_cruise and V_dive
%plot V_cruise
n_axis = linspace(-10,10,100);                      %indexes for plotting vertical lines
plot(V_cruise*ones(1,length(n_axis)),n_axis,"--")

%plot V_dive
plot(V_dive*ones(1,length(n_axis)),n_axis,"--")

end

function EAS = TAS_to_EAS(TAS,h) %converts True Air Speed to Equivalent Air speed (units does not matter, output same units as input)
    [a,mu,rho] = AtmosphereFunction(h)    
    EAS = TAS*sqrt(rho/0.00237691267925741); % 0.00237691267925741 = sea-level air density [slug/ft^3]
end

