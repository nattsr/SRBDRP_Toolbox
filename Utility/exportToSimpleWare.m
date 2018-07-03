function [] = exportToSimpleWare(image3d)
%exportToSimpleWare a 3-D binary image to .bmp images for inputs in Simpleware and COMSOL 
%   Input Argument
%   - image3D      : a (ny*nx*nz) uint8 matrix, 3-D binary image of
%                    pore space (0 = pore, 1 = grain)
%   Output Argument 
%   - []           : bmp images for Simpleware

%   Revision 1: February 2015 Nattavadee Srisutthiyakorn
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)


    for i = 1:size(image3d,3)
        imwrite(image3d(:,:,i),[inputname(1),num2str(i),'.bmp'])
    end 
end