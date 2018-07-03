function [ image3D ] = createSCP( cubeLength, nUnitCell, grainDilationRatio )
%createSCP creates a 3D image of simple cubic pack
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
%   - image3D      : a (nx*ny*nz) uint8 matrix, 3-D binary image of 
%                    pore space (0 = pore, 1 = grain)
%
%   Note
%   - need to use qCBinary.m

%   Revision 1: December 2015 Nattavadee Srisutthiyakorn
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)
%% QC Inputs
if nargin < 2
    nUnitCell = 1; 
    grainDilationRatio = 1;
end 


%% Initialization
unitCellLength = ceil(cubeLength./nUnitCell);

sphereRadius = unitCellLength/2;
endpt = unitCellLength;

CT      = [ 0       0       0;
            endpt   0       0;
            0       endpt   0;
            0       0       endpt;
            endpt   endpt   0;
            endpt   0       endpt;
            0       endpt   endpt;
            endpt   endpt   endpt];

% Create a mesh
[x, y, z]   = meshgrid(1:unitCellLength, 1:unitCellLength, 1:unitCellLength);

image3DUnit = zeros(unitCellLength, unitCellLength, unitCellLength);

% Filling in the identical spheres
for iSphere = 1:8
    tempImage   = sqrt((x - CT(iSphere,1)).^2 + (y - CT(iSphere,2)).^2 ...
                + (z - CT(iSphere,3)).^2) < sphereRadius.*grainDilationRatio;
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

