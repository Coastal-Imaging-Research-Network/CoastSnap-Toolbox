%Add relevant paths to Matlab
rectify_code_path = fullfile(strrep(which('CSPloadPaths'),'CSPloadPaths.m',''),'rectifyCode'); %Path with additional rectify code from CIRN toolbox
tools_path = fullfile(strrep(which('CSPloadPaths'),'CSPloadPaths.m',''),'tools'); %Path with additional rectify code from CIRN toolbox
support_routines_path = 'C:\Users\z2273773\OneDrive - UNSW\RESEARCH2\GitHub\Support-Routines'; %Path where support routines are stored (e.g. matlab2Epoch)
shoreline_mapping_toolbox_path = 'C:\Users\z2273773\OneDrive - UNSW\RESEARCH2\GitHub\CoastSnap-Toolbox'; %Path where the shoreline mapping toolbox is located

addpath(rectify_code_path)
addpath(tools_path)
addpath(support_routines_path)
addpath(shoreline_mapping_toolbox_path)