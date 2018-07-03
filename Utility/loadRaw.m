function [ image3D ] = loadRaw( fileName, nx, ny, nz, format)
%loadRaw load 3-D binary matrix into matlab with specified format
%   Input Arguments
%   - fileName     : a string, file name with '.raw' 
%   - nx           : an integer, number of pixel in x-direction
%   - ny           : an integer, number of pixel in y-direction
%   - nz           : an integer, number of pixel in z-direction
%   - format       : a string, format of 3-D binary image
%                       'uint8'  for a binary image
%                       'uint16' for a gray scale image
%
%   Output Argument
%   - image3D      : a (ny*nx*nz) uint8 matrix, 3-D binary image of
%                    pore space (0 = pore, 1 = grain)
%
%   Example
%   cylinderL200 = loadRaw('cylinderL200.raw', 200, 100, 100, 'uint8');

%   Revision 1: June 2016 Nattavadee Srisutthiyakorn


%% Program
% Open the file
fileID  = fopen(fileName);

% QC Inputs
if nargin < 5
    disp('Missing the format, assume that the image is uint8')
    format = 'uint8';
end

% Read the image
if nargin < 2
    disp('Missing geometry (nx, ny, nz), assume that the image is a 3-D cube with nx = ny = nz')
    tempImage = fread(fileID, [format,'=>',format]);
    nx = real(round((length(tempImage)).^(1/3)));
    ny = nx;
    nz = nx;
else
    tempImage = fread(fileID, nx*ny*nz, [format,'=>',format]);
end     

% Reshape the image
image3D   = reshape(tempImage, nx, ny, nz);

fclose(fileID);



