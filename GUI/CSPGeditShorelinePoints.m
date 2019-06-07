function CSPGeditShorelinePoints(handles)

%Get user data stored in axes
data = get(handles.oblq_image,'UserData');
data_plan = get(handles.plan_image,'UserData');

%Edit points using impoly
sl = data_plan.sl;
metadata = data_plan.metadata;
siteDB = data.siteDB;
h = impoly(handles.plan_image,sl.xyz(:,1:2),'closed',0);
disp('Please edit your shoreline now or press any key to continue')
pause
zoom off
newpos = getPosition(h);
delete(h)
delete(data.sl_handle_oblq);
delete(data_plan.sl_handle_plan);

%Update newly edited points
xyz = NaN(size(newpos,1),3);
xyz(:,1:2) = newpos;
xyz(:,3) = sl.xyz(1,3)*ones(size(newpos,1),1);
UTM = [xyz(:,1)+siteDB.origin.eastings xyz(:,2)+siteDB.origin.northings metadata.rectz*ones(size(xyz(:,1)))];
UV = findUVnDOF(metadata.geom.betas,xyz,metadata.geom); %Its good practise to store the original Image UV data of the shoreline so you don't have to redo the geometry
UV = reshape(UV,size(xyz,1),2);
data_plan.sl.xyz = xyz;
data_plan.sl.UV = UV;
data_plan.sl.UTM = UTM;

%Plot edited data;
axes(handles.oblq_image)
data.sl_handle_oblq = plot(UV(:,1),UV(:,2),'y','linewidth',2);
axes(handles.plan_image)
data_plan.sl_handle_plan=plot(xyz(:,1),xyz(:,2),'y','linewidth',2);

%Send new data to GUI
set(handles.plan_image,'UserData',data_plan)
set(handles.oblq_image,'UserData',data)







