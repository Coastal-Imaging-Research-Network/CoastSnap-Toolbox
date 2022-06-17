function CSPGmakeShorelineChangePlot(handles)


%Get data from handles
data = get(handles.oblq_image,'UserData');
data_plan = get(handles.plan_image,'UserData');
width = 20; %Width of figure in cm
transect_nos = data.siteDB.sl_settings.transect_averaging_region; %Transects to average over
prevshoreline = str2num(get(handles.previousshoreline,'String')); %How many shorelines to step back
slope = data.siteDB.sl_settings.beach_slope;

%Get shoreline list for site
[slepochs,slfiles,slpaths,sltide] = CSPgetShorelineList(data.site);
navepochs = data.navigation.epochs;
navfiles = data.navigation.files;

%Find common shorelines between all shorelines available and those for
%specific tide
[~,Icommon] = intersect(navepochs,slepochs);

%Now plot shorelines on image
figure
I = data.I;
ax_height = width*size(I,1)/size(I,2);
ax_height2 = 3;
plot_gap = 0.5;
plot_bot = 1.2;
hor_mar = [0.2 0.2];
ver_mar = [0.2 ax_height2+plot_gap+plot_bot];
mid_mar = [0 0];
geomplot(1,1,1,1,width,ax_height,hor_mar,ver_mar,mid_mar)
image(I)
axis off
hold on

%Load SL transect file
CSPloadPaths
load(fullfile(shoreline_path,'Transect Files',data.siteDB.sl_settings.transect_file))

%Plot comparison shorelines
metadata = data_plan.metadata;
colors = distinguishable_colors(2); %Colors of shorelines
imtimes = cell(2,1);
p =NaN(2,length(transect_nos)); %beach width matrix to calculate alongshore-average beach width based on defined transects

%Plot previous and present shoreline
Inow = find(data.epoch==navepochs(Icommon));
Iprev = max(1,Inow-prevshoreline); %Taken from GUI. If a negative number, use the first shoreline in record

%First do previous
imdata = CSPparseFilename(navfiles(Icommon(Iprev)).name);
imtimes{1} = datestr(CSPepoch2LocalMatlab(str2num(imdata.epochtime),data.siteDB.timezone.gmt_offset),'dd/mm/yyyy');
sldir = fullfile(shoreline_path,imdata.site,imdata.year);
slfile = strrep(navfiles(Icommon(Iprev)).name,'snap','shoreline');
slfile = strrep(slfile,'timex','shoreline');
slfile = strrep(slfile,'.jpg','.mat');
if exist(fullfile(sldir,slfile)) %Catch in case shoreline was mapped on registered image
    load(fullfile(sldir,slfile));
else
    slfile = strrep(slfile,'.mat','_registered.mat');
    load(fullfile(sldir,slfile));
end
%load(fullfile(sldir,slfile));
UV = findUVnDOF(metadata.geom.betas,sl.xyz,metadata.geom);
UV = reshape(UV,length(sl.xyz),2);
plot(UV(:,1),UV(:,2),'linewidth',1.5,'color',colors(1,:))
for j = 1:length(transect_nos)
    [x_int,y_int] = polyxpoly(sl.xyz(:,1),sl.xyz(:,2),SLtransects.x(:,transect_nos(j)),SLtransects.y(:,transect_nos(j)));
    if ~isempty(x_int)
        p(1,j) = sqrt((x_int-SLtransects.x(1,transect_nos(j)))^2+(y_int-SLtransects.y(1,transect_nos(j)))^2);
    else
        disp(['Warning: shoreline does not intersect with transect number ' num2str(transect_nos(j))])
    end
end
%Tidally-correct data
%bw_corr = (data.tide_level-sl.xyz(1,3))/slope;
bw_corr = (0-sl.xyz(1,3))/slope; %Now use MSL to keep it consistent
p(1,:) = p(1,:)-bw_corr;

%Now do present shoreline
imdata = CSPparseFilename(navfiles(Icommon(Inow)).name);
imtimes{2} = datestr(CSPepoch2LocalMatlab(str2num(imdata.epochtime),data.siteDB.timezone.gmt_offset),'dd/mm/yyyy');
sldir = fullfile(shoreline_path,imdata.site,imdata.year);
slfile = strrep(navfiles(Icommon(Inow)).name,'snap','shoreline');
slfile = strrep(slfile,'timex','shoreline');
slfile = strrep(slfile,'.jpg','.mat');
load(fullfile(sldir,slfile));
UV = findUVnDOF(metadata.geom.betas,sl.xyz,metadata.geom);
UV = reshape(UV,length(sl.xyz),2);
plot(UV(:,1),UV(:,2),'linewidth',1.5,'color',colors(2,:))
for j = 1:length(transect_nos)
    [x_int,y_int] = polyxpoly(sl.xyz(:,1),sl.xyz(:,2),SLtransects.x(:,transect_nos(j)),SLtransects.y(:,transect_nos(j)));
    if ~isempty(x_int)
        p(2,j) = sqrt((x_int-SLtransects.x(1,transect_nos(j)))^2+(y_int-SLtransects.y(1,transect_nos(j)))^2);
    else
        %Extend transect by 50% just in case it is not long enough
        pt1 =[SLtransects.x(1,transect_nos(j)),SLtransects.y(1,transect_nos(j))];
        pt2 =[SLtransects.x(2,transect_nos(j)),SLtransects.y(2,transect_nos(j))];
        pt2new = pt1+1.5*(pt2-pt1);
        [x_int,y_int] = polyxpoly(sl.xyz(:,1),sl.xyz(:,2),[pt1(1);pt2new(1)],[pt1(2);pt2new(2)]);
        if ~isempty(x_int)
            p(2,j) = sqrt((x_int-SLtransects.x(1,transect_nos(j)))^2+(y_int-SLtransects.y(1,transect_nos(j)))^2);
        else
            disp(['Warning: shoreline does not intersect with transect number ' num2str(transect_nos(j))])
        end
    end
end
%Tidally-correct data
%bw_corr = (data.tide_level-sl.xyz(1,3))/slope;
bw_corr = (0-sl.xyz(1,3))/slope; %Now use MSL to keep it consistent
p(2,:) = p(2,:)-bw_corr;

h = legend(imtimes,'location','NorthEast');
h.FontSize = 10;

    
%Plot time-series below
ver_mar2 = [ver_mar(1)+ax_height+plot_gap plot_bot];
hor_mar2 = [1.5 width/2];
geomplot(1,1,1,1,width,ax_height2,hor_mar2,ver_mar2,mid_mar)
alongshore_distances = SLtransects.alongshore_distances(transect_nos);
area(alongshore_distances,diff(p));
xlim([min(alongshore_distances) max(alongshore_distances)])
YL1 = interp1([-400:5:400],[-400:5:400],min(diff(p))-5,'nearest');
YL2 = interp1([-400:5:400],[-400:5:400],max(diff(p))+5,'nearest');
ylim([YL1 YL2])
set(gcf,'color','w')
set(gca,'fontsize',8)
ylabel('Beach change (m)','fontsize',10)
xlabel('Alongshore distance (m)','fontsize',10)
set(gca,'ygrid','on')
set(gca,'xgrid','on')
XL = xlim;
YL = ylim;
hold on
diffavge = nanmean(diff(p)); %Average beach width change
if diffavge<0
    plot(XL,diffavge*ones(size(XL)),'r--','linewidth',2)
    text(XL(2)+0.1*diff(XL),YL(1)+0.7*diff(YL),'Beach width change','fontsize',20,'color','b','fontname','Berlin Sans FB');
    text(XL(2)+0.1*diff(XL),YL(1)+0.45*diff(YL),[num2str(diffavge,'%0.0f') ' metres (average)'],'fontsize',20,'color','r','fontname','Berlin Sans FB')
else
    plot(XL,diffavge*ones(size(XL)),'g--','linewidth',2 )
    text(XL(2)+0.1*diff(XL),YL(1)+0.7*diff(YL),'Beach width change','fontsize',20,'color','b','fontname','Berlin Sans FB');
    text(XL(2)+0.1*diff(XL),YL(1)+0.45*diff(YL),['+' num2str(diffavge,'%0.0f') ' metres (average)'],'fontsize',20,'color','g','fontname','Berlin Sans FB')
end

%Put coastsnap logo
Ics = imread('CoastSnap Logo Portrait.png');
ax_height3 = 0.7*ax_height2;
ax_width = ax_height3*size(Ics,2)/size(Ics,1);
ver_mar3 = [ver_mar(1)+ax_height+plot_gap+(ax_height2-ax_height3) plot_bot];
hor_mar3 = [width-hor_mar(2)-ax_width hor_mar(2)];
geomplot(1,1,1,1,width,ax_height3,hor_mar3,ver_mar3,mid_mar)
image(Ics)
axis off