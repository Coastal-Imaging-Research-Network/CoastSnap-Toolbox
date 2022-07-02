function CSPGmakeBeachWidthAnimation(handles)


%Get data from handles
data = get(handles.oblq_image,'UserData');
data_plan = get(handles.plan_image,'UserData');
width = 20; %Width of figure in cm
transect_nos = data.siteDB.sl_settings.transect_averaging_region; %Transects to average over
trendinterval = str2num(get(handles.trendinterval,'String')); %In days (usually 6 weeks)
trendinterval_seconds = trendinterval*3600*24;
slope = data.siteDB.sl_settings.beach_slope;
%Prompt user to select output path to save frames
output_path = uigetdir(data.path, 'Select output directory for beach width animation frames and time-series data');

%% First Calculate BW time-series

%Get shoreline list for site
[slepochs,slfiles,slpaths,sltide] = CSPgetShorelineList(data.site);
Icut = find(data.navigation.epochs>=data.epoch-trendinterval_seconds&data.navigation.epochs<=data.epoch); %Only use data within specified search window
navepochs = data.navigation.epochs(Icut);
navfiles = data.navigation.files(Icut);
navpaths = data.navigation.paths(Icut);

%Find common shorelines between all shorelines available and those for
%specific tide
%[~,Icommon] = intersect(navepochs,slepochs);
[~,Icommon] = intersect(slepochs,navepochs);

%Load SL transect file
CSPloadPaths
load(fullfile(shoreline_path,'Transect Files',data.siteDB.sl_settings.transect_file))

%Loop through shorelines
p =NaN(length(Icommon),length(transect_nos)); %beach width matrix to calculate alongshore-average beach width based on defined transects
disp('Calculating shoreline data....')
for i = 1:length(Icommon)
    load(fullfile(slpaths(Icommon(i)).name,slfiles(Icommon(i)).name))
    for j = 1:length(transect_nos)
        [x_int,y_int] = polyxpoly(sl.xyz(:,1),sl.xyz(:,2),SLtransects.x(:,transect_nos(j)),SLtransects.y(:,transect_nos(j)));
        if length(x_int)>1
            warning('More than 1 intersection point detected between shoreline and transect')
        end
        if ~isempty(x_int)
            p(i,j) = sqrt((x_int(1)-SLtransects.x(1,transect_nos(j)))^2+(y_int(1)-SLtransects.y(1,transect_nos(j)))^2); %If more than 1 intersection, choose the most landward
        else
            %disp(['Warning: shoreline does not intersect with transect number ' num2str(transect_nos(j))])
        end
    end
    %Tidally-correct data
    %bw_corr = (data.tide_level-sl.xyz(1,3))/slope; %Slope taken from characteristic beach slope in CoastSnapDB
    bw_corr = (0-sl.xyz(1,3))/slope; %now project to MSL instead of tide level from first image. Slope taken from characteristic beach slope in CoastSnapDB
    p(i,:) = p(i,:)-bw_corr;
end
disp('Done')

%% Now make animation
fig=figure;
set(gcf,'color','w')
I = imread(fullfile(navpaths(1).name,navfiles(1).name));
ax_height = width*size(I,1)/size(I,2);
ax_height2 = 3;
plot_gap = 0.5;
plot_bot = 1.2;
hor_mar = [0.2 0.2];
ver_mar = [0.2 ax_height2+plot_gap+plot_bot];
mid_mar = [0 0];
geomplot(1,1,1,1,width,ax_height,hor_mar,ver_mar,mid_mar)
ax1 = gca;
image(I)
axis off

%Icut = find(navepochs>slepochs(Icommon(1)));
%navepochs = data.navigation.epochs(Icut);
%navfiles = data.navigation.files(Icut);
%navpaths = data.navigation.paths(Icut);

if ismember(navepochs(1),slepochs)
    imdata = CSPparseFilename(navfiles(1).name);
    sldir = fullfile(shoreline_path,imdata.site,imdata.year);
    slfile = strrep(navfiles(1).name,'snap','shoreline');
    slfile = strrep(slfile,'timex','shoreline');
    slfile = strrep(slfile,'.jpg','.mat');
    if isfile(fullfile(sldir,slfile))
        load(fullfile(sldir,slfile))
        hold on
        plot(sl.UV(:,1),sl.UV(:,2),'r','linewidth',2)
        hold off
    end
end
  
