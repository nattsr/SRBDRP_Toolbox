function [image3D] = createHypotrochoid(nx,ny,nz,r,k,ct)
%createHypotrochoid create a 3-D binary image of a hypotrochoidal pipe
%
%   Input Arguments
%   - nx     : an integer, number of pixel in x-direction
%   - ny     : an integer, number of pixel in y-direction
%   - nz     : an integer, number of pixel in z-direction
%   - r      : an integer, radius of the hypotrochoid
%   - k      : an integer, number of sides
%   - ct     : an integer, center of a cylinder pipe
%
%   Output Arguments
%   - image3D      : a (ny*nx*nz) uint8 matrix, 3-D binary image of
%                    pore space (0 = pore, 1 = grain)
%
%   Note:
%       (1) In order to run this code, qCBinary.m file is needed.
%       (2) For more information, http://mathworld.wolfram.com/Hypocycloid.html

%   Revision 1: August 2014 Nattavadee Srisutthiyakorn
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)


%% Program
% Create the image
[x y z] = meshgrid(1:nx, 1:ny, 1:nz);
theta = linspace(0,2*pi,200);

a = sqrt(1/2).*r; % valid for k =3;
for t=1:ny
    xv(t) = (k-1)*a*cos(theta(t)) + a*cos((k-1)*theta(t)) + ct;
    zv(t) = (k-1)*a*sin(theta(t)) - a*sin((k-1)*theta(t)) + ct;
end

for j = 1:ny
    temp(:,j,:) = inpolygon(x(:,j,:),z(:,j,:),xv,zv);
end
temp = qCBinary(temp);

% Output
image3D = abs(1-temp);

end