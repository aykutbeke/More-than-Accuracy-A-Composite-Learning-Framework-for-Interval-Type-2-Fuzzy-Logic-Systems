function x = PICP(y, y_l, y_u)

i_u = y>y_u;
i_l = y<y_l;

n_u = sum(i_u);
n_l = sum(i_l);
n = length(y);
j=n-(n_u + n_l);
x=100/n*j;