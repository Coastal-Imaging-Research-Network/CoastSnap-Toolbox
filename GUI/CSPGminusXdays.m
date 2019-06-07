function CSPGminusXdays(handles)

%Get data from handles
data = get(handles.oblq_image,'UserData');

%Find present image in set of images all within a similar tide
I = find(data.navigation.epochs==data.epoch);
timestep = str2num(get(handles.timestep,'String')); %in days
timestep_seconds = timestep*3600*24; %in seconds to conform with epoch time
Inew = interp1(data.navigation.epochs,1:length(data.navigation.epochs),data.epoch-timestep_seconds,'nearest','extrap'); %Minus
newpath = data.navigation.paths(Inew).name; %Step one forward
newfile = data.navigation.files(Inew).name; %Step one forward

%Reload data to GUI with new image path and file
if Inew==I
    warning('The image found is the same as the present image. Try increasing the timestep to search further into the past')
else
    %Reload data to GUI with new image path and file
    CSPGloadImage(handles,newpath,newfile);
end