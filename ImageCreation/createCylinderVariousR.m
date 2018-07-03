function [image3D] = createCylinderVariousR(nx,ny,nz,R,ct)
%createCylinder creates a 3-D binary image of a round pipe
%
%   Input Arguments
%   - nx     : an integer, number of pixel in x-direction
%   - ny     : an integer, number of pixel in y-direction
%   - nz     : an integer, number of pixel in z-direction
%   - R      : a vector, radius of a cylinder pipe
%   - ct     : an integer, center of a cylinder pipe
%
%   Output Arguments
%   - image3D      : a (ny*nx*nz) uint8 matrix, 3-D binary image of
%                    pore space (0 = pore, 1 = grain)
%
%   Note:
%       In order to run this code, qCBinary.m file is needed.

%   Revision 1: August 2016 Nattavadee Srisutthiyakorn
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)


%% Program
% Grid meshing
[x, z] = meshgrid(1:nx, 1:nz);

for iSlice = 1:ny
    temp(iSlice,:,:) = sqrt((x - ct).^2 + (z - ct).^2) < R(iSlice);
end

temp = qCBinary(temp);
image3D = abs(1-temp);


end