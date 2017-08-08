clear;
clc;
close all;
params = inputdlg({'alpha','beta','delta','Fh'},...
              'Parameters', [1 7; 1 7;1 7;1 7]); 
alpha=str2double(params{1});
beta=str2double(params{2});
gamma=-log2((alpha^-1)-(2^-beta));
delta=str2double(params{3});
fh=str2double(params{4});
L=256;
x=1:1:256;
RGB=imread('gg.png'); 
HSV=rgb2hsv(RGB);
H=HSV;
V=HSV(:,:,3);
X=0:1:255;
V=im2uint8(V);
[row,col]=size(V);
tot=row*col;
P=imhist(V)/tot;
P=P';
value=(sum(X.*P)/(sum(P)))*1/L;
a=L*(1-value);
a=double(a);
xmax=double(max(max(V)));
xavg=double(mean(mean(V)));
for i=1:1:256;
    if i<a;
        UX0(i)=0;
    else
        UX0(i)=(i-a)/(L-a);
    end
end

nUX0=max(UX0(:))*((UX0/max(UX0(:))).^delta);
for i=1:1:256;
    if (nUX0(i)~=0)
        xx(i)=a+nUX0(i).*(L-a);
    else
        xx(i)=0;
    end
end

for x=1:1:256
    UX1(x)=exp(-(xmax-x)^2/(2*fh^2));
end

for i=1:1:256
    if UX1(i)<0.5
        UXx1(i)=alpha*(UX1(i)^beta);
    else
        UXx1(i)=1-alpha*((1-UX1(i))^gamma);
    end
end
val2=2*log(UXx1)*(fh^2);
xx1=abs(xmax-sqrt(abs(val2)));

for k=1:1:L
    if (k<=a);
        new(k)=xx1(k);
    else
        new(k)=xx(k);
    end
end    
new=new/255;
[m,n]=size(V);
for i=1:1:m;
    for j=1:1:n;
        k=V(i,j);
        Vv(i,j)=new(k+1);
    end
end

%{
s=HSV(:,:,2);
ss=power(s,2/3);
Vv=Vv./(f1/100);
%}
%Vv=double(Vv)/255;

HSV(:,:,3)=Vv;
% HSV(:,:,2)=ss;
I1=hsv2rgb(HSV);
 figure,
 %imhist(Vv)
 imshow(I1);
 title('modified with proposed technique');
 V=mat2gray(double(V));
 figure,imshow(RGB);
 title('original');