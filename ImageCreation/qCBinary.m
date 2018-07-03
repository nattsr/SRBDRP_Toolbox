function [ image3DQC ] = qCBinary( image3D )
%qCBinary QC the image after any mathematical operation that it is binary.
%
%   Input Arguments
%   - image3D      : a (nx*ny*nz) uint8 matrix, 3-D binary image of 
%                    pore space to be checked (0 = pore, 1 = grain)
%
%   Output Arguments
%   - image3DQC    : a (nx*ny*nz) uint8 matrix, 3-D binary image of 
%                    pore space (0 = pore, 1 = grain)

%   Revision 2: December  2015 Nattavadee Srisutthiyakorn (more efficient)
%   Revision 1: September 2014 Nattavadee Srisutthiyakorn (QCbinary.m)
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)



%% Program
% Find the size
[nx, ny, nz]    = size(image3D);

% Replace any value greater than 1 with 1
tempImage       = image3D(:);
tempImage(tempImage > 1) = 1;

% Reshape back into the same shape
image3DQC       = reshape(tempImage,[nx, ny, nz]);


