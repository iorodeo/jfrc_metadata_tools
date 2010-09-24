function varargout = basicMetaDataDlg(varargin)
% BASICMETADATADLG M-file for basicMetaDataDlg.fig
%      BASICMETADATADLG, by itself, creates a new BASICMETADATADLG or raises the existing
%      singleton*.
%
%      H = BASICMETADATADLG returns the handle to a new BASICMETADATADLG or the handle to
%      the existing singleton*.
%
%      BASICMETADATADLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BASICMETADATADLG.M with the given input arguments.
%
%      BASICMETADATADLG('Property','Value',...) creates a new BASICMETADATADLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before basicMetaDataDlg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to basicMetaDataDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help basicMetaDataDlg

% Last Modified by GUIDE v2.5 24-Sep-2010 10:59:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @basicMetaDataDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @basicMetaDataDlg_OutputFcn, ...
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


% --- Executes just before basicMetaDataDlg is made visible.
function basicMetaDataDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to basicMetaDataDlg (see VARARGIN)

% Choose default command line output for basicMetaDataDlg
handles.output = hObject;

if isempty(varargin)
    error('basicMetaDataDlg requires at least one input argument, defaultsTree');
end

% Set optional argument mode if it is not given.
if length(varargin) < 2
    mode = 'basic';
else
    mode = varargin{2};
end
defaultsTree = varargin{1};

% Create JIDE property grid and add it to figure. 
% Note, the 'HandleVisilbility' of the figure must be set to 'on' for this 
% to work properly. For this example I set it to 'on' in guide.
pgrid = PropertyGrid(handles.dialogFigure,'Position', [0 0.1 1 0.9]);

pgrid.setDefaultsTree(defaultsTree);
pgrid.setMode(mode);

handles.defaultsTree = defaultsTree;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes basicMetaDataDlg wait for user response (see UIRESUME)
%uiwait(handles.dialogFigure);


% --- Outputs from this function are returned to the command line.
function varargout = basicMetaDataDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close dialogFigure.
function dialogFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to dialogFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check to see if tree has all required manual entry values
exitFlag = true;
if handles.defaultsTree.hasValuesNeeded('manual') == false
    % Create message showing values still required.
    msg = sprintf('Values required:\n\n');
    valuesNeeded = handles.defaultsTree.getValuesNeeded('manual');
    for i = 1:length(valuesNeeded)
        displayString = cleanPathString(valuesNeeded{i});
        msg = sprintf('%s%s\n',msg, displayString);
    end
    % Create dialog displaying values still required and asking if use want
    % to quit
    msg = sprintf('Not all required values have been entered\n\n%s',msg);
    msg = sprintf('%s\nDo you really want to quit?',msg);
    answer = questdlg(msg,'Exit', 'yes', 'no', 'no');
    switch lower(answer)
        case 'yes'
            exitFlag = true;
        otherwise
            exitFlag = false;
    end
end

% Set temperature and humidity values in xml defaults Tree

% Hint: delete(hObject) closes the figure
if exitFlag == true
    delete(hObject);
end

function outPathString = cleanPathString(inPathString)
% Cleans up path strings for displaying them in dialogs. Basically just
% remove the .content part of the path string if it refers to a content
% node.
if length(inPathString) > length('content')
    endString = inPathString(end-length('content')+1:end);
    if strcmpi(endString,'content')
        outPathString = inPathString(1:end-length('content')-1);
    else
        outPathString = inPathString;
    end
else
    outPathString = inPathString;
end
