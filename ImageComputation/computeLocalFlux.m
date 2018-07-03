function [ uX, uY, uZ, absU ] = computeLocalFlux( u )
%computeLocalFlux transforms a local flux matrix into its components xyz 
%
%   Input Arguments
%   - u(x,y,z,t)   : a (nx*ny*nz*nt) uint8 matrix, a local flux where x,y,z
%                    are the location, and t indicates direction (x = 1, y
%                    = 2, z = 3)
%
%   Output Arguments
%   - uX           : a (nx*ny*nz) uint8 matrix, flux in x direction
%   - uY           : a (nx*ny*nz) uint8 matrix, flux in y direction
%   - qz           : a (nx*ny*nz) uint8 matrix, flux in z direction
%   - qq           : a (nx*ny*nz) uint8 matrix, absolute flux magnitude

%
%   Revision 1: January 2015 Nattavadee Srisutthiyakorn
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)
%% 
% Finding uX, uY, uZ
uX = u(:,:,:,1);
uY = u(:,:,:,2);
uZ = u(:,:,:,3);

% Flux absolute magnitude
absU = sqrt(u(:,:,:,1).^2+u(:,:,:,2).^2+u(:,:,:,3).^2);
    
    
end

