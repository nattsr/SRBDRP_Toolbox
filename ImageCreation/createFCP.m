function [ image3D ] = createFCP( cubeLength, nUnitCell, grainDilationRatio )
%createFCP creates a 3D image face-centered cubic pack
%   
%   Input Arguments
%   - cubeLength   : an integer, length of a 3D image cube in pixel 
%                    (cubeLength = nx = ny = nz)
%   - nUnitCell    : an integer, number of unit cell of the size, 
%                    for example, nUnitcell = 2 resulting in 2^3 unit cells 
%                    in 3-D images
%                   (Default: 1 for unit cell of SCP)
%   - grainDilationRatio 
%                  : an integer, the size of sphere in relation to
%                    the original one. If it's greater than 1 then the 
%                    spheres overlap
%                    (Default: 1 = using the original radius of spheres)
%
%   Output Arguments
%   - image3D      : a (nx*ny*nz) uint8 matrix, 3-D binary image of a
%                    face-centered cubic pack (0 = pore, 1 = grain)
%
%   Note
%   - need to use qCBinary.m

%   Revision 1: March 2016 Nattavadee Srisutthiyakorn
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)
%% QC Inputs
if nargin < 2
    nUnitCell = 1;
    grainDilationRatio = 1;
end 
if nargin < 3
    grainDilationRatio = 1;
end 


%% Initialization
unitCellLength = ceil(cubeLength./nUnitCell);

sphereRadius = ceil(unitCellLength./(2*sqrt(2)));
midpt = floor(unitCellLength/2);
endpt = unitCellLength;

edgeCT  = [ 0       0       0;
            endpt   0       0;
            0       endpt   0;
            0       0       endpt;
            endpt   endpt   0;
            endpt   0       endpt;
            0       endpt   endpt;
            endpt   endpt   endpt];

midCT   = [ 0       midpt   midpt;
            midpt   0       midpt;
            midpt   midpt   0;
            endpt   midpt   midpt;
            midpt   endpt   midpt;
            midpt   midpt   endpt;];

% Create a mesh
[x, y, z]   = meshgrid(1:unitCellLength, 1:unitCellLength, 1:unitCellLength);

image3DUnit = zeros(unitCellLength, unitCellLength, unitCellLength);

% Filling in spheres at the edge
for iSphere = 1:8
    tempImage   = sqrt((x - edgeCT(iSphere,1)).^2 + (y - edgeCT(iSphere,2)).^2 ...
                + (z - edgeCT(iSphere,3)).^2) < sphereRadius.*grainDilationRatio;
    image3DUnit = image3DUnit + tempImage;
end

% Filling in spheres at the middle
for iSphere = 1:6
    tempImage   = sqrt((x - midCT(iSphere,1)).^2 + (y - midCT(iSphere,2)).^2 ...
                + (z - midCT(iSphere,3)).^2) < sphereRadius.*grainDilationRatio;
    image3DUnit = image3DUnit + tempImage;
end

% QC the overlap
image3DUnit = qCBinary(image3DUnit);

% Expand the unit cell
if nUnitCell > 1
    image3D = expandUnitCell( image3DUnit, nUnitCell);
    image3D = image3D(1:cubeLength,1:cubeLength,1:cubeLength);
else
    image3D = image3DUnit;
end

    
end

