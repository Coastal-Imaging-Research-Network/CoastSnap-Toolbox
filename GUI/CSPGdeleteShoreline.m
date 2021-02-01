function CSPGdeleteShoreline(handles)

CSPloadPaths
data = get(handles.oblq_image,'UserData');
data_plan = get(handles.plan_image,'UserData');
fileparts = CSPparseFilename(data.fname);
site = fileparts.site;

%First check that a shoreline exists
if isempty(data_plan.sl)||~isfield(data_plan,'sl')
    warning('No shoreline exists to save!')
else
    button = questdlg('Are you sure you want to delete this shoreline from the database?','Delete Shoreline?','Yes','No','No');
    switch button
        case 'Yes'
            savedir = [shoreline_path filesep fileparts.site filesep fileparts.year filesep];
            savefname = strrep(data.fname,'snap','shoreline');
            savefname = strrep(savefname,'timex','shoreline');
            savefname = strrep(savefname,'.jpg','.mat');
            delete(fullfile(savedir,savefname))
            disp('Shoreline deleted from DB!')
    end
end
    