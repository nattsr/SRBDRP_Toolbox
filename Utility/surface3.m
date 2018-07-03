function h=surface3(volume,varargin)
%SURFACE3 Create 3-D cuboid surfaces.
%   SURFACE3(VOLUME) plots 6 boundary surfaces of a cuboid to the current
%   axes.
%   SURFACE3(VOLUME,X,Y,Z) plots 6 surfaces using the regular mesh
%   specified by the 3 mesh node vectors X, Y and Z. It is required that
%   max(size(X)) = size(VOLUME,1)+1 etc. Default is 0:size(volume,1), for
%   Y and Z accordingly.
%
%   SURFACE3 returns a vector of 6 handles to the SURFACE objects at x=0,
%   y=0,z=0,x=nx,y=ny,z=nz.
%
%   See also SURFACE, SURF, LINE, PATCH, TEXT, SHADING.
%  
%   EXAMPLE:
%     volume = rand(10,10,20);
%     x = (0:10)/10; y=x; z=(0:20)/10;
%     h=surface3(volume,x,y,z);
%     set(gcf,'position',[0 0 300 250])
%     for i=1:6
%       set(h(i),'EdgeColor','k')
%     end
%     colorbar
 
%   By Fabian Krzikalla, Stanford University
%   www.stanford.edu/~krz
%   Date: 2011/05/11
 
% parsing input parameters
p = inputParser;
p.addRequired('volume',@isnumeric);
p.addOptional('x', 0:size(volume,1), @(x)isnumeric(x) && max(size(x))==size(volume,1)+1);
p.addOptional('y', 0:size(volume,2), @(x)isnumeric(x) && max(size(x))==size(volume,2)+1);
p.addOptional('z', 0:size(volume,3), @(x)isnumeric(x) && max(size(x))==size(volume,3)+1);
p.parse(volume,varargin{:})
 
volume=p.Results.volume;
x=p.Results.x; y=p.Results.y; z=p.Results.z;
 
% calculate 6 matrices with color information of the cuboid faces
dim=size(volume);
[tmpxy,tmpxz]=meshgrid(y,z);
[tmpyz,tmpyx]=meshgrid(z,x);
[tmpzx,tmpzy]=meshgrid(x,y);
cx0=zeros(dim(2),dim(3));
cx1=zeros(dim(2),dim(3));
cy0=zeros(dim(3),dim(1));
cy1=zeros(dim(3),dim(1));
cz0=zeros(dim(1),dim(2));
cz1=zeros(dim(1),dim(2));
for i=1:dim(2)
    cx0(i,:)=volume(1,i,:);
    cx1(i,:)=volume(end,i,:);
    cz0(:,i)=volume(:,i,1);
    cz1(:,i)=volume(:,i,end);    
end
for i=1:dim(3)    
    cy0(i,:)=volume(:,1,i);
    cy1(i,:)=volume(:,end,i);
end
 
tmp=[0 x(end) 0 y(end) 0 z(end)];
axis(tmp)
camproj('perspective')
axis equal
campos([3   -3    3]*2*mean(tmp))
 
% create surfaces
h(1)=surface(zeros(dim(2)+1,dim(3)+1)',tmpxy,tmpxz,cx0'); hold all;% x=0
h(2)=surface(tmpyx,zeros(dim(3)+1,dim(1)+1)',tmpyz,cy0'); % y=0
h(3)=surface(tmpzx,tmpzy,zeros(dim(1)+1,dim(2)+1)',cz0'); % z=0
h(4)=surface(ones(dim(2)+1,dim(3)+1)'*x(end),tmpxy,tmpxz,cx1'); % x=end
h(5)=surface(tmpyx,ones(dim(3)+1,dim(1)+1)'*y(end),tmpyz,cy1'); % y=end
h(6)=surface(tmpzx,tmpzy,ones(dim(1)+1,dim(2)+1)'*z(end),cz1'); % z=end
box on;
for i=1:6
set(h(i),'EdgeColor','none')
% set(h(i),'FaceColor','flat')
end