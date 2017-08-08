function [ result ] = evaluate_params( alpha,beta,gamma,delta,fh,hist,ma,me )

e=.01;
f=100;
f1=100;
L=256;
X=0:1:255;
P=hist;
value=(sum(X.*P)/(sum(P)))*1/L;
a=L*(1-value);
a=double(a);
xmax=ma;
xavg=me;
for i=1:1:256;
    if i<a;
        UX0(i)=0;
    else
        UX0(i)=(i-a)/(L-a);
    end
end

nUX0=max(UX0(:)).*(UX0/max(UX0(:))).^delta;
for i=1:1:256;
    if (nUX0(i)>0);
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
val=2.*log(UXx1).*(fh^2);
xx1=xmax-sqrt(abs(val));
for k=1:1:L
    if (k<=a);
        new(k)=xx1(k);
    else
        new(k)=xx(k);
    end
end 
L=256;
lamda=1.5;
g=1/L;
s1=(P-new).^2;
s2=(new-g).^2;
result=sum(s1(:))+lamda*sum(s2(:));

end

