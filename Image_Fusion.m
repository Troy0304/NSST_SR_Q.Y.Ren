function varargout = Image_Fusion(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Image_Fusion_OpeningFcn, ...
                   'gui_OutputFcn',  @Image_Fusion_OutputFcn, ...
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


% --- Executes just before Image_Fusion is made visible.
function Image_Fusion_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

function varargout = Image_Fusion_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function pushbutton1_Callback(hObject, eventdata, handles)
[filename1,PathName1] = uigetfile('source_images\*.jpg;*.bmp;*.png;*.tif;*.tiff;*.pgm;*.gif','Please choose the first input image');
X1 = [PathName1 filename1];
global OrginImage1;
if PathName1 ~=0
    OriginImage1 = imread(X1);
    handles.OrginImage1=OriginImage1;
    guidata(hObject,handles);
    axes(handles.axes1);
    imshow(OriginImage1);
end

function pushbutton2_Callback(hObject, eventdata, handles)
[filename2,PathName2] = uigetfile('source_images\*.jpg;*.bmp;*.png;*.tif;*.tiff;*.pgm;*.gif','Please choose the first input image');
X2 = [PathName2 filename2];

if PathName2 ~=0
    OriginImage2 = imread(X2);
    handles.OrginImage2=OriginImage2;
    guidata(hObject,handles);
    axes(handles.axes2);
    imshow(OriginImage2);
end


function popupmenu4_Callback(hObject, eventdata, handles)
global result
val=get(handles.popupmenu4,'Value');
switch val
    case 1
        result=1;
    case 2
        result=2;
    case 3
        result=3;
end
disp(result);

function edit18_Callback(hObject, eventdata, handles)



function pushbutton3_Callback(hObject, eventdata, handles)
% 
% 
%图像融合

addpath(genpath('nsst_toolbox'));
addpath(genpath('sparsefusion'));
%load('sparsefusion/Dictionary/D_512.mat');
load('sparsefusion/Dictionary/D_100000_256_8.mat');
Imr=handles.OrginImage1;
Ipe=handles.OrginImage2;
Image1=double(Imr)/255;
Image2=double(Ipe)/255;

% size(Image1)
% size(Image2)
global result
result
if result == 1 
    Imr=handles.OrginImage1;
    Ipe=handles.OrginImage2;
    Image1=double(Imr)/255;
    Image2=double(Ipe)/255;
    I1 = im2double(Imr);
    I1 = rgb2gray(I1);
    IpeRGB = im2double(Ipe);
    I3 = rgb2hsv(IpeRGB);
    I2 = I3(:,:,3);
    [m,n] = size(I1);
    l = max(m,n);
    J1 = zeros(l,l);
    J2 = zeros(l,l);
    J1(1:m,1:n) = I1;
    J2(1:m,1:n) = I2;
    %% Parameters for NSST
    lpfilt = 'maxflat';
    shear_parameters.dcomp =[ 4  4  3  3];
    shear_parameters.dsize =[32 32 16 16];
    %% NSST分解
    [dst1,shear_f1]=nsst_dec2(J1,shear_parameters,lpfilt);
    [dst2,shear_f2]=nsst_dec2(J2,shear_parameters,lpfilt);
    %% 设置可见光边缘融合比例(0-1)

    c_total=str2double(get(handles.edit18,'String'));
    if isempty(c_total)
        c_total=0.4;
    end
    % Lowpass subband
    X1_1= dst1{1};
    X1_2 =dst2{1};
    overlap = 6;
    epsilon=0.1;
    X1=sparse_fusion_0313(X1_1,X1_2,D,overlap,epsilon);
    dst{1} = X1;

    % Bandpass subbands
    for i = 1:16
        X2_1{i} = dst1{2}(:,:,i);
        X2_2{i} = dst2{2}(:,:,i);
    end

    for i = 1:16
        X2(:,:,i) = nsst_fuse(X2_1{i},X2_2{i},c_total,X1_1,X1_2);
    end

    for i = 1:16
        X3_1{i} = dst1{3}(:,:,i);
        X3_2{i} = dst2{3}(:,:,i);
    end

    for i = 1:16
        X3(:,:,i) = nsst_fuse(X3_1{i},X3_2{i},c_total,X1_1,X1_2);
    end

    for i = 1:8
        X4_1{i} = dst1{4}(:,:,i);
        X4_2{i} = dst2{4}(:,:,i);
    end

    for i = 1:8
        X4(:,:,i) = nsst_fuse(X4_1{i},X4_2{i},c_total,X1_1,X1_2);
    end

    for i = 1:8
        X5_1{i} = dst1{5}(:,:,i);
        X5_2{i} = dst2{5}(:,:,i);
    end

    for i = 1:8
        X5(:,:,i) = nsst_fuse(X5_1{i},X5_2{i},c_total,X1_1,X1_2);
    end

    dst{2} = X2;
    dst{3} = X3;
    dst{4} = X4;
    dst{5} = X5;

    %% Reconstruction
    Ir=nsst_rec2(dst,shear_f1,lpfilt);
    Fi = Ir(1:m,1:n);
    I3(:,:,3)=Fi;
    FF = hsv2rgb(I3);
%     handles.X=FF;
%     guidata(hObject,handles);
    axes(handles.axes3);

        
    imshow(uint8(FF*255));

    title('NSST-SR');
end



if result == 2
    %设置可见光边缘融合比例
    c_total=str2double(get(handles.edit18,'String'));
    Imr=handles.OrginImage1;
    Ipe=handles.OrginImage2;
    Image1=double(Imr)/255;
    Image2=double(Ipe)/255;
    I1 = im2double(Imr);
    I1 = rgb2gray(I1);
    IpeRGB = im2double(Ipe);
    I3 = rgb2hsv(IpeRGB);
    I2 = I3(:,:,3);
    [m,n] = size(I1);
    l = max(m,n);
    J1 = zeros(l,l);
    J2 = zeros(l,l);
    J1(1:m,1:n) = I1;
    J2(1:m,1:n) = I2;

    %% Parameters for NSST
    lpfilt = 'maxflat';
    shear_parameters.dcomp =[ 4  4  3  3];
    shear_parameters.dsize =[32 32 16 16];

    %% NSST分解
    [dst1,shear_f1]=nsst_dec2(J1,shear_parameters,lpfilt);
    [dst2,shear_f2]=nsst_dec2(J2,shear_parameters,lpfilt);

    % Lowpass subband

    X1_1= dst1{1};
    X1_2 =dst2{1};

    % EA strategy
    mB1 = mean(X1_1(:));
    mB2 = mean(X1_2(:));
    MB1 = median(X1_1(:));
    MB2 = median(X1_2(:));
    G1 = (mB1+MB1)/2;
    G2 = (mB2+MB2)/2;

    w1 = zeros(m,n);
    w2 = zeros(m,n);
    a = 4;
    t = 3;
    for i = 1:m
        for j = 1:n
            w1(i,j) = exp(a*abs(X1_1(i,j)-G1));
            w2(i,j) = exp(a*abs(X1_2(i,j)-G2));
            WB1(i,j) = w1(i,j)/(w1(i,j)+w2(i,j));
            WB2(i,j) = w2(i,j)/(w1(i,j)+w2(i,j));
        end
    end

    X1 = zeros(l,l);
    for i = 1:m
        for j = 1:n
            X1(i,j) = WB1(i,j)*X1_1(i,j)+WB2(i,j)*X1_2(i,j);
        end
    end

    dst{1} = X1;

    % Bandpass subbands

    for i = 1:16
        X2_1{i} = dst1{2}(:,:,i);
        X2_2{i} = dst2{2}(:,:,i);
    end

    for i = 1:16
        X2(:,:,i) = nsst_fuse(X2_1{i},X2_2{i},c_total,X1_1,X1_2);
    end

    for i = 1:16
        X3_1{i} = dst1{3}(:,:,i);
        X3_2{i} = dst2{3}(:,:,i);
    end

    for i = 1:16
        X3(:,:,i) = nsst_fuse(X3_1{i},X3_2{i},c_total,X1_1,X1_2);
    end

    for i = 1:8
        X4_1{i} = dst1{4}(:,:,i);
        X4_2{i} = dst2{4}(:,:,i);
    end

    for i = 1:8
        X4(:,:,i) = nsst_fuse(X4_1{i},X4_2{i},c_total,X1_1,X1_2);
    end

    for i = 1:8
        X5_1{i} = dst1{5}(:,:,i);
        X5_2{i} = dst2{5}(:,:,i);
    end

    for i = 1:8
        X5(:,:,i) = nsst_fuse(X5_1{i},X5_2{i},c_total,X1_1,X1_2);
    end

    dst{2} = X2;
    dst{3} = X3;
    dst{4} = X4;
    dst{5} = X5;

    % Reconstruction
    Ir=nsst_rec2(dst,shear_f1,lpfilt);

    Fi = Ir(1:m,1:n);
    I3(:,:,3)=Fi;
    FF = hsv2rgb(I3);
    handles.X=FF;
    guidata(hObject,handles);
    axes(handles.axes3);
    if max(FF(:))<=2
        
         imshow(uint8(FF*255));

    else
          imshow((FF),[]);

    end
    title('NSST');
end

if result == 3   
    Imr=handles.OrginImage1;
    Ipe=handles.OrginImage2;
    Image1=double(Imr)/255;
    Image2=double(Ipe)/255;
    img1=Image1;
    img2=Image2;
    I1 = im2double(Imr);
    I1 = rgb2gray(I1);
    IpeRGB = im2double(Ipe);
    I3 = rgb2hsv(IpeRGB);
    I2 = I3(:,:,3);
    [m,n] = size(I1);
    l = max(m,n);
    J1 = zeros(l,l);
    J2 = zeros(l,l);
    J1(1:m,1:n) = I1;
    J2(1:m,1:n) = I2;

    overlap = 6;
    epsilon=0.1;

    if size(img1,3)==1   %for gray images
        imgf=sparse_fusion_0313(img1,img2,D,overlap,epsilon);
    else                 %for color images
        imgf=zeros(size(img1));
        for i=1:3
            imgf(:,:,i)=sparse_fusion_0313(img1(:,:,i),img2(:,:,i),D,overlap,epsilon);
        end
    end
    Fi = imgf(1:m,1:n);
    I3(:,:,3)=Fi;
    FF = hsv2rgb(I3);
    handles.X=FF;
    guidata(hObject,handles);
    axes(handles.axes3);
    if max(FF(:))<=2
        
         imshow(uint8(FF*255));

    else
          imshow((FF),[]);

    end
    title('SR');
end


if 1
%评价指标
imwrite(FF,'FF.png');
ff_ori=imread('FF.png');
ff=double(ff_ori); %对融合图像预处理
ff_normal=ff/256;
[R,C]=size(ff);

%相对标准差
s=size(size(Image1));
if s(2)==3 %判断是灰度图像还是RGB彩色图像
f1=rgb2gray(Image1);
f2=rgb2gray(Image2);
f3=rgb2gray(ff_normal);
else
    f1=Image1;
    f2=Image2;
end 
c1=0;
c2=0;
u1=(sum(f1(:)))/(m*n);
u2=(sum(f2(:)))/(m*n);
[m,n]=size(f1);
for i =1:m
    for j =1:n
        w1=f3(i,j)-u1;
        w2=f3(i,j)-u2;
        c1=c1+w1^2;
        c2=c2+w2^2;
    end
end
sd1=sqrt(c1/((m-1)*(n-1)));
sd2=sqrt(c2/((m-1)*(n-1)));
RSD1=sd1/u1;
RSD2=sd2/u2;
f=(RSD1+RSD2)/2;
set(handles.edit1,'String',num2str(f));


%峰值信噪比
MAX=255; %图像灰度级最大值
D1=Image1-ff_normal;
D2=Image2-ff_normal;
MES1=sum(D1(:).*D1(:))./prod(size(Image1));
MES2=sum(D2(:).*D2(:))./prod(size(Image2));
PSNR1=10*log10(MAX^2/MES1);
PSNR2=10*log10(MAX^2/MES2);
PS=(PSNR1+PSNR2)/2;
set(handles.edit2,'String',num2str(PS));


%空间频率
SF=space_frequency(ff);
set(handles.edit3,'String',num2str(SF));


%图像清晰度
n=R*C;
m=1;
for i=1:(R-1)
    for j=1:(C-1)
        x=ff(i,j)-ff(i,j+1);
        y=ff(i,j)-ff(i+1,j);
        z(m,1)=sqrt((x.^2+y.^2)/2);
        m=m+1;
    end
end
G=sum(z)/n;  
set(handles.edit4,'String',num2str(G));


%互信息
MI=MI_calculate(ff_ori,Imr,Ipe);
set(handles.edit5,'String',num2str(MI));


%交叉熵
f=CE_calculate(ff_ori,Imr,Ipe);
set(handles.edit6,'String',num2str(f));
end

function edit1_Callback(hObject, eventdata, handles)

function edit1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)

function edit2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)

function edit3_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)

function edit4_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)

function edit5_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit6_Callback(hObject, eventdata, handles)

function edit6_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit18_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function popupmenu4_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
