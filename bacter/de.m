
clc;
clear;
close all;

%% Problem Definition

%CostFunction=@(x) Sphere(x);    % Cost Function
RGB=imread('gg.png'); 
HSV=rgb2hsv(RGB);
H=HSV;
V=HSV(:,:,3);
V=im2uint8(V);
[row,col]=size(V);
tot=row*col;
hist=(imhist(V)/tot)';
P=hist;
X=0:1:255;
L=256;

value=sum(X.*P)/(sum(P));
part=round(L-value);
part=part+50;
if (part>=L)
    part=L-1;
end
xmax=double(max(max(V)));
xavg=double(mean(mean(V)));
[u21,Fh_min]=member(xmax,xavg,hist);

nVar=4;            % Number of Decision Variables

VarSize=[1 nVar];   % Decision Variables Matrix Size

VarMin=-[5 0.5 Fh_min 2];          % Lower Bound of Decision Variables
VarMax= [6 1 105 3];          % Upper Bound of Decision Variables

%% DE Parameters

MaxIt=10;      % Maximum Number of Iterations

nPop=50;        % Population Size

beta_min=0.37;   % Lower Bound of Scaling Factor
beta_max=0.98;   % Upper Bound of Scaling Factor

pCR=0.40;        % Crossover Probability

%% Initialization

empty_individual.Position=[];
empty_individual.Cost=[];
BestSol.Cost=inf;

pop=repmat(empty_individual,nPop,1);

for i=1:nPop

    pop(i).Position(1)=unifrnd(5,6,1);
    pop(i).Position(2)=unifrnd(0.5,1,1);
    pop(i).Position(3)=unifrnd(Fh_min,105,1);
    pop(i).Position(4)=unifrnd(2,3,1);
    
    pop(i).Cost=CostFunction(pop(i).Position,hist,xmax,xavg,row,col,part);
    
    if pop(i).Cost<BestSol.Cost
        BestSol=pop(i);
    end
    
end

BestCost=zeros(MaxIt,1);

%% DE Main Loop

for it=1:MaxIt
    
    for i=1:nPop
        
        x=pop(i).Position;
        
        A=randperm(nPop);
        
        A(A==i)=[];
        
        a=A(1);
        b=A(2);
        c=A(3);
        
        % Mutation
        %beta=unifrnd(beta_min,beta_max);
        beta=unifrnd(beta_min,beta_max,VarSize);
        y=pop(a).Position+beta.*(pop(b).Position-pop(c).Position);
        y = max(y, VarMin);
		y = min(y, VarMax);
		
        % Crossover
        z=zeros(size(x));
        j0=randi([1 numel(x)]);
        for j=1:numel(x)
            if j==j0 || rand<=pCR
                z(j)=y(j);
            else
                z(j)=x(j);
            end
        end
        
        NewSol.Position=z;
        NewSol.Cost=CostFunction(NewSol.Position,hist,xmax,xavg,row,col,part);
        
        if NewSol.Cost<pop(i).Cost
            pop(i)=NewSol;
            
            if pop(i).Cost<BestSol.Cost
               BestSol=pop(i);
            end
        end
        
    end
    
    % Update Best Cost
    BestCost(it)=BestSol.Cost;
    
    % Show Iteration Information
    disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
    
end

%% Show Results

figure;
%plot(BestCost);
semilogy(BestCost, 'LineWidth', 2);
xlabel('Iteration');
ylabel('Best Cost');
grid on;

%%

a=177;
params=BestSol.Position;
%params=[7.0000	0.6000	79.7629	2.3188]
Uc=params(2);
t=params(1);
L=256;
g=params(4);
e=.01;
f=100;
f1=100;
x=1:1:256;
RGB=imread('bird.jpg'); % Give the correct pathof the required image
% RGB=imread('flower2.jpg');
HSV=rgb2hsv(RGB);
H=HSV;
V=HSV(:,:,3);
X=0:1:255;
V=im2uint8(V);
P=imhist(V);
P=P';
value=sum(X.*P)/(sum(P));
a=round(L-value);
a=a+50
if (a>=L)
    a=L-1;
end
% a=180;
% Uc=((a)/2)/L;
xmax=double(max(max(V)));
xavg=double(mean(mean(V)));
for i=1:1:256;
    if i<a;
        UX(i)=0;
    else
        UX(i)=(i-a)/(L-a);
    end
end
UXx=.95.*(UX+.0001).^(g);
for i=1:1:256;
    if (UXx(i)>0);
        xx(i)=a+UXx(i).*(L-a);
    else
        xx(i)=i;
    end
end
[UX1,Fh]=member(xmax,xavg,P);
Fh=params(3);
Fh=Fh_min;
UXx1=1./(1+exp(-t.*(UX1-Uc)));
xx1=xavg-xmax+sqrt(-2.*log(UXx1).*(Fh^2));
xx1=xx1-min(xx1);
xx=(xx./max(xx));
xx1=(xx1./max(xx1));
while ((xx1(a)-xx(a))>e)
    f=f-2;
    f1=f1+.1;
    xx1=(f.*xx1)./100;
    xx=(f1.*xx)./100;
end  
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
s=HSV(:,:,2);
ss=power(s,2/3);
Vv=Vv./(f1/100);
HSV(:,:,3)=Vv;
I=hsv2rgb(HSV);
% HSV(:,:,2)=ss;
I1=hsv2rgb(HSV);
 figure,
 imhist(Vv)
 imshow(I1);
 title('modified with proposed technique');
 V=mat2gray(double(V));
 figure,imshow(imread('bird.jpg'));
 title('original');