%Plot time-series below
ver_mar2 = [ver_mar(1)+ax_height+plot_gap plot_bot];
hor_mar2 = [1.5 width/2.5];
geomplot(1,1,1,1,width,ax_height2,hor_mar2,ver_mar2,mid_mar)
ax2 = gca;
dates = CSPepoch2LocalMatlab(slepochs(Icommon),data.siteDB.timezone.gmt_offset);
av_bw = nanmean(p');
plot(dates,av_bw,'x','color',0.7*[1 1 1])
hold on
f = fit(dates',av_bw','smoothingspline','SmoothingParam',0.1);
plot(dates,f(dates),'color','k','linewidth',1)
xlim([min(dates) max(dates)])
datetick('x','keeplimits')
set(gca,'ygrid','on')
set(gca,'xgrid','on')
ylabel('Beach width (m)','fontsize',11)
YL = ylim;
XL = xlim;
hold on
dd =  CSPepoch2LocalMatlab(navepochs(1),data.siteDB.timezone.gmt_offset);
counter = plot([dd(1) dd(1)],[YL(1) YL(2)],'r','linewidth',2); 
bw_now = f(CSPepoch2LocalMatlab(navepochs(1),data.siteDB.timezone.gmt_offset));
text(XL(2)+0.1*diff(XL),YL(1)+0.7*diff(YL),'Beach width','fontsize',20,'color','b','fontname','Berlin Sans FB');
bw_text = text(XL(2)+0.1*diff(XL),YL(1)+0.45*diff(YL),[num2str(bw_now,'%0.1f') ' metres'],'fontsize',20,'color','r','fontname','Berlin Sans FB');
ylim(YL)

%Save beachwidth time-series data to csv file in output directory
M = [datevec(dates) av_bw' f(dates)]; %8-column matrix of dates, alongshore-averaged beach width and smoothed beach width
writematrix(M,fullfile(output_path,['beachwidth_timeseries_' data.site '.csv']))

%Put coastsnap logo
Ics = imread('CoastSnap Logo Portrait.png');
ax_height3 = 0.7*ax_height2;
ax_width = ax_height3*size(Ics,2)/size(Ics,1);
ver_mar3 = [ver_mar(1)+ax_height+plot_gap+(ax_height2-ax_height3) plot_bot];
hor_mar3 = [width-hor_mar(2)-ax_width hor_mar(2)];
geomplot(1,1,1,1,width,ax_height3,hor_mar3,ver_mar3,mid_mar)
image(Ics)
axis off
if exist('exportgraphics','file')~=0
    exportgraphics(fig,fullfile(output_path,'frame_001.jpg'),'Resolution',300) %Exportgraphics only from Matlab 2020 onwards
else
    print(fig,fullfile(output_path,'frame_001.jpg'),'-djpeg','-r300')
end

%Now loop over other images
for i = 2:navepochs %Loop over all images, not just images with shorelines
    axes(ax1)
    imdata = CSPparseFilename(navfiles(i).name);
    I = imread(fullfile(navpaths(i).name,navfiles(i).name));
    image(I)
    axis off
    if ismember(navepochs(i),slepochs)
        imdata = CSPparseFilename(navfiles(i).name);
        sldir = fullfile(shoreline_path,imdata.site,imdata.year);
        slfile = strrep(navfiles(i).name,'snap','shoreline');
        slfile = strrep(slfile,'timex','shoreline');
        slfile = strrep(slfile,'.jpg','.mat');
        if isfile(fullfile(sldir,slfile))
            load(fullfile(sldir,slfile));
            hold on
            plot(sl.UV(:,1),sl.UV(:,2),'r','linewidth',2)
            hold off
        end
    end
    
    axes(ax2)
    dd =  CSPepoch2LocalMatlab(navepochs(i),data.siteDB.timezone.gmt_offset);
    hold on
    delete(counter)
    counter = plot([dd dd],[YL(1) YL(2)],'r','linewidth',2);
    bw_now = f(CSPepoch2LocalMatlab(navepochs(i),data.siteDB.timezone.gmt_offset));
    delete(bw_text)
    bw_text = text(XL(2)+0.1*diff(XL),YL(1)+0.45*diff(YL),[num2str(bw_now,'%0.1f') ' metres'],'fontsize',20,'color','r','fontname','Berlin Sans FB');  
    print(fig,fullfile(output_path,['frame_' num2str(i,'%03.0f') '.jpg']),'-djpeg','-r300')
end