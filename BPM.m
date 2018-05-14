%% LOADING HOMEMADE VIDEO
clc;clear
v = VideoReader('Homemade.MOV');

%% preallocating to improve processing

totalFrames = round(v.FrameRate*v.Duration);

vec_r = zeros(1,round(v.Duration*v.FrameRate));
vec_g = zeros(1,round(v.Duration*v.FrameRate));
vec_b = zeros(1,round(v.Duration*v.FrameRate));
vec_y = zeros(1,round(v.Duration*v.FrameRate));
vec_cb = zeros(1,round(v.Duration*v.FrameRate));
vec_cr = zeros(1,round(v.Duration*v.FrameRate));

p_y = zeros(v.Height,v.Width,totalFrames);
r1 = zeros(v.Height,v.Width,totalFrames);
g1 = zeros(v.Height,v.Width,totalFrames);
b1 = zeros(v.Height,v.Width,totalFrames);
y1 = zeros(v.Height,v.Width,totalFrames);
cb1 = zeros(v.Height,v.Width,totalFrames);
cr1 = zeros(v.Height,v.Width,totalFrames);

%% extracting color components from video
k=1;
while hasFrame(v)
    img1 = readFrame(v);
    ycbcr= rgb2ycbcr(img1);
    %r1(:,:,k)=img1(:,:,1);
    %g1(:,:,k)=img1(:,:,2);
    %b1(:,:,k)=img1(:,:,3);
    y1(:,:,k) = ycbcr(:,:,1);
    cb1(:,:,k) = ycbcr(:,:,2);
    cr1(:,:,k) = ycbcr(:,:,3);   
            
    k = k+1;
end

%% cutting image and extracting pixel average from cutted image

%finding middle point at the video picture
h = (size(p_y(:,:,5),1)/2);
d = (size(p_y(:,:,5),2)/2);
for x = 1:totalFrames
    
   %temp_r =  imcrop(r1(:,:,x),[d h 19 19]);
   %temp_g =  imcrop(g1(:,:,x),[d h 19 19]);
   %temp_b =  imcrop(b1(:,:,x),[d h 19 19]);
   temp_y =  imcrop(y1(:,:,x),[d h 19 19]);
   temp_cb =  imcrop(cb1(:,:,x),[d h 19 19]);
   temp_cr =  imcrop(cr1(:,:,x),[d h 19 19]);
   
   %vec_r(x) = mean(mean(temp_r));
   %vec_g(x) = mean(mean(temp_g));
   %vec_b(x) = mean(mean(temp_b));
   vec_y(x) = mean(mean(temp_y));
   vec_cb(x) = mean(mean(temp_cb));
   vec_cr(x) = mean(mean(temp_cr));
end

%% PLOTTING
figure(1)
%putting in time domain
x = 1:totalFrames;
t = x./30;
%subplot(2,3,1);
%plot(t,vec_r)
%xlabel('TIME');
%ylabel('Amplitude da média');
%title('R');
%subplot(2,3,2);
%plot(t,vec_g)
%xlabel('TIME');
%ylabel('Amplitude da média');
%title('R');
%subplot(2,3,3);
%plot(t,vec_b)
%xlabel('TIME');
%ylabel('Amplitude da média');
%title('B');

%subplot(2,3,4);
%histogram(vec_r)
%title('HISTOGRAMA R');
%subplot(2,3,5);
%histogram(vec_g)
%title('HISTOGRAMA G');
%subplot(2,3,6);
%histogram(vec_b)
%title('HISTOGRAMA B');

subplot(2,3,1);
plot(t,vec_y)
xlabel('TIME');
ylabel('Amplitude da média');
title('Y');
subplot(2,3,2);
plot(t,vec_cb)
xlabel('TIME');
ylabel('Amplitude da média');
title('Cb');
subplot(2,3,3);
plot(t,vec_cr)
xlabel('TIME');
ylabel('Amplitude da média');
title('Cr');

subplot(2,3,4);
histogram(vec_y)
title('HISTOGRAMA Y');
subplot(2,3,5);
histogram(vec_cb)
title('HISTOGRAMA Cb');
subplot(2,3,6);
histogram(vec_cr)
title('HISTOGRAMA Cr');

%% FFT OF THE COMPONENTS
fs=v.FrameRate;


n = 2^nextpow2(totalFrames); 
Y = fft(vec_y,n)/totalFrames;
Y_abs = abs(Y(1:n/2+1));
f = fs/2*linspace(0,1,n/2+1);

figure(2)
plot(f,2*Y_abs)
xlabel('Frequencia (Hz)')
ylabel('MÓDULO')
title('Espectro do Componente Y')



%% COEFFICIENTS FOR THE HOMEMADE
coef=fir1(100,[0.013 0.13],rectwin(100+1));

%% FILTERING
figure(3)
y_out=filter(coef,1,vec_y);
cb_out=filter(coef,1,vec_cb);
cr_out=filter(coef,1,vec_cr);

subplot(1,3,1)
plot(y_out)
title('Y')
ylabel('AMPLITUDE')
xlabel('FRAME')

subplot(1,3,2)
plot(cb_out)
title('Cb')
ylabel('AMPLITUDE')
xlabel('Frame')

subplot(1,3,3)
plot(cr_out)
title('Cr')
ylabel('AMPLITUDE')
xlabel('Frame')

%% COUNTING BEATS

cutting_coef = totalFrames/4;
y_75=y_out(1,cutting_coef:totalFrames);
cb_75=cb_out(1,cutting_coef:totalFrames);
cr_75=cr_out(1,cutting_coef:totalFrames);

p_y=size(findpeaks(y_75,fs,'MinPeakHeight',mean(y_75)),2);
p_cb=size(findpeaks(cb_75,fs,'MinPeakHeight',mean(cb_75)),2);
p_cr=size(findpeaks(cr_75,fs,'MinPeakHeight',mean(cr_75)),2);


y_BPM=p_y*60*fs/(totalFrames-cutting_coef)
cb_BPM=p_cb*60*fs/(totalFrames-cutting_coef) 
cr_BPM=p_cr*60*fs/(totalFrames-cutting_coef)