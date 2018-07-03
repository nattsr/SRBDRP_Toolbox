function [ KCcorrection, phi_ssa ] = computeKCcorrection( PSD )
%computeKCcorrection compute the correction for the Kozeny-Carman equation
%   Input Argument
%   - PSD          : a vector (nVoxel), the pore size distribution along
%                    the flow path
%   Output Argument
%   - KCcorrection : a double, the value needed for correction from
%                    Kozeny-Carman permeability to Lattice Boltzmann
%                    Permeability
%   Note


%% Program
% Initialization
PSD  = PSD(:);
% Remove the number 0
PSD = PSD(PSD ~= 0);
nPSD = length(PSD);

% compute the approximate surface area using a frustum formula
for iPSD = 2:nPSD
    r1 = PSD(iPSD-1);
    r2 = PSD(iPSD);
    saSlice(iPSD-1) = pi.*(r2 + r1).*sqrt((r2-r1).^2 + 1^2);
    % The discretization is 1 voxel at a time
end

pv = pi.*sum(PSD.^2);       % Pore volume
sa = sum(saSlice);          % Surface Area

phi_ssa = pv/sa;            % Pore volume/Surface area ratio

% calculate the hydraulic radius
rH = 2.*pv./sa;

% calculate the equivalent radius of a circular pipe that has the same
% porosity
rC = sqrt(sum(PSD.^2)/nPSD);

% calculate the apparent radius (same definition as the Kozeny-Carman)
rA = sqrt(rH.*rC);

% calculate permeability ratio
% Definition:
% permTheo = pi*L/(8*A*l*sum(1./(rr*dl).^4))*m2tomD;
% permKC = pi.*(rA.*dl).^4./(8.*A).*m2tomD;

permTheo = nPSD./(sum(1./PSD.^4));
permKC = (rA).^4;

% the correction
KCcorrection = permTheo./permKC;


end
