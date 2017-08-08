clc;
clear all;
close all;
%params=[0.7	5.6000	79.7629	2.3188 10.6677];

RGB=imread('img1.png'); 
HSV=rgb2hsv(RGB);
H=HSV;
V=HSV(:,:,3);
V=im2uint8(V);
[row,col]=size(V);
tot=row*col;
hist=(imhist(V)/tot)';
xmax=double(max(max(V)));
xavg=double(mean(mean(V)));
[u21,Fh]=member(xmax,xavg,hist);
%%
%Function to be minimized
D=5;
%Initialization of DE parameters
N=20; %population size (total function evaluations will be itmax*N, must be>=5)
itmax=30;
F=0.8; CR=0.5; %mutation and crossover ratio
%Problem bounds
a1(1:N,1)=0.1; a2(1:N,1)=1; %bounds on variable alpha
a1(1:N,2)=0; a2(1:N,2)=10; %bounds on variable beta
a1(1:N,3)=-3.169; a2(1:N,3)=-0.9990; %bounds on variable gamma
a1(1:N,4)=0; a2(1:N,4)=5; %bounds on variable delta
a1(1:N,5)=Fh; a2(1:N,5)=150; %bounds on variable fh


d=(a2-a1);
basemat=repmat(int16(linspace(1,N,N)),N,1); %used later
basej=repmat(int16(linspace(1,D,D)),N,1); %used later
%Random initialization of positions
x=a1+d.*rand(N,D);
x(:,3)=-log2((x(:,1).^-1)-(2.^-x(:,2)));
%Evaluate objective for all particles
fx=func_cal(x(:,1),x(:,2),x(:,3),x(:,4),x(:,5),hist,N,xmax,xavg);
%Find best
[fxbest,ixbest]=min(fx);
xbest=x(ixbest,1:D);
%%
%Iterate
for it=1:itmax;
	permat=bsxfun(@(x,y) x(randperm(y(1))),basemat',N(ones(N,1)))';
	%Generate donors by mutation
	v(1:N,1:D)=repmat(xbest,N,1)+F*(x(permat(1:N,1),1:D)-x(permat(1:N,2),1:D));
	%Perform recombination
	r=repmat(randi([1 D],N,1),1,D);
	muv = ((rand(N,D)<CR) + (basej==r)) ~= 0;
	mux = 1-muv;
	u(1:N,1:D)=x(1:N,1:D).*mux(1:N,1:D)+v(1:N,1:D).*muv(1:N,1:D);
	%Greedy selection
	fu=func_cal(u(:,1),u(:,2),u(:,3),u(:,4),u(:,5),hist,N,xmax,xavg);
	idx=fu<fx;
	fx(idx)=fu(idx);
	x(idx,1:D)=u(idx,1:D);
	%Find best
	[fxbest,ixbest]=min(fx);
	xbest=x(ixbest,1:D);
end %end loop on iterations
%[xbest,fxbest]

%%

params=xbest;
%params=[0.530994070872880,5.64997052899017,-1.15499624454059,7.0290789552059,74.9075982358463];
alpha=params(1);
beta=params(2);
gamma=params(3);
delta=params(4);
fh=params(5);
L=256;
x=1:1:256;
RGB=imread('img1.png'); 
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

nUX0=max(UX0(:)).*(UX0/max(UX0(:))).^delta;
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
xx1=xmax-sqrt(abs(val2));

for k=1:1:L
    if (k<=a);
        new(k)=xx1(k);
    else
        new(k)=xx(k);
    end
end    


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
HSV(:,:,3)=Vv;
I=hsv2rgb(HSV);
% HSV(:,:,2)=ss;
I1=hsv2rgb(HSV);
 figure,
 %imhist(Vv)
 imshow(I1);
 title('modified with proposed technique');
 V=mat2gray(double(V));
 figure,imshow(imread('img.png'));
 title('original');
