function varargout = CSP(varargin)
% CSP MATLAB code for CSP.fig
%      CSP, by itself, creates a new CSP or raises the existing
%      singleton*.
%
%      H = CSP returns the handle to a new CSP or the handle to
%      the existing singleton*.
%
%      CSP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CSP.M with the given input arguments.
%
%      CSP('Property','Value',...) creates a new CSP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CSP_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CSP_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CSP

% Last Modified by GUIDE v2.5 28-Feb-2021 18:14:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CSP_OpeningFcn, ...
                   'gui_OutputFcn',  @CSP_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before CSP is made visible.
function CSP_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, sepe OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CSP (see VARARGIN)

% Choose default command line output for CSP
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CSP wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%Get UserData
set(handles.oblq_image, 'UserData',[]);
set(handles.plan_image, 'UserData',[]);
set(handles.oblq_image, 'Visible','off');
set(handles.plan_image, 'Visible','off');
CSPloadPaths %Load coastsnap paths
userData.path = image_path;
%userData.sl_handle_oblq = [];
set(handles.oblq_image, 'UserData',userData);
%data_plan.sl_handle_plan = [];
%set(handles.plan_image, 'UserData',data_plan);


% --- Outputs from this function are returned to the command line.
function varargout = CSP_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function loadimage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadimage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% get new path from default or already loaded



% --- Executes on button press in loadimage.
function loadimage_Callback(hObject, eventdata, handles)
% hObject    handle to loadimage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CSPGloadImage(handles);



% --- Executes on button press in rectimage.
function rectimage_Callback(hObject, eventdata, handles)
% hObject    handle to rectimage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CSPGrectifyImage(handles);


% --- Executes on button press in mapshoreline.
function mapshoreline_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mapshoreline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in mapshoreline.
function mapshoreline_Callback(hObject, eventdata, handles)
% hObject    handle to mapshoreline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CSPGmapShoreline(handles)

% --- Executes on button press in editshorelinepoints.
function editshorelinepoints_Callback(hObject, eventdata, handles)
% hObject    handle to editshorelinepoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CSPGeditShorelinePoints(handles)

% --- Executes on button press in maketrendplot.
function maketrendplot_Callback(hObject, eventdata, handles)
% hObject    handle to maketrendplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CSPGmakeTrendPlot(handles)

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on button press in cropshorelinepoints.
function cropshorelinepoints_Callback(hObject, eventdata, handles)
% hObject    handle to cropshorelinepoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CSPGcropShorelinePoints(handles)

% --- Executes on button press in saveshoreline.
function saveshoreline_Callback(hObject, eventdata, handles)
% hObject    handle to saveshoreline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CSPGsaveShoreline(handles)

% --- Executes on button press in NextImage.
function NextImage_Callback(hObject, eventdata, handles)
% hObject    handle to NextImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CSPGnextImage(handles)

% --- Executes on button press in PreviousImage.
function PreviousImage_Callback(hObject, eventdata, handles)
% hObject    handle to PreviousImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CSPGpreviousImage(handles)

% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Settings_Callback(hObject, eventdata, handles)
% hObject    handle to Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in minusXdays.
function minusXdays_Callback(hObject, eventdata, handles)
% hObject    handle to minusXdays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CSPGminusXdays(handles)

% --- Executes on button press in plusXdays.
function plusXdays_Callback(hObject, eventdata, handles)
% hObject    handle to plusXdays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CSPGplusXdays(handles)

function timestep_Callback(hObject, eventdata, handles)
% hObject    handle to timestep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timestep as text
%        str2double(get(hObject,'String')) returns contents of timestep as a double


% --- Executes during object creation, after setting all properties.
function timestep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timestep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function trendinterval_Callback(hObject, eventdata, handles)
% hObject    handle to trendinterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trendinterval as text
%        str2double(get(hObject,'String')) returns contents of trendinterval as a double


% --- Executes during object creation, after setting all properties.
function trendinterval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trendinterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PlotShorelineChange.
function PlotShorelineChange_Callback(hObject, eventdata, handles)
% hObject    handle to PlotShorelineChange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CSPGmakeShorelineChangePlot(handles)



function previousshoreline_Callback(hObject, eventdata, handles)
% hObject    handle to previousshoreline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of previousshoreline as text
%        str2double(get(hObject,'String')) returns contents of previousshoreline as a double


% --- Executes during object creation, after setting all properties.
function previousshoreline_CreateFcn(hObject, eventdata, handles)
% hObject    handle to previousshoreline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tidetolerance_Callback(hObject, eventdata, handles)
% hObject    handle to tidetolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tidetolerance as text
%        str2double(get(hObject,'String')) returns contents of tidetolerance as a double


% --- Executes during object creation, after setting all properties.
function tidetolerance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tidetolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadgeometry.
function loadgeometry_Callback(hObject, eventdata, handles)
% hObject    handle to loadgeometry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CSPGloadExistingGeometry(handles)

% --- Executes on button press in bulkrectandmap.
function bulkrectandmap_Callback(hObject, eventdata, handles)
% hObject    handle to bulkrectandmap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CSPGbulkRectAndMap(handles)


% --- Executes on button press in qashoreline.
function qashoreline_Callback(hObject, eventdata, handles)
% hObject    handle to qashoreline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CSPGdeleteShoreline(handles)



% --------------------------------------------------------------------
function Menu_tools_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_tools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function getVirtualGCP_Callback(hObject, eventdata, handles)
% hObject    handle to getVirtualGCP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CSPGgetVirtualGCP(handles)



% --------------------------------------------------------------------
function Menu_Advanced_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_Advanced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function makeAnimation_Callback(hObject, eventdata, handles)
% hObject    handle to makeAnimation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CSPGmakeBeachWidthAnimation(handles)
