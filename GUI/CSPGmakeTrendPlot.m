function CSPGmakeTrendPlot(handles)


%Get data from handles
data = get(handles.oblq_image,'UserData');
data_plan = get(handles.plan_image,'UserData');
width = 20; %Width of figure in cm
transect_nos = data.siteDB.sl_settings.transect_averaging_region; %Transects to average over
trendinterval = str2num(get(handles.trendinterval,'String')); %In days (usually 6 weeks)
trendinterval_seconds = trendinterval*3600*24;
slope = data.siteDB.sl_settings.beach_slope;
sl_cutoff = 8;
plot_maxmin = 1;
export_data = 1;

%Get shoreline list for site
[slepochs,slfiles,slpaths,sltide] = CSPgetShorelineList(data.site);
Icut = find(data.navigation.epochs>=data.epoch-trendinterval_seconds&data.navigation.epochs<=data.epoch); %Only use data within specified search window
navepochs = data.navigation.epochs(Icut);
navfiles = data.navigation.files(Icut);
navpaths = data.navigation.paths(Icut);

%Find common shorelines between all shorelines available and those for
%specific tide
[~,Icommon] = intersect(navepochs,slepochs);

%Now plot shorelines on image
bwfig = figure;
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
    
    if length(Icommon)<sl_cutoff %Only plot shorelines if < sl_cutoff
        
        %MDH 19/07/2023 Now project tidally correctected shorelines onto
        %oblique image to avoid confusion
        tidal_correction = (data.tide_level+data.siteDB.rect.tidal_offset-sl.xyz(1,3))/slope; %Use elevation of present shoreline here rather than MSL (as below). This is so the present shoreline is not tidally corrected as wel 
        new_sl = CSPGshiftSLxshore(sl,SLtransects,tidal_correction,data.tide_level);
        UV = findUVnDOF(metadata.geom.betas,new_sl,metadata.geom);
        UV = reshape(UV,length(new_sl),2);
        plot(UV(:,1),UV(:,2),'linewidth',1,'color',colors(i,:))
    end
    
    for j = 1:length(transect_nos)
        [x_int,y_int] = polyxpoly(sl.xyz(:,1),sl.xyz(:,2),SLtransects.x(:,transect_nos(j)),SLtransects.y(:,transect_nos(j)));
        if ~isempty(x_int)
            p(i,j) = sqrt((x_int(1)-SLtransects.x(1,transect_nos(j)))^2+(y_int(1)-SLtransects.y(1,transect_nos(j)))^2);
        else
            disp(['Warning: shoreline does not intersect with transect number ' num2str(transect_nos(j)) ' for date ' imtimes{i}])
        end
    end
    %Tidally-correct data
    %bw_corr = (data.tide_level-sl.xyz(1,3))/slope; %Slope taken from characteristic beach slope in CoastSnapDB 
    bw_corr = (0-sl.xyz(1,3))/slope; %now project to MSL instead of tide level from first image. %Slope taken from characteristic beach slope in CoastSnapDB 
    p(i,:) = p(i,:)-bw_corr;
