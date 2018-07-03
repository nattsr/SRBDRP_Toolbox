function [image3D] = createEqTriangle(nx,ny,nz,t,ct)
%createEqTriangle creates a 3-D binary image of an equilateral triangle pipe
%
%   Input Arguments
%   - nx     : an integer, number of pixel in x-direction
%   - ny     : an integer, number of pixel in y-direction
%   - nz     : an integer, number of pixel in z-direction
%   - t      : an integer, length of equilateral triangle
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
c = t/2;
d = sqrt(3)*t/2;
temp1 = and(and(abs(x-ct+t/4)<c/2,abs(z-ct)<d/2),z < d/c*(x-ct+t/4) + ct );
temp2 = and(and(abs(x-ct-t/4+1)<c/2,abs(z-ct)<d/2),z < -d/c*(x-ct-t/4) + ct );
temp = temp1+temp2;
temp = qCBinary(temp);

% Output
image3D = abs(1-temp);
end

