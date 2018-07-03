function [ permeability ] = kozenyCarman1( geomFactor, radius, xArea, ...
                                           tortuosity, dl )
%kozenyCarman1 computes permeability using form 1 of Kozeny-Carman equation
%   permeability = (geomFactor ./ 0.5) .* ...
%                  (pi .* radius.^4) ./ (8 .* xArea .* tortuosity)
%
%   Input Arguments
%   - geomFactor   : a double, geometric factor (unitless)
%                    0.5   for pipe with circle or ellipse cross-section
%                    0.562 for pipe with square cross-section
%                    0.6   for pipe with equilateral triangle cross-section
%                    for any other shapes, 0.5 is typically assumed.
%   - radius       : a double, radius of a pipe (unit: pixel length or
%                    meter if dl = 1)
%   - xArea        : a double, area of cross-sectional area of rock frame
%                    (unit: (pixel length).^2 or meter^2 if dl = 1)
%   - tortuosity   : a double, length of flow path over length of frame
%                    (unitless)
%   - dl           : a double, the length of one pixel in meter 
%                    (dx = 0.002 mm -> dl = 0.002.* 0.001 m). dl = 1 is
%                    there's no correction needed
%
%   Output Arguments
%   - permeability : a double, permeability in mD (millidarcy)
%
%   Example
%   Consider a solid frame with cross-sectional area 100.*100 pixels, the
%   pore space is cylindrical pipe shape with radius 4 pixels, the
%   tortuosity is 1 and each pixel represent 0.002*0.001 m.
%
%   [ permeability ] = kozenyCarman1( 0.5, 4, 100^2, ...
%    1, 0.002*0.001 )

%   Revision 1: July   2015 Nattavadee Srisutthiyakorn
%   Stanford Rock Physics and Borehole Geophysics Project (SRB)



%%
% Convert unit m^2 to millidarcy
m2tomD = 1 ./ 0.986923 ./ 10.^-12 .* 1000;

% Change the scale
radius  = radius .* dl;
xArea   = xArea .* dl.^2;

% Calculate permeability
permeability = m2tomD .* (geomFactor./0.5) .* (pi.*(radius).^4) ./ ...
               (8 .* (xArea) .* tortuosity);


           
end
