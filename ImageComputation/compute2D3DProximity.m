function [ Proximity2D, Proximity3D ] ...
    = compute2D3DProximity( image3D )
%computeStreamlines2D3DProximity extracts proximity to the nearest solid
%
%   Input Arguments
%   - image3D         : a (nx*ny*nz) uint8 matrix, 3-D binary image of 
%                       pore space (0 = pore, 1 = grain)
%
%   Output Arguments
%   - Proximity2D     : a (nx*ny*nz) uint8 matrix, 3-D double image of 
%                       2-D proximity (0 = pore, 1 = grain)       
%   - Proximity3D     : a (nx*ny*nz) uint8 matrix, 3-D double image of 
%                       3-D proximity (0 = pore, 1 = grain)    

%   Revision 1: April    2016 Nattavadee Srisutthiyakorn
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)



%% Program
% Rotate matrix into the the flow along x direction
[nx, ny, nz] = size(image3D);
for iSlice = 1:nx
    image3DRot(:,:,iSlice) = reshape(image3D(iSlice,1:ny,1:nz),ny,nz);
end

% Find the distance matrix in 2D, 3D
Proximity3D = bwdist(image3DRot,'euclidean');
Proximity2D = zeros(ny, nz, nx);

for iSlice = 1:nx
    image2D = image3DRot(:,:,iSlice);
    Proximity2D(:,:,iSlice) = bwdist(image2D,'euclidean');
end



