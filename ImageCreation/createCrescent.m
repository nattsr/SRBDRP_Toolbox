function [image3D] = createCrescent(nx,ny,nz,r0,phi,ct)
%createCrescent creates a 3-D binary image of a crescent pipe
%   
%   Input Arguments
%   - nx     : an integer, number of pixel in x-direction
%   - ny     : an integer, number of pixel in y-direction
%   - nz     : an integer, number of pixel in z-direction
%   - r0     : an integer, radius of a cylinder pipe that is required ..
%              to change the size of crescent pipe
%   - ct     : an integer, center of the pipe
%   - phi    : an integer, angle governing how curve the crescent pipe is
%
%
%   Output Arguments
%   - image3D      : a (ny*nx*nz) uint8 matrix, 3-D binary image of
%                    pore space (0 = pore, 1 = grain)
%
%   Note
%       (1) In order to run this code, qCBinary.m file is needed.
%       (2) the largest r within nx,nz = 100 is 24
%   Example
%       [Crescent] = createCrescent(100,200,100,24,pi/4,50);

%   Revision 1: August 2014 Nattavadee Srisutthiyakorn
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)



%% Program
% Initialziation
[x y z] = meshgrid(1:nx, 1:ny, 1:nz);
Area = pi*r0^2;
b = sqrt(Area./((2-(2.*cos(phi)).^2).*phi+sin(2.*phi))); %verified to give the same porosity
eps = cos(phi).*2;
a = b.*eps;

% Create the image
temp1 = sqrt((x-ct+b).^2 + (z-ct).^2) < a;
temp2 = sqrt((x-ct).^2 + (z-ct).^2) < b;
temp = temp2 - temp1;
temp = qCBinary(temp);

% Output
image3D = abs(1-temp);
end