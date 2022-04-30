function x = PINAW(y_l, y_u)
n = length(y_l);
r = max(y_u) - min(y_l);
x = sum(y_u-y_l)*1/(n*r);