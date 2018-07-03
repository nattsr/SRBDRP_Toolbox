function [image3D] = createSinusoidalPipe(nx,ny,nz,r0,ct,delta)
%createSinusoidalPipe creates a 3-D binary image of a sinusoidal pipe
%
%   Input Arguments
%   - nx     : an integer, number of pixel in x-direction
%   - ny     : an integer, number of pixel in y-direction
%   - nz     : an integer, number of pixel in z-direction
%   - r0     : an integer, initial radius
%   - ct     : an integer, center of the pipe
%   - delta  : an integer, fractional change in radius
%
%   Output Arguments
%   - image3D      : a (nx*ny*nz) uint8 matrix, 3-D binary image of 
%                    pore space (0 = pore, 1 = grain)

%   Revision 1: April 2016 Nattavadee Srisutthiyakorn
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)


%% Program

% Initialization
lambda = 2*r0;

% Grid meshing
[x, z] = meshgrid(1:nx, 1:nz);

t = linspace(0,4*pi*lambda,200);

% Equation
rr = r0*(1 + delta*sin(t./lambda));

for iSlice = 1:ny
    temp(iSlice,:,:) = sqrt((x - ct).^2 + (z - ct).^2) < rr(iSlice);
end

temp = qCBinary(temp);
image3D = abs(1-temp);




end