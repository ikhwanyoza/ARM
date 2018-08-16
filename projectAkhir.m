function varargout = projectAkhir(varargin)
% PROJECTAKHIR M-file for projectAkhir.fig
%      PROJECTAKHIR, by itself, creates a new PROJECTAKHIR or raises the existing
%      singleton*.
%
%      H = PROJECTAKHIR returns the handle to a new PROJECTAKHIR or the handle to
%      the existing singleton*.
%
%      PROJECTAKHIR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJECTAKHIR.M with the given input arguments.
%
%      PROJECTAKHIR('Property','Value',...) creates a new PROJECTAKHIR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before projectAkhir_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to projectAkhir_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help projectAkhir

% Last Modified by GUIDE v2.5 25-Nov-2016 13:49:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @projectAkhir_OpeningFcn, ...
                   'gui_OutputFcn',  @projectAkhir_OutputFcn, ...
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


% --- Executes just before projectAkhir is made visible.
function projectAkhir_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to projectAkhir (see VARARGIN)
% Choose default command line output for projectAkhir
handles.output = hObject;

%cam = webcam('USB2.0 HD UVC WebCam');
global vid;
axes(handles.axes1);
vid = videoinput('winvideo', 1, 'YUY2_640x480');
%vid = videoinput('winvideo', 2, 'RGB24_320x240');
%himage=image(zeros(320,240,3),'parent',handles.axes1);
set(vid, 'TriggerRepeat', Inf);
vid.returnedcolorspace = 'rgb';
vid.FrameGrabInterval = 2;
%cam.Resolution = '320x240';

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes projectAkhir wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = projectAkhir_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in start.
function start_Callback(~, ~, ~)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in help.
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in koneksi.
function koneksi_Callback(hObject, eventdata, handles)
% hObject    handle to koneksi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global G
myform = guidata(gcbo)
aa = get(myform.edit1, 'string');
ab = str2double(get(myform.edit2, 'string'));
G = serial(aa, 'Baudrate', ab, 'DataBits', 8, 'StopBits', 1, 'InputBufferSize', 16000);
fopen(G);

%%%%%%%
global vid;
blackImage = 0 * ones(480, 640 );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while(vid.FramesAcquired<=100)
    %mengambil citra dari video
    data = getsnapshot(vid);
    %untuk mendeteksi objek berwarna merah yang bergerak
    %diperlukan pengurangan komponen warna merah
    %mengekstrak komponen warna merah dari citra grayscale
    diff_im = imsubtract(data(:,:,1), rgb2gray(data));
    diff_im2 = imsubtract(data(:,:,3), rgb2gray(data));
    %filterisasi menggunakan filter media untuk menghilangkan noise
    diff_im = medfilt2(diff_im, [3 3]);
    diff_im2 = medfilt2(diff_im2, [3 3]);
    %konversi grayscale ke biner
    diff_im = im2bw(diff_im, 0.18);
    diff_im2 = im2bw(diff_im2, 0.18);
    %menghilangkan semua pixel kurang dari 300px
    diff_im = bwareaopen(diff_im, 300);
    diff_im2 = bwareaopen(diff_im2, 300);
    %memberi label semua komponen yang terkoneksi pada citra
    bw = bwlabel(diff_im, 8);
    bw2 = bwlabel(diff_im2, 8);
    %berikut ini adalah sintak untuk mengkarakterisasi tiap bagian label
    stats = regionprops(bw, 'BoundingBox', 'Centroid');
    stats2 = regionprops(bw2, 'BoundingBox','Centroid');
    
    %menampilkan citra hasil snapshot
    imshow(data)
    
    hold on
    if (mean(mean(diff_im-blackImage))~=0)
    %berikut adalah logika loop untuk membuat box kotak yang mengitari
    %objek warna merah
        for object = 1:length(stats)
            bb = stats(object).BoundingBox;
            bc = stats(object).Centroid;
            rectangle('Position', bb, 'EdgeColor', 'r', 'LineWidth', 2)
            plot(bc(1), bc(2), '-m+')
            a = text(bc(1) + 15, bc(2), strcat('X : ', num2str(round(bc(1))), 'Y : ', num2str(round(bc(2)))));
            set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'Red');
            %logika camera
            g1 = round(round(bc(1)) * (180/620))
            g2 = round(round(bc(2)) * (180/470))
            fprintf(G, 'a%d\n', g1)
            pause(0.2);
            fprintf(G, 'b%d\n', g2)
            pause(0.2);
        end
    else
        fprintf(G, 'a%d\n', 90);
        pause(0.3);
        fprintf(G, 'b%d\n', 90);
        pause(0.3);
    end
    %%%%%%%%%%%%%%%
    if (mean(mean(diff_im2-blackImage))~=0)
        for object = 1:length(stats2)
            bb = stats2(object).BoundingBox;
            bcc = stats2(object).Centroid;
            rectangle('Position', bb, 'EdgeColor', 'g', 'LineWidth', 2)
            plot(bcc(1), bcc(2), '-m+')
            a = text(bcc(1) + 15, bcc(2), strcat('X : ', num2str(round(bcc(1))), 'Y : ', num2str(round(bcc(2)))));
            set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'Green');
            %logika kamera
            g3 = round(round(bcc(2)) * (180/470))
            g4 = round(round(bcc(1)) * (180/620))
            fprintf(G, 'c%d\n', g3)
            pause(0.3);
            fprintf(G, 'd%d\n', g4)
            pause(0.3);
        end
    else
        fprintf(G, 'c%d\n', 90);
        pause(0.3);
        fprintf(G, 'd%d\n', 90);
        pause(0.3);
    end
    hold off
end

stoppreview(vid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in diskoneksi.
function diskoneksi_Callback(hObject, eventdata, handles)
% hObject    handle to diskoneksi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global G
fclose(G);
delete(G);
clear G;
close;


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
