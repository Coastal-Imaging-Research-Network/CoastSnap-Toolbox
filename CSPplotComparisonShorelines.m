close all
clear variables
clc


%Input variables of interest
tide_tol = 0.6;
width = 20;
max_shorelines = 3;
site = 'manly';
siteDB = CSPreadSiteDB(site);


%Prompt user to select image
CSPloadPaths
[imfile,imdir]=uigetfile([base_path '*.jpg'],...
   'Select CoastSnap image .jpg file');
if isnumeric(imfile)|isnumeric(imdir)
     error('¡¡ No file selected !!')
end


%Display image
data = CSPparseFilename(imfile);
I = imread([imdir imfile]); %Read image
ax_height = width*size(I,1)/size(I,2);
geomplot(1,1,1,1,width,ax_height,[0 0],[0 0],[0 0])
image(I)
axis off
hold on
rectdir = strrep(imdir,'Processed','Rectified');
rectfile = strrep(imfile,'snap','plan');rectfile = strrep(rectfile,'.jpg','.mat');
load(fullfile(rectdir,rectfile))
sldir = strrep(imdir,'Images','Shorelines'); sldir = strrep(sldir,'Processed\',[]);
slfile = strrep(imfile,'snap','shoreline');slfile = strrep(slfile,'.jpg','.mat');
load(fullfile(sldir,slfile));
sl_now = sl;
UV = findUVnDOF(metadata.geom.betas,sl.xyz,metadata.geom);
UV = reshape(UV,length(sl.xyz),2);

%Search SL database for similar tide levels
[epochtimes,sl_fnames,tides] = CSPgetShorelineInfo(site); % Find all shorelines and associated tide levels in DB
I = find(tides>(sl.xyz(1,3)-siteDB.rect.tidal_offset-tide_tol)&tides<(sl.xyz(1,3)-siteDB.rect.tidal_offset+tide_tol)&epochtimes~=str2num(data.epochtime));
disp([num2str(length(I)) ' shorelines found with a tide level +/- ' num2str(tide_tol) 'm of the selected image tide level']) 

%Find epoch times corresponding to last month and last year
comparison_dates = [str2num(data.epochtime)-30*3600*24 str2num(data.epochtime)-12*30*3600*24]; %Epoch time is in seconds
Inew = interp1(epochtimes(I),I,comparison_dates,'nearest','extrap'); %Extrapolate outside of domain
I = Inew;
datestr(epoch2Matlab(epochtimes(I)))

plot(UV(:,1),UV(:,2),'b','linewidth',2)
hold on

%Loop through relevant shorelines and plot on image
legend_dates = [];
linecolors = {'g','r'};
for i = 1:length(I)
    slfile_pre = sl_fnames(I(i)).name;
    data_pre = CSPparseFilename(slfile_pre);
    load(fullfile(shoreline_path,data_pre.site,data_pre.year,slfile_pre));
    UV_pre = findUVnDOF(metadata.geom.betas,sl.xyz,metadata.geom);
    UV_pre = reshape(UV_pre,length(sl.xyz),2);
    hold on
    plot(UV_pre(:,1),UV_pre(:,2),'--','linewidth',2,'color',linecolors{i})
    legend_dates = [legend_dates '''' datestr(CSPepoch2LocalMatlab(epochtimes(I(i)),siteDB.timezone.gmt_offset),'dd/mm/yyyy') ''','];
end
plot(UV(:,1),UV(:,2),'b','linewidth',2)

legend_dates = [legend_dates '''' datestr(CSPepoch2LocalMatlab(str2num(data.epochtime),siteDB.timezone.gmt_offset),'dd/mm/yyyy') ''''];
%eval(['h = legend(' legend_dates ',''location'',''NorthEast'');'])
h = legend(['This week (' datestr(CSPepoch2LocalMatlab(str2num(data.epochtime),siteDB.timezone.gmt_offset),'dd/mm/yyyy') ')'],['1 month ago (' datestr(CSPepoch2LocalMatlab(epochtimes(I(1)),siteDB.timezone.gmt_offset),'dd/mm/yyyy') ')'],['1 year ago (' datestr(CSPepoch2LocalMatlab(epochtimes(I(2)),siteDB.timezone.gmt_offset),'dd/mm/yyyy') ')']);
set(h,'fontsize',12)
%jpg_name = ['shorelineplot_' data.site '_' datestr(data.date,'ddmmyyyy') '.jpg'];
%print(jpg_name,'-djpeg','-r600')
