function x = nmse(y, y_h)
x = sum((y-y_h).^2)/sum((y-mean(y)).^2);
x=round(x,4);