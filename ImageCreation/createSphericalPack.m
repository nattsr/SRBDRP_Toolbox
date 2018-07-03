function [ image3D ] = createSphericalPack( locationX, locationY, locationZ,...
                                            radius, cubeSize )
%createSphericalPack creates a 3-D binary image of a sphere pack
%   
%   Input Arguments
%   - locX         : a (nSph*1) double vector, x coordinate location
%   - locY         : a (nSph*1) double vector, y coordinate location
%   - locZ         : a (nSph*1) double vector, z coordinate location
%   - radius       : a (nSph*1) double vector, radius of a sphere
%   - cubeSize     : an integer, size of the pack 
%                    (Example: cubeSize = 200 -> 200^3 px cube;
%
%   Output Arguments
%   - image3D      : a (nx*ny*nz) int8 matrix, 3-D binary image of a
%                    rock (0 = pore, 1 = grain)
%
%   Revision 1: January 2016 Nattavadee Srisutthiyakorn
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)


%% Program 
% Initialization
bufferZone  = 10;
nz          = cubeSize + bufferZone*2; 

% Find the dimension of this pack
minVec = [min(locationX) min(locationY) min(locationZ)];
maxVec = [max(locationX) max(locationY) max(locationZ)];

% Scaling the cube size
locationX    = locationX.*nz./maxVec(1);
locationY    = locationY.*nz./maxVec(2);
locationZ    = locationZ.*nz./maxVec(3);
radius  = radius.*nz./maxVec(1);

% Create the geometry
[x, y, z] = meshgrid(1:nz, 1:nz, 1:nz);
tempImage = zeros(nz,nz,nz);

for iSph = 1:size(radius,1)
    tempSph = sqrt((x - locationX(iSph)).^2 ...
                 + (y - locationY(iSph)).^2 ...
                 + (z - locationZ(iSph)).^2) < radius(iSph);
    tempImage = tempImage + tempSph;
end

tempImage = qCBinary(tempImage);

% Output
image3D = int8(tempImage(11:cubeSize + bufferZone, ...
                         11:cubeSize + bufferZone, ...
                         11:cubeSize + bufferZone));
    
    
end

