function varargout = dialogExample(varargin)
% DIALOGEXAMPLE M-file for dialogExample.fig
%      DIALOGEXAMPLE, by itself, creates a new DIALOGEXAMPLE or raises the existing
%      singleton*.
%
%      H = DIALOGEXAMPLE returns the handle to a new DIALOGEXAMPLE or the handle to
%      the existing singleton*.
%
%      DIALOGEXAMPLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIALOGEXAMPLE.M with the given input arguments.
%
%      DIALOGEXAMPLE('Property','Value',...) creates a new DIALOGEXAMPLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dialogExample_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dialogExample_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dialogExample

% Last Modified by GUIDE v2.5 24-Sep-2010 14:30:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dialogExample_OpeningFcn, ...
                   'gui_OutputFcn',  @dialogExample_OutputFcn, ...
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


% --- Executes just before dialogExample is made visible.
function dialogExample_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dialogExample (see VARARGIN)

% Choose default command line output for dialogExample
handles.output = hObject;

% For this example we either use an example file from the sample_xml
% directory or we get a file name from the command line.
if isempty(varargin)
    % No arguments - set defaults file to flybowl_defaults in sample_xml
    defaultsFile = ['..', filesep, 'sample_xml', filesep, 'flybowl_defaults.xml'];
else
    % Set defaults file first argument.
    defaultsFile = varargin{1};
end

% Set initial mode for GUI
handles = setInitialMode(handles,'basic');

% Load XML defaults file. Creates handles.defaultsTree object and sets
% handles.defatulsFile
handles = loadDefaultsFile(handles,defaultsFile);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dialogExample wait for user response (see UIRESUME)
% uiwait(handles.mainFigure);


% --- Outputs from this function are returned to the command line.
function varargout = dialogExample_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in opendDialogPushButton.
function opendDialogPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to opendDialogPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('open dialog')
dialogHdl = basicMetaDataDlg(handles.defaultsTree,handles.mode);
uiwait(dialogHdl);
% Update handles structure - this is required because handles.defaultsTree
% had changed.  
guidata(hObject, handles);

% --- Executes on button press in saveMetaDataPushButton.
function saveMetaDataPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveMetaDataPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('save metadata');
saveDialogName = 'Save metadata to XML file';
[fileName, pathName, ~] =  uiputfile('metadata_test_write.xml', saveDialogName);
if ~fileName == 0
    fileName = [pathName,fileName];
    metaDataTree = createXMLMetaData(handles.defaultsTree);
    metaDataTree.write(fileName);
end

% --- Executes on button press in loadDefaultsPushButton.
function loadDefaultsPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadDefaultsPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('load defaults file');
[fileName, pathName, ~] = uigetfile('.xml');
if ~fileName == 0
    fileName = [pathName,fileName];
    handles = loadDefaultsFile(handles,fileName);
end
% Update handles structure
guidata(hObject, handles);
    
% --- Executes on button press in savedefaultspushbuttton.
function saveDefaultsPushButtton_Callback(hObject, eventdata, handles)
% hObject    handle to savedefaultspushbuttton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('save defaults')
saveDialogName = 'Save defaults metadata to XML file';
[fileName, pathName, ~] = uiputfile('defaults_test_write.xml',saveDialogName);
if ~fileName == 0
   fileName = [pathName,fileName];
   handles.defaultsTree.write(fileName);
end

% --- Executes when selected object is changed in modeButtonGroup.
function modeButtonGroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in modeButtonGroup 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'basicRadioButton'
        % Code for when radiobutton1 is selected.
        handles.mode = 'basic';
        disp('mode changed to basic');
    case 'advancedRadioButton'
        % Code for when radiobutton2 is selected.
        handles.mode = 'advanced';
        disp('mode changed to advanced');
    otherwise
        % Code for when there is no match.
        error('Unknown radio button - this should not happen');
end
% Update handles structure
guidata(hObject, handles);


% Utility Functions
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
function setCurrentFileText(handles,value)
% Set value of current file text
text = sprintf('Current File: %s', value);
set(handles.currentFileText,'String', text);

% -------------------------------------------------------------------------
function handles = loadDefaultsFile(handles, fileName)
% This function loads the XML Defatuls data file
try
    handles.defaultsTree = loadXMLDefaultsTree(fileName);
catch ME
    warnmsg = sprintf('unable to load defaults file: %s, %s', fileName,ME.message);
    warndlg(warnmsg, 'File load Error');
    return;
end
handles.defaultsFile = fileName;
setCurrentFileText(handles,fileName);

% -------------------------------------------------------------------------
function handles = setInitialMode(handles,mode)
% Sets initial mode for GUI
switch lower(mode)
    case 'basic'
        set(handles.basicRadioButton,'Value', true);
    case 'advanced'
        set(handles.advancedRadioButton,'Value', true);
    otherwise
        error('unrecognized mode %s',mode);
        set(handles.basicRadioButton,'Value', true);
        mode = 'basic';
end
handles.mode = mode;



