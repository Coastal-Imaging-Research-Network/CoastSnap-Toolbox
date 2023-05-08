function CSPGplotShorelineForecast(handles)


%Get data from handles
data = get(handles.oblq_image,'UserData');
data_plan = get(handles.plan_image,'UserData');
width = 20; %Width of figure in cm
transect_nos = data.siteDB.sl_settings.transect_averaging_region; %Transects to average over
forecast_error = 6.31; %uncertainty of forecast

%Prompt user to input forecast of beach width change
forecast = inputdlg('Please input your change in beach width forecast (in meters)','Forecast value');
forecast = str2num(forecast{1});

%Now plot shorelines on image
figure
I = data.I;
ax_height = width*size(I,1)/size(I,2);
ax_height2 = 3;
plot_gap = 0.5;
plot_bot = 0.5;
hor_mar = [0.2 0.2];
ver_mar = [0.2 plot_bot];
mid_mar = [0 0];
geomplot(1,1,1,1,width,ax_height,hor_mar,ver_mar,mid_mar)
image(I)
axis off
hold on

%Load SL transect file
CSPloadPaths
load(fullfile(shoreline_path,'Transect Files',data.siteDB.sl_settings.transect_file))

%Plot 2 shorelines
metadata = data_plan.metadata;
colors = distinguishable_colors(2); %Colors of shorelines
imtimes = cell(3,1);
new_sl =NaN(length(transect_nos),3); %new shoreline based on forecast
error_sea = new_sl; %To create uncertainty area
error_land = new_sl;%To create uncertainty area


%Plot present shoreline
[slepochs,slfiles,slpaths,sltide] = CSPgetShorelineList(data.site);
Inow = find(data.epoch==slepochs);
imdata = CSPparseFilename(data.fname);
imtimes{1} = ['Current shoreline (' datestr(CSPepoch2LocalMatlab(data.epoch,data.siteDB.timezone.gmt_offset),'dd/mm/yyyy') ')'];
load(fullfile(slpaths(Inow).name,slfiles(Inow).name));
UV = findUVnDOF(metadata.geom.betas,sl.xyz,metadata.geom);
UV = reshape(UV,length(sl.xyz),2);
plot(UV(:,1),UV(:,2),'linewidth',1.5,'color',colors(2,:))
for j = 1:length(transect_nos)
    [x_int,y_int] = polyxpoly(sl.xyz(:,1),sl.xyz(:,2),SLtransects.x(:,transect_nos(j)),SLtransects.y(:,transect_nos(j)));
    alpha = polyfit(SLtransects.x(:,transect_nos(j)),SLtransects.y(:,transect_nos(j)),1);
    xnew = x_int-forecast/sqrt(1+alpha(1)^2);
    ynew = polyval(alpha,xnew);
    new_sl(j,:) = [xnew ynew sl.xyz(1,3)]; %Same elevation as present shoreline
    xnew_sea = x_int-(forecast-forecast_error)/sqrt(1+alpha(1)^2);
    ynew_sea = polyval(alpha,xnew_sea);
    error_sea(j,:) = [xnew_sea ynew_sea sl.xyz(1,3)]; %Same elevation as present shoreline
    xnew_land = x_int-(forecast+forecast_error)/sqrt(1+alpha(1)^2); %Note, add forecast error here
    ynew_land = polyval(alpha,xnew_land);
    error_land(j,:) = [xnew_land ynew_land sl.xyz(1,3)]; %Same elevation as present shoreline
end

UVnew = findUVnDOF(metadata.geom.betas,new_sl,metadata.geom);
UVnew = reshape(UVnew,length(new_sl),2);
xyz_error = [error_sea; flipud(error_land)];
%xyz_error = [new; flipud(error_land)];
UVerror = findUVnDOF(metadata.geom.betas,xyz_error,metadata.geom);
UVerror = reshape(UVerror,length(xyz_error),2);
plot(UVnew(:,1),UVnew(:,2),'linewidth',2,'color','k','linestyle','-')
hold on
patch(UVerror(:,1),UVerror(:,2),0.5*[1 1 1],'EdgeColor','none')
plot(UVnew(:,1),UVnew(:,2),'linewidth',2,'color','k','linestyle','-')

imtimes{2} = 'Forecast post-storm shoreline';
imtimes{3} = 'Forecast uncertainty';
h = legend(imtimes,'location','NorthEast');
h.FontSize = 12;
set(gcf,'color','w')