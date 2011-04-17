function varargout = multiSelectDlg(varargin)
% MULTISELECTDLG MATLAB code for multiSelectDlg.fig
%      MULTISELECTDLG, by itself, creates a new MULTISELECTDLG or raises the existing
%      singleton*.
%
%      H = MULTISELECTDLG returns the handle to a new MULTISELECTDLG or the handle to
%      the existing singleton*.
%
%      MULTISELECTDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MULTISELECTDLG.M with the given input arguments.
%
%      MULTISELECTDLG('Property','Value',...) creates a new MULTISELECTDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before multiSelectDlg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to multiSelectDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help multiSelectDlg

% Last Modified by GUIDE v2.5 16-Apr-2011 15:01:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @multiSelectDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @multiSelectDlg_OutputFcn, ...
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


% --- Executes just before multiSelectDlg is made visible.
function multiSelectDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to multiSelectDlg (see VARARGIN)

% Choose default command line output for multiSelectDlg
handles.uiwait_flag = 1;
handles.output = '';
handles.emptyMarker = '-';

% Get arguments. 
if length(varargin) > 0
    allowedValues = varargin{1};
else
    % Temporary - for development purposes. 
    allowedValues = {'alan', 'bob', 'steve', 'dave', 'gary', 'bill'};
end

if length(varargin) > 1
    handles.includeEmpty = varargin{2};
else
    handles.includeEmpty = true;
end

if length(varargin) > 2
    handles.nameStr = varargin{3};
else
    handles.nameStr = 'MultiSelect Dialog';
end
set(handles.multiSelectFigure,'Name', handles.nameStr);

if handles.includeEmpty == true
    handles.allowedValues = {handles.emptyMarker, allowedValues{:}};
else
    handles.allowedValues = allowedValues;
end

set(handles.select_Listbox,'String', handles.allowedValues);
handles = updateValuesString(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes multiSelectDlg wait for user response (see UIRESUME)
if handles.uiwait_flag == 1
    uiwait(handles.multiSelectFigure);
end

% --- Executes when user attempts to close multiSelectFigure.
function multiSelectFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to multiSelectFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if handles.uiwait_flag ~=0  
    if isequal(get(hObject, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        set(handles.multiSelectFigure,'WindowStyle', 'normal');
        uiresume(hObject);
    else
        % The GUI is no longer waiting, just close it
        delete(hObject);
    end
else
    delete(hObject);
end


% --- Outputs from this function are returned to the command line.
function varargout = multiSelectDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% The figure can be deleted now
if handles.uiwait_flag ~=0
    delete(handles.multiSelectFigure);
end

% --- Executes on selection change in select_Listbox.
function select_Listbox_Callback(hObject, eventdata, handles)
% hObject    handle to select_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns select_Listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_Listbox

handles = updateValuesString(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function select_Listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OK_Pushbutton.
function OK_Pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to OK_Pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = handles.valuesString;
guidata(hObject, handles);
close(handles.multiSelectFigure);

% --- Executes on button press in Cancel_Pushbutton.
function Cancel_Pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel_Pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = '';
guidata(hObject, handles);
close(handles.multiSelectFigure);

% -------------------------------------------------------------------------
function handles = updateValuesString(handles)
% Sets the output string based on the current value. 
ind = get(handles.select_Listbox,'Value');
selectString = get(handles.select_Listbox,'String');
values = selectString(ind);
valuesString = '';
cnt  = 0;
for i = 1:length(values)
   if values{i} == handles.emptyMarker
      continue; 
   end
   cnt = cnt + 1;
   if cnt == 1
       valuesString = values{i};
   else
       valuesString = sprintf('%s, %s', valuesString, values{i});
       
   end
end
handles.valuesString = valuesString;


