function [ PSD ] = modelPSD( nX, yMin, yMax)
%modelPSD create different model of pore size distribution


% model 1 straight line
PSD{1} = linspace(yMin, yMax, nX);

% model 2 sinusoidal 
xRange = linspace(3*pi/2, 5*pi/2, nX);
yEqn   = sin(xRange);
% transpose the equation to the specified range
PSD{2} = ((yMax-yMin)/(max(yEqn) - min(yEqn))*(yEqn - min(yEqn))) + yMin; 

% model 3 gauss error equation
xRange = linspace(-2,2,nX);
yEqn   = erf(xRange);
% transpose the equation to the specified range
PSD{3} = ((yMax-yMin)/(max(yEqn) - min(yEqn))*(yEqn - min(yEqn))) + yMin;

% model 4 sinusoidal 
xRange = linspace(2*pi/2, 4*pi/2, nX);
yEqn   = sin(xRange);
% transpose the equation to the specified range
PSD{4} = -(PSD{2} - PSD{1}) + PSD{1};

% model 5 gauss err flip curvature
PSD{5} = -(PSD{3} - PSD{1}) + PSD{1};

end

