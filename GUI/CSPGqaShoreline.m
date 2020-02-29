function out = CSPGqaShoreline(handles)

data = get(handles.oblq_image,'UserData'); %Get data stored in the userdata in the oblq_image handles
siteDB = data.siteDB;
gcp_list = CSPgetGCPcombo(siteDB,data.epoch);
I = data.I;
axes(handles.oblq_image) %Plot gpcs on GUI axis
