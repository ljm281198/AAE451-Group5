function Vn_diagram(FinalOutput,PerformanceInputs)
W_0 = FinalOutput.EmptyWeight.We;

%n_plus for Part 25 regulations
n_plus = 2.1 + 24000/(W_0 + 10000)
if n_plus < 2.5
    n_plus = 2.5
end

Ve = linspace(0,100,100);
plot(Ve, n_plus*ones(1,length(Ve)),"--")

%n_minus
h_cruise = PerformanceInputs.hc;
V_cruise = PerformanceInputs.V;
V_cruise = TAS_to_EAS(V_cruise,h_cruise);

% V_dive = V_cruise/0.8;    %wait for email
% n_minus = 
% if n_minus > -1.0
%     n_minus = -1.0


end

function EAS = TAS_to_EAS(TAS,h) %converts True Air Speed to Equivalent Air speed (units does not matter, output same units as input)
    [a,mu,rho] = AtmosphereFunction(h)    
    EAS = TAS*sqrt(rho/0.00237691267925741); % 0.00237691267925741 = sea-level air density [slug/ft^3]
end

