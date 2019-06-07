function CSPGcropShorelinePoints(handles)

%Get user data stored in axes
data = get(handles.oblq_image,'UserData');
data_plan = get(handles.plan_image,'UserData');

%Remove plotted shorelines from figure and replace with dash-dot
delete(data.sl_handle_oblq);
delete(data_plan.sl_handle_plan);
axes(handles.plan_image)
hold on
data.sl_handle_plan = plot(data_plan.sl.xyz(:,1),data_plan.sl.xyz(:,2),'b.-','markersize',10);
axes(handles.oblq_image)
hold on
data.sl_handle_oblq = plot(data_plan.sl.UV(:,1),data_plan.sl.UV(:,2),'b.-','markersize',10);

%Edit points using impoly
h = impoly(handles.plan_image,'closed',0);
disp('Select region you want to crop')
croppos = getPosition(h);
delete(h)
Icrop = find(inpolygon(data_plan.sl.xyz(:,1),data_plan.sl.xyz(:,2),croppos(:,1),croppos(:,2)));
axes(handles.oblq_image)
h_crop_oblq=plot(data_plan.sl.UV(Icrop,1),data_plan.sl.UV(Icrop,2),'rx');
axes(handles.plan_image)
h_crop_plan=plot(data_plan.sl.xyz(Icrop,1),data_plan.sl.xyz(Icrop,2),'rx');

%Ask user if they want to delete these points
ButtonName = questdlg('Do you want to crop the points shown in red?','Crop points?','Yes','No','No');
switch ButtonName
    case 'No'
        disp('Points not cropped')
    case 'Yes'
        data_plan.sl.xyz(Icrop,:) = [];
        data_plan.sl.UV(Icrop,:) = [];
        data_plan.sl.UTM(Icrop,:) = [];
        disp([num2str(length(Icrop)) ' points cropped'])
end

%Update figure with new shoreline
delete(h_crop_oblq); delete(h_crop_plan); delete(data.sl_handle_plan); delete(data.sl_handle_oblq);
axes(handles.oblq_image)
zoom off
data.sl_handle_oblq = plot(data_plan.sl.UV(:,1),data_plan.sl.UV(:,2),'y','linewidth',2);
axes(handles.plan_image)
zoom off
data_plan.sl_handle_plan=plot(data_plan.sl.xyz(:,1),data_plan.sl.xyz(:,2),'y','linewidth',2);

%Send new data to GUI
set(handles.plan_image,'UserData',data_plan)
set(handles.oblq_image,'UserData',data)




