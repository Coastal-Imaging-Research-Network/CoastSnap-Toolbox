function CSPGnextImage(handles)

%Get data from handles
data = get(handles.oblq_image,'UserData');

%Find present image in set of images all within a similar tide
I = find(data.navigation.epochs==data.epoch);
newpath = data.navigation.paths(I+1).name; %Step one forward
newfile = data.navigation.files(I+1).name; %Step one forward

%Reload data to GUI with new image path and file
CSPGloadImage(handles,newpath,newfile);