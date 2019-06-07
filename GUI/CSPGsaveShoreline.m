function CSPGsaveShoreline(handles)

CSPloadPaths
data = get(handles.oblq_image,'UserData');
data_plan = get(handles.plan_image,'UserData');
fileparts = CSPparseFilename(data.fname);
site = fileparts.site;

%First check that a shoreline exists
if isempty(data_plan.sl)||~isfield(data_plan,'sl')
    warning('No shoreline exists to save!')
else
    button = questdlg('Do you want to save this shoreline to the database?','Save to DB?','Yes','No','No');
    switch button
        case 'Yes'
            sl = data_plan.sl;
            savedir = [shoreline_path filesep fileparts.site filesep fileparts.year filesep];
            savefname = strrep(data.fname,'snap','shoreline');
            savefname = strrep(savefname,'timex','shoreline');
            savefname = strrep(savefname,'.jpg','.mat');
            save(fullfile(savedir,savefname),'sl')
            disp('Shoreline saved to DB!')
    end
end
    