function [maxi,mini] = cal_max_min_gamma( amin,amax,bmin,bmax)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
res(1)=-log2(abs((amin^-1)-(2^-bmin)));
res(2)=-log2(abs((amax^-1)-(2^-bmin)));
res(3)=-log2(abs((amin^-1)-(2^-bmax)));
res(4)=-log2(abs((amax^-1)-(2^-bmax)));
maxi=max(res(:));
mini=min(res(:));

end

