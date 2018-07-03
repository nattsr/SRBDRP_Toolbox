function [image3D] = createRectangle(nx,ny,nz,a,b,ct)
%createRectangle creates a 3-D binary image of a rectangle pipe
%
%   Input Arguments
%   - nx     : an integer, number of pixel in x-direction
%   - ny     : an integer, number of pixel in y-direction
%   - nz     : an integer, number of pixel in z-direction
%   - a      : an integer, semi-major axes
%   - b      : an integer, semi-minor axes
%   - ct     : an integer, center of a cylinder pipe
%
%   Output Arguments
%   - image3D      : a (ny*nx*nz) uint8 matrix, 3-D binary image of
%                    pore space (0 = pore, 1 = grain)
%
%   Note:
%       In order to run this code, qCBinary.m file is needed.

%   Revision 1: August 2014 Nattavadee Srisutthiyakorn
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)


%% Program

% Create the image
[x y z] = meshgrid(1:nx, 1:ny, 1:nz);
temp = and(abs(x-ct)<a/2,abs(z-ct)<b/2);
temp = qCBinary(temp);

% Output
image3D = abs(1-temp);

end