function x = mae(y, y_h)
x=mean(abs(y-y_h));
x=round(x,4);