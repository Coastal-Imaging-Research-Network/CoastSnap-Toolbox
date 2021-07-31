function CSPGmakeTrendPlot(handles)


%Get data from handles
data = get(handles.oblq_image,'UserData');
data_plan = get(handles.plan_image,'UserData');
width = 20; %Width of figure in cm
transect_nos = data.siteDB.sl_settings.transect_averaging_region; %Transects to average over
trendinterval = str2num(get(handles.trendinterval,'String')); %In days (usually 6 weeks)
trendinterval_seconds = trendinterval*3600*24;
slope = data.siteDB.sl_settings.beach_slope;

%Get shoreline list for site
[slepochs,slfiles,slpaths,sltide] = CSPgetShorelineList(data.site);
Icut = find(data.navigation.epochs>=data.epoch-trendinterval_seconds&data.navigation.epochs<=data.epoch); %Only use data within specified search window
navepochs = data.navigation.epochs(Icut);
navfiles = data.navigation.files(Icut);

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

%Loop through shorelines
metadata = data_plan.metadata;
colors = distinguishable_colors(length(Icommon)); %Colors of shorelines
imtimes = cell(length(Icommon),1);
p =NaN(length(Icommon),length(transect_nos)); %beach width matrix to calculate alongshore-average beach width based on defined transects

%If more than 8 shorelines, plot shorelines differently
if length(Icommon)>8
    colors = ones(length(Icommon),3)*0; %Make all colours black
    colors2 = distinguishable_colors(4)
    colors(1,:) = colors2(1,:);
    colors(end,:) = colors2(end,:);
end

%Plot shorelines
for i = 1:length(Icommon)
    imdata = CSPparseFilename(navfiles(Icommon(i)).name);
    imtimes{i} = datestr(CSPepoch2LocalMatlab(str2num(imdata.epochtime),data.siteDB.timezone.gmt_offset),'dd/mm/yyyy');
    sldir = fullfile(shoreline_path,imdata.site,imdata.year);
    slfile = strrep(navfiles(Icommon(i)).name,'snap','shoreline');
    slfile = strrep(slfile,'timex','shoreline');
    slfile = strrep(slfile,'.jpg','.mat');
    if exist(fullfile(sldir,slfile)) %Catch in case shoreline was mapped on registered image
        load(fullfile(sldir,slfile));
    else
        slfile = strrep(slfile,'.mat','_registered.mat');
        load(fullfile(sldir,slfile));
    end
    UV = findUVnDOF(metadata.geom.betas,sl.xyz,metadata.geom);
    UV = reshape(UV,length(sl.xyz),2);
    plot(UV(:,1),UV(:,2),'linewidth',1,'color',colors(i,:))
    for j = 1:length(transect_nos)
        [x_int,y_int] = polyxpoly(sl.xyz(:,1),sl.xyz(:,2),SLtransects.x(:,transect_nos(j)),SLtransects.y(:,transect_nos(j)));
        if ~isempty(x_int)
            p(i,j) = sqrt((x_int-SLtransects.x(1,transect_nos(j)))^2+(y_int-SLtransects.y(1,transect_nos(j)))^2);
        else
            disp(['Warning: shoreline does not intersect with transect number ' num2str(transect_nos(j)) ' for date ' imtimes{i}])
        end
    end
    %Tidally-correct data
    %bw_corr = (data.tide_level-sl.xyz(1,3))/slope; %Slope taken from characteristic beach slope in CoastSnapDB 
    bw_corr = (0-sl.xyz(1,3))/slope; %now project to MSL instead of tide level from first image. %Slope taken from characteristic beach slope in CoastSnapDB 
    p(i,:) = p(i,:)-bw_corr;
end

if length(Icommon)<8  
    h = legend(imtimes,'location','NorthEast');
    h.FontSize = 8;    
end
  
%Plot time-series below
ver_mar2 = [ver_mar(1)+ax_height+plot_gap plot_bot];
hor_mar2 = [1.5 width/2];
geomplot(1,1,1,1,width,ax_height2,hor_mar2,ver_mar2,mid_mar)
dates = datenum(imtimes,'dd/mm/yyyy');
av_bw = nanmean(p');
for i = 1:length(dates)
plot(dates(i),av_bw(i),'.','markersize',20,'color',colors(i,:))
hold on
end
alpha = polyfit(dates,av_bw',1);
plot([min(dates)-5 max(dates)+5],polyval(alpha,[min(dates)-5 max(dates)+5]),'linewidth',2,'color',0.7*[1 1 1])
YL1 = interp1([0:5:400],[0:5:400],min(av_bw)-5,'nearest');
YL2 = interp1([0:5:400],[0:5:400],max(av_bw)+5,'nearest');
XL1 = min(dates)-7;
XL2 = max(dates)+7;
xlim([XL1 XL2])
ylim([YL1 YL2])
if XL2-XL1<180
    datetick('x','dd/mm','keeplimits')
else
    datetick('x','mm/yy','keeplimits')
end
xtickangle(0); %Stop latest version (Matlab R2021a) from automatically rotating tick 45 degrees
set(gcf,'color','w')
set(gca,'fontsize',9)
ylabel('Beach width (m)','fontsize',12)
xlabel('Date','fontsize',12)
set(gca,'ygrid','on')
set(gca,'xgrid','on')
XL = xlim;
YL = ylim;
if alpha(1)>0
    text(XL(2)+0.1*diff(XL),YL(1)+0.7*diff(YL),'Beach width trend','fontsize',20,'color','b','fontname','Berlin Sans FB');
    if (XL2-XL1)<365.25
        text(XL(2)+0.1*diff(XL),YL(1)+0.45*diff(YL),['+' num2str(alpha(1)*7,'%0.2f') ' metres/week'],'fontsize',20,'color','g','fontname','Berlin Sans FB')
    else
        text(XL(2)+0.1*diff(XL),YL(1)+0.45*diff(YL),['+' num2str(alpha(1)*365.25,'%0.2f') ' metres/year'],'fontsize',20,'color','g','fontname','Berlin Sans FB')
    end
else
    text(XL(2)+0.1*diff(XL),YL(1)+0.7*diff(YL),'Beach width trend','fontsize',20,'color','b','fontname','Berlin Sans FB');
    if (XL2-XL1)<365.25
        text(XL(2)+0.1*diff(XL),YL(1)+0.45*diff(YL),[num2str(alpha(1)*7,'%0.2f') ' metres/week'],'fontsize',20,'color','r','fontname','Berlin Sans FB')
    else
        text(XL(2)+0.1*diff(XL),YL(1)+0.45*diff(YL),[num2str(alpha(1)*365.25,'%0.2f') ' metres/year'],'fontsize',20,'color','r','fontname','Berlin Sans FB')
    end
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

%Display some statistics on max and min beach width
%Minimum
[Min_BW,Imin] = min(av_bw);
disp(['Minimum average beach width over time period is ' num2str(Min_BW,'%0.1f')...
    'm (' datestr(dates(Imin),'dd/mm/yyyy') ')'])
%Maximum
[Max_BW,Imax] = max(av_bw);
disp(['Maximum average beach width over time period is ' num2str(Max_BW,'%0.1f')...
    'm (' datestr(dates(Imax),'dd/mm/yyyy') ')'])


