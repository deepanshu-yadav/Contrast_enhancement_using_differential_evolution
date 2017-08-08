function [ result ] = func_cal(p1,p2,p3,p4,p5,h,n,ma,me)
for i=1:n
    result(i)=evaluate_params(p1(i),p2(i),p3(i),p4(i),p5(i),h,ma,me);
end

end

