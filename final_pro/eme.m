% Call: eme(A,M,L)
% The 1st measure, EME, of enhancement calculation
% of the image X of size MxM by using blocks of size LxL
%
function E=eme(X,L)

%	L=5; 
[r,c]=size(X);
	k1=floor(r/L);
	k2=floor(c/L);
	E=0.; 
	%B1=zeros(L);
	m1=1;
	for m=1:k1
	    n1=1;
	    for n=1:k2
	    	B1=X(m1:m1+L-1,n1:n1+L-1);
            b_min=min(min(B1));
            b_max=max(max(B1));

            if b_min>0 
                b_ratio=b_max/b_min;
                E=E+20.*log(b_ratio);	  
            end;

            n1=n1+L;	              
	    end;
	    m1=m1+L;
	end;
	E=(E/k1)/k2;
