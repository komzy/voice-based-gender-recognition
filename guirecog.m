function varargout = guirecog(varargin)
% GUIRECOG M-file for guirecog.fig
%      GUIRECOG, by itself, creates a new GUIRECOG or raises the existing
%      singleton*.
%
%      H = GUIRECOG returns the handle to a new GUIRECOG or the handle to
%      the existing singleton*.
%
%      GUIRECOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIRECOG.M with the given input arguments.
%
%      GUIRECOG('Property','Value',...) creates a new GUIRECOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guirecog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guirecog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guirecog

% Last Modified by GUIDE v2.5 01-May-2014 22:20:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guirecog_OpeningFcn, ...
                   'gui_OutputFcn',  @guirecog_OutputFcn, ...
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


% --- Executes just before guirecog is made visible.
function guirecog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guirecog (see VARARGIN)

% Choose default command line output for guirecog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guirecog wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = guirecog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

set(handles.box,'string','Estimated Gender: ---             Fundamental Frequency: ---')
% --- Executes on button press in record.
function record_Callback(hObject, eventdata, handles)
% hObject    handle to record (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
time = get(handles.slider,'Value');
global audio fs cepstrum ms1 ms2;
fs=8000;
obj= audiorecorder(fs,16,1);
recordblocking(obj,time)
set(handles.box, 'String', 'End of Recording');
audio=getaudiodata(obj);
ms1=fs/260;                 % maximum speech Fx at 260Hz
ms2=fs/75;                  % minimum speech Fx at 75Hz
% do fourier transform of windowed signal
Y=fft(audio.*hamming(length(audio)));
% cepstrum is FFT of log spectrum
cepstrum=fft(log(abs(Y)+eps)); 


% --- Executes on button press in play.
function play_Callback(hObject, eventdata, handles)
% hObject    handle to play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global audio fs;
player = audioplayer(audio, fs);
playblocking(player);


% --- Executes on button press in plot.
function plot_Callback(hObject, eventdata, handles)
% hObject    handle to plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global audio fs cepstrum ms1 ms2;
t=(0:length(audio)-1)/fs;
axes(handles.axes1);
plot(t,audio);
xlabel('Time (s)');
ylabel('Amplitude');

% plot between 3.8ms (=260Hz) and 13.3ms (=75Hz)
q=(ms1:ms2)/fs;
axes(handles.axes2);
plot(q,abs(cepstrum(ms1:ms2)));
xlabel('Quefrency (s)');
ylabel('Amplitude');




% --- Executes on button press in compute.
function compute_Callback(hObject, eventdata, handles)
% hObject    handle to compute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get a section of vowel
global cepstrum fs ms1 ms2;
% determining fundamental frequency
[c,fx]=max(abs(cepstrum(ms1:ms2)));
freq=fs/(ms1+fx-1);

if freq<= 175 && freq >=80
        d=['Estimated Gender: Male          Fundamental Frequency: ',num2str(round(freq))];
        set(handles.box,'string',d);
        
    elseif freq>175 && freq<=255
    d=['Estimated Gender: Female          Fundamental Frequency: ',num2str(round(freq))];
     set(handles.box,'string',d);
    else
        d=['Unable to recognize. Try speaking slowly. Fundamental Frequency: ',num2str(round(freq))];
         set(handles.box,'string',d);
end


function box_Callback(hObject, eventdata, handles)
% hObject    handle to box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of box as text
%        str2double(get(hObject,'String')) returns contents of box as a double


% --- Executes during object creation, after setting all properties.
function box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_Callback(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
time = get(handles.slider,'Value');
set(handles.time_text, 'String', num2str(time));
 guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function time_text_Callback(hObject, eventdata, handles)
% hObject    handle to time_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time_text as text
%        str2double(get(hObject,'String')) returns contents of time_text as a double


% --- Executes during object creation, after setting all properties.
function time_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[0.94 0.94 0.94]);
end
