function out = CSPGgetVirtualGCP(handles)

data = get(handles.oblq_image,'UserData'); %Get data stored in the userdata in the oblq_image handles
siteDB = data.siteDB;
I = data.I;
axes(handles.oblq_image) %Plot gpcs on GUI axis

%First, check if image has already been rectified
fileparts = CSPparseFilename(data.fname);
rect_path = strrep(data.pname,'Processed','Rectified');
rect_path = strrep(rect_path,'Registered','Rectified'); %For Registered images
rect_name = strrep(data.fname,'snap','plan'); %Rectified is called plan to keep with Argus conventions
rect_name = strrep(rect_name,'timex','plan'); %For timex images


if ~exist(fullfile(rect_path,rect_name),'file')
    errordlg('Image has not been rectified. Please rectify image to obtain image geometry');
else
    zoom on;
    pause()
    zoom off;
    UVvirtual = ginput(1);
    load(strrep(fullfile(rect_path,rect_name),'.jpg','.mat'));
    XYZvirtual = findXYZ6dof(UVvirtual(1),UVvirtual(2),0,metadata.geom.betas,metadata.geom.lcp);
    UTMvirtual = [XYZvirtual(1)+siteDB.origin.eastings XYZvirtual(2)+siteDB.origin.northings 0];
    msgbox(['Virtual GCP coordinate in UTM is (' num2str(UTMvirtual(1),'%0.2f') 'm, ' num2str(UTMvirtual(2),'%0.2f') 'm, 0m)'],'Virtual GCP Coordinate');
end
