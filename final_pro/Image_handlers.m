function res123 = Image_handlers(arg)
RGB=imread(arg); 
HSV=rgb2hsv(RGB);
H=HSV;
V=HSV(:,:,3);
V=im2uint8(V);
[row,col]=size(V);
tot=row*col;
hist=(imhist(V)/tot)';
xmax=double(max(max(V)));
xavg=double(mean(mean(V)));
[u21,Fh_min]=member(xmax,xavg,hist);

nVar=5;            % Number of Decision Variables

VarSize=[1 nVar];   % Decision Variables Matrix Size

VarMin=[0.79 0.81 0 0.5 Fh_min];          % Lower Bound of Decision Variables
VarMax=[0.99 1.06 0 1.5 Fh_min+30]; 
[ma,mi]=cal_max_min_gamma(VarMin(1),VarMax(1),VarMin(2),VarMax(2));
VarMin(3)=mi;
VarMax(3)=ma;
% Upper Bound of Decision Variables

%% DE Parameters

MaxIt=10;      % Maximum Number of Iterations

nPop=100;        % Population Size

beta_min=0.37;   % Lower Bound of Scaling Factor
beta_max=0.98;   % Upper Bound of Scaling Factor

pCR=0.2;        % Crossover Probability

%% Initialization

empty_individual.Position=[];
empty_individual.Cost=[];
BestSol.Cost=inf;

pop=repmat(empty_individual,nPop,1);

for i=1:nPop

    pop(i).Position(1)=unifrnd(VarMin(1),VarMax(1),1);
    pop(i).Position(2)=unifrnd(VarMin(2),VarMax(2),1);
    pop(i).Position(3)=-log2(abs((pop(i).Position(1)^-1)-(2^-pop(i).Position(2))));
    pop(i).Position(4)=unifrnd(VarMin(4),VarMax(4),1);
    pop(i).Position(5)=unifrnd(VarMin(5),VarMax(5),1);
    pop(i).Cost=CostFunction(pop(i).Position,hist,xmax);
    
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
        NewSol.Cost=CostFunction(NewSol.Position,hist,xmax);
        
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

%{
figure;
%plot(BestCost);
semilogy(BestCost, 'LineWidth', 2);
xlabel('Iteration');
ylabel('Best Cost');
grid on;
%}



datas=BestSol.Position;
alpha=datas(1);
beta=datas(2);
gamma=datas(3);
delta=datas(4);
fh=datas(5);
L=256;
x=1:1:256;
%RGB=imread('gg.png'); 
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
 %V=mat2gray(double(V));
 figure,imshow(RGB);
 title('original');

end