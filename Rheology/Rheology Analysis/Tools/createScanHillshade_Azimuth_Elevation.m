function [H,x,y, interpolatedPtCloud,F] = createScanHillshade_Azimuth_Elevation(ptCloud,spacing,xLim,yLim,azimuth,altitude)
%%A function to create a scattered interpolant of an input point cloud, and
%%generate interpolated values based on an input spacing, and then
%%generate a hillshade

xyz = double(ptCloud.Location);
xyz(isnan(xyz(:,1)),:) = 0;
x = xyz(:,1);
y=xyz(:,2);
z=xyz(:,3);
F = scatteredInterpolant(x,y,z);
F.Method = 'linear';
F.ExtrapolationMethod = 'none';

[Xq,yQ] = meshgrid(min(xLim):spacing:max(xLim),min(yLim):spacing:max(yLim));
Zq = F(Xq,yQ);

ptCloudData = [Xq(:),yQ(:),Zq(:)];

interpolatedPtCloud = pointCloud(ptCloudData);
cmatrix = ones(size(interpolatedPtCloud.Location)).*[1 1 1];
interpolatedPtCloud = pointCloud(ptCloudData,'Color',cmatrix);
x = [min(xLim):spacing:max(xLim)];
y= [min(yLim):spacing:max(yLim)];
H = hillshade_esri_azi_alt(Zq,[min(y):spacing:max(y)],[min(x):spacing:max(x)],'azimuth',azimuth,'altitude',altitude);

end