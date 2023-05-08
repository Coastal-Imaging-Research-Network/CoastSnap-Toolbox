function CSPplotParticipationStatistics(site,startdate,enddate,rootID)

%Find path of DB file
CSPloadPaths
dbfile = fullfile([DB_path filesep 'CoastSnapDB.xlsx']);
exportfile = fullfile([DB_path filesep 'spotteron_export.xlsx']); %File exported from spotteron db, converted to Excel first
[data,txt] = xlsread(dbfile,'database');
siteDB = CSPreadSiteDB(site); %Read metadata

%Read image times - make sure Excel format is as below
if isempty(strfind(txt{2,3},'PM'))||isempty(strfind(txt{2,3},'AM')) %if using AM/PM
    imtimes = datenum(char(txt{2:end,3}),'dd/mm/yyyy HH:MM:SS AM');
else
    imtimes = datenum(char(txt{2:end,3}),'dd/mm/yyyy HH:MM:SS'); %if using 24 hour clock
end

%Convert to GMT time
imtimesGMT = imtimes;
Idefault= find(strcmp(txt(2:end,4),siteDB.timezone.name)); %e.g. AEDT = Australian Eastern Daylight Time
imtimesGMT(Idefault) = imtimesGMT(Idefault)-siteDB.timezone.gmt_offset/24; %Subtract the offset in hours to convert to gmt time
Ialternative = find(strcmp(txt(2:end,4),siteDB.timezone.alternative.name)); %e.g. AEDT = Australian Eastern Daylight Time
imtimesGMT(Ialternative) = imtimesGMT(Ialternative)-siteDB.timezone.alternative.gmt_offset/24; %Subtract the offset in hours to convert to default
imtimesLocal = imtimesGMT+siteDB.timezone.gmt_offset/24;

% %Get images coming from App not listed in DB
% [epochtimes,filenames,~,~] = CSPgetImageList(site,'Processed');
% I = NaN(length(epochtimes),1);
% for i = 1:length(epochtimes)
%     Iapp = strfind(filenames(i).name,'+'); %If taken by app, filename has a + in it instead of AEST
%     if isempty(Iapp)
%         I(i) = 0;
%     else
%         I(i) = 1;
%     end
% end
% Iapp = find(I==1);
% apptimes = CSPepoch2LocalMatlab(epochtimes(Iapp),siteDB.timezone.gmt_offset);
%Get images coming from App not listed in DB

[data1,txt1] = xlsread(exportfile);
Iroot = find(data1(:,2)==rootID); %RootID is 2nd column in export file. UPDATE It might be 1st column
apptimes=datenum(char(txt1{Iroot+1,17}),'dd/mm/yyyy HH:MM:SS AM');

dd = startdate:enddate;
for i = 1:length(dd)
J1 = find(floor(imtimesLocal)==dd(i)&strcmp(txt(2:end,1),site));
J2=find(floor(apptimes)==dd(i));
N(i) = length(J1)+length(J2);
end

cN = cumsum(N);
%cN(cN==0) = NaN;
%cN(1) = 0;

%Get submission types
subtypes = {'Email','Facebook','Twitter','Instagram','App'};
subtypes_count = NaN(length(subtypes),1);
for i = 1:length(subtypes)-1
    J = find(strcmp(txt(2:end,6),subtypes{i})&strcmp(txt(2:end,1),site));
    subtypes_count(i) = length(J);
end
subtypes_count(end) = length(apptimes);

width = 30;
height = 9;
piesize = 8;
geomplot(1,1,1,1,width,height,[1.4 piesize],[0.4 1.2],[0 0])
plot(dd,cN,'b','linewidth',1)
hold on
datetick('x')
set(gca,'fontsize',10)
xlabel('Month','fontsize',12)
ylabel('Cumulative images','fontsize',12)
set(gca,'ygrid','on')
set(gcf,'color','w')
xlim([startdate enddate])
%title(['Cumulative number of images:' datestr(startdate,'dd/mm/yyyy') ' - ' datestr(enddate,'dd/mm/yyyy')],'Fontsize',10)
%print 'Cumulative_Posts.jpg' -r600 -djpeg
XL = xlim;
YL = ylim;
text_title1 = ['Cumulative number of images:'];
text_title2 = [datestr(startdate,'dd/mm/yyyy') ' - ' datestr(enddate,'dd/mm/yyyy')];
text(XL(1)+0.1*diff(XL),YL(1)+0.8*diff(YL),text_title1,'fontsize',14,'fontweight','bold')
text(XL(1)+0.1*diff(XL),YL(1)+0.71*diff(YL),text_title2,'fontsize',14,'fontweight','bold')


geomplot(1,1,1,1,width,height,[width-piesize 0],[0.4 1],[0 0])
h1=pie(subtypes_count);
h1(2).FontSize = 10;
h1(4).FontSize = 10;
h1(6).FontSize = 10;
if length(h1)>=8
    h1(8).FontSize = 10;
end
h = legend(subtypes,'Location','southoutside');%,'Orientation','horizontal');
h.FontSize = 10;
title(h,'Submission type');
%title('Image submission type')

%Get most popular time of day
J = find(strcmp(txt(2:end,1),site));
M = datevec(imtimesLocal(J));
disp(['Most popular day of week is ' num2str(mode(weekday(imtimesLocal(J))))])
disp(['Most popular time of day is ' num2str(mode(M(:,4)))])
disp(['Total number of submissions is ' num2str(cN(end))])
disp(['Average number of submissions per week is ' num2str(7*cN(end)/((1+(enddate-startdate))),'%0.1f')])



