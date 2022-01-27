%Insert site-specific data here
site = 'blacksmiths'
photoshoptemp_dir = 'C:\Users\z2273773\Desktop\manly\New folder'; %Name of directory where you have saved your registered images from photoshop


%Now do processing
files = dir([photoshoptemp_dir filesep '*.jpg']);
siteDB = CSPreadSiteDB(site);
for i = 1:length(files)
    i
    fname = files(i).name(7:end-4) %Assumes that your exported files have the default 6-char identifyer from Photoshop
    %fname = files(i).name;
    %out = CSreadImageData(files(i).name)
    
    out = CSPparseFilename(fname)
    I = imread(fullfile(photoshoptemp_dir,files(i).name));
    width = 20;
ax_height = width*size(I,1)/size(I,2);
geomplot(1,1,1,1,width,ax_height,[0 0],[0 0],[0 0])
image(I)
axis off
XL = xlim;
YL = ylim;
matlablocal = CSPepoch2LocalMatlab(str2num(out.epochtime),siteDB.timezone.gmt_offset);
tidelevel = CSPgetTideLevel(str2num(out.epochtime),site);
user = strrep(out.user,'_','');
txt = ['Date: ' datestr(matlablocal,'yyyy/mm/dd') ' Time: ' datestr(matlablocal,'HH:MM') ' Contributor: ' user ' Tide level: ' num2str(tidelevel,'%0.2f') 'm AHD'];
h=text(XL(1)+0.02*diff(XL),YL(1)+0.02*diff(YL),txt,'color',0.2*[1 1 1]);
h.HorizontalAlignment = 'left';
h.FontSize = 12;
print(fullfile(photoshoptemp_dir,strrep(fname,'.jpg','_registered.jpg')),'-r400','-djpeg')
close all
end