end
av_bw = nanmean(p');
[~,Imin] = min(av_bw);
[~,Imax] = max(av_bw);
Iall = [1 Imin Imax length(av_bw)];

if length(Icommon)<sl_cutoff
    %h = legend(imtimes,'location','NorthWest');
    h = legend(imtimes,'location','NorthEast');
    h.FontSize = 8;
else
    for i = 1:length(Iall)
        imdata = CSPparseFilename(navfiles(Icommon(Iall(i))).name);
        %imtimes{i} = datestr(CSPepoch2LocalMatlab(str2num(imdata.epochtime),data.siteDB.timezone.gmt_offset),'dd/mm/yyyy');
        sldir = fullfile(shoreline_path,imdata.site,imdata.year);
        slfile = strrep(navfiles(Icommon(Iall(i))).name,'snap','shoreline');
        slfile = strrep(slfile,'timex','shoreline');
        slfile = strrep(slfile,'.jpg','.mat');
        if exist(fullfile(sldir,slfile)) %Catch in case shoreline was mapped on registered image
            load(fullfile(sldir,slfile));
        else
            slfile = strrep(slfile,'.mat','_registered.mat');
            load(fullfile(sldir,slfile));
        end
        %MDH 19/07/2023 Now project tidally correctected shorelines onto
        %oblique image to avoid confusion
        tidal_correction = (data.tide_level+data.siteDB.rect.tidal_offset-sl.xyz(1,3))/slope; %Use elevation of present shoreline here rather than MSL (as below). This is so the present shoreline is not tidally corrected as wel 
        new_sl = CSPGshiftSLxshore(sl,SLtransects,tidal_correction,data.tide_level);
        UV = findUVnDOF(metadata.geom.betas,new_sl,metadata.geom);
        UV = reshape(UV,length(new_sl),2);
        plot(UV(:,1),UV(:,2),'linewidth',1,'color',colors(i,:))
    end
    h = legend(['Initial width = ' num2str(av_bw(1),'%0.1f') ' m (' imtimes{1} ')'],['Min. width = ' num2str(av_bw(Imin),'%0.1f') ' m (' imtimes{Imin} ')'],['Max. width = ' num2str(av_bw(Imax),'%0.1f') ' m (' imtimes{Imax} ')'],['Latest width = ' num2str(av_bw(end),'%0.1f') ' m (' imtimes{end} ')']);
end


%Plot time-series below
ver_mar2 = [ver_mar(1)+ax_height+plot_gap plot_bot];
hor_mar2 = [1.5 width/2];
geomplot(1,1,1,1,width,ax_height2,hor_mar2,ver_mar2,mid_mar)
dates = datenum(imtimes,'dd/mm/yyyy');
if length(Icommon)<sl_cutoff
    for i = 1:length(dates)
        plot(dates(i),av_bw(i),'.','markersize',20,'color',colors(i,:))
        hold on
    end
else
    plot(dates,av_bw,'.','color',0.7*[1 1 1],'markersize',15)
    hold on
    plot(dates(1),av_bw(1),'.','color',colors(1,:),'markersize',15)
    plot(dates(Imin),av_bw(Imin),'.','color',colors(2,:),'markersize',15)
    plot(dates(Imax),av_bw(Imax),'.','color',colors(3,:),'markersize',15)
    plot(dates(end),av_bw(end),'.','color',colors(4,:),'markersize',15)
end
alpha = polyfit(dates,av_bw',1);
texttype = 'Beach width trend';
units = ' metres/year';
if alpha(1)>0
    value = num2str(alpha(1)*365.25,'+%0.2f'); %Convert to metres/year
    textcolor = 'g';
elseif alpha(1)<0
    value = num2str(alpha(1)*365.25,'%0.2f'); %Convert to metres/year
    textcolor = 'r';
end
plot([min(dates)-5 max(dates)+5],polyval(alpha,[min(dates)-5 max(dates)+5]),'linewidth',2,'color','k')
YL1 = interp1([-100:5:400],[-100:5:400],min(av_bw)-5,'nearest');
YL2 = interp1([-100:5:400],[-100:5:400],max(av_bw)+5,'nearest');
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
text(XL(2)+0.1*diff(XL),YL(1)+0.7*diff(YL),texttype,'fontsize',20,'color','b','fontname','Berlin Sans FB');
text(XL(2)+0.1*diff(XL),YL(1)+0.45*diff(YL),[value units],'fontsize',20,'color',textcolor,'fontname','Berlin Sans FB')

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

%Export data to jpg

if export_data==1
    %Prompt user to select output path to save frames
    output_path = uigetdir(data.path, 'Select output directory for beach width animation frames and time-series data');
    if value(outputpath~=0) %Catch in case user closes folder

        filename_trend = ['beachwidth_trend_figure_' data.site '.jpg'];
        exportgraphics(bwfig,fullfile(output_path,filename_trend),'Resolution',600)

        if plot_maxmin==1

            %Plot image and shoreline corresponding to minimum
            Iminimage = imread(fullfile(navpaths(Icommon(Imin)).name,navfiles(Icommon(Imin)).name));
            ax_height = width*size(Iminimage,1)/size(Iminimage,2);
            hor_mar = [0.2 0.2];
            ver_mar = [0.2 0.2];
            mid_mar = [1 0];
            minfig=figure;
            geomplot(1,1,1,1,width,ax_height,hor_mar,ver_mar,mid_mar)
            image(Iminimage)
            hold on
            imdata = CSPparseFilename(navfiles(Icommon(Imin)).name);
            sldir = fullfile(shoreline_path,imdata.site,imdata.year);
            slfile = strrep(navfiles(Icommon(Imin)).name,'snap','shoreline');
            slfile = strrep(slfile,'timex','shoreline');
            slfile = strrep(slfile,'.jpg','.mat');
            rectpath = strrep(navpaths(Icommon(Imin)).name,'Processed','Rectified');
            rectfile = strrep(navfiles(Icommon(Imin)).name,'snap','plan');
            rectfile = strrep(rectfile,'timex','plan');
            rectfile = strrep(rectfile,'.jpg','.mat');
            if exist(fullfile(sldir,slfile)) %Catch in case shoreline was mapped on registered image
                load(fullfile(sldir,slfile));
                load(fullfile(rectpath,rectfile))
            else
                slfile = strrep(slfile,'.mat','_registered.mat');
                load(fullfile(sldir,slfile));
            end
            UV = findUVnDOF(metadata.geom.betas,sl.xyz,metadata.geom);
            UV = reshape(UV,length(sl.xyz),2);
            plot(UV(:,1),UV(:,2),'linewidth',2,'color',colors(Imin,:))
            axis off
            set(gcf,'color','w')
            txt = ['Minimum beach width = ' num2str(Min_BW,'%0.1f')  ' m (' datestr(dates(Imin),'dd/mm/yyyy') ')'];
            h = legend(txt,'location','NorthWest'); %change to NorthWest for LHS beach
            h.FontSize = 14;
            %h=text(XL(1)+0.02*diff(XL),YL(1)+0.02*diff(YL),txt,'color', colors(Imin,:),'fontsize',20,'BackgroundColor','w');
            filename_min = ['min_width_figure_' data.site '.jpg'];
            exportgraphics(minfig,fullfile(output_path,filename_min),'Resolution',600)

            %Now do same for maximum
            Imaximage = imread(fullfile(navpaths(Icommon(Imax)).name,navfiles(Icommon(Imax)).name));
            ax_height = width*size(Imaximage,1)/size(Imaximage,2);
            hor_mar = [0.2 0.2];
            ver_mar = [0.2 0.2];
            mid_mar = [1 0];
            maxfig=figure;
            geomplot(1,1,1,1,width,ax_height,hor_mar,ver_mar,mid_mar)
            image(Imaximage)
            hold on
            imdata = CSPparseFilename(navfiles(Icommon(Imax)).name);
            sldir = fullfile(shoreline_path,imdata.site,imdata.year);
            slfile = strrep(navfiles(Icommon(Imax)).name,'snap','shoreline');
            slfile = strrep(slfile,'timex','shoreline');
            slfile = strrep(slfile,'.jpg','.mat');
            rectpath = strrep(navpaths(Icommon(Imax)).name,'Processed','Rectified');
            rectfile = strrep(navfiles(Icommon(Imax)).name,'snap','plan');
            rectfile = strrep(rectfile,'timex','plan');
            rectfile = strrep(rectfile,'.jpg','.mat');
            if exist(fullfile(sldir,slfile)) %Catch in case shoreline was mapped on registered image
                load(fullfile(sldir,slfile));
                load(fullfile(rectpath,rectfile))
            else
                slfile = strrep(slfile,'.mat','_registered.mat');
                load(fullfile(sldir,slfile));
            end
            UV = findUVnDOF(metadata.geom.betas,sl.xyz,metadata.geom);
            UV = reshape(UV,length(sl.xyz),2);
            plot(UV(:,1),UV(:,2),'linewidth',2,'color',colors(Imax,:))
            axis off
            set(gcf,'color','w')
            XL = xlim;
            YL = ylim;
            txt = ['Maximum beach width = ' num2str(Max_BW,'%0.1f')  ' m (' datestr(dates(Imax),'dd/mm/yyyy') ')'];
            h = legend(txt,'location','NorthWest'); %change to NorthWest for LHS beach
            h.FontSize = 14;
            %h=text(XL(1)+0.02*diff(XL),YL(1)+0.02*diff(YL),txt,'color', colors(Imax,:),'fontsize',20,'BackgroundColor','w');
            filename_min = ['max_width_figure_' data.site '.jpg'];
            exportgraphics(maxfig,fullfile(output_path,filename_min),'Resolution',600)


        end
    end
end



