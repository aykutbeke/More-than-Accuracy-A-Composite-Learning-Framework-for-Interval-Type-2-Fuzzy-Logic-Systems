function [x,y] = qcurve(y, y_h)
l = length(y);
r = rand(l,1)*0.0001;
x = min(y):0.01:max(y);
y = interp1(y+r,y_h,x);
