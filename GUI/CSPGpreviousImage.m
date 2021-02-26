function CSPGpreviousImage(handles)

%Get data from handles
data = get(handles.oblq_image,'UserData');

%Find present image in set of images all within a similar tide
I = find(data.navigation.epochs==data.epoch);
if I>1
    newpath = data.navigation.paths(I-1).name; %Step one back
    newfile = data.navigation.files(I-1).name; %Step one back
    
    %Reload data to GUI with new image path and file
    CSPGloadImage(handles,newpath,newfile);
else
    disp('You have stepped to the first image')
end
 
