function y = myTriMF(x, params)

a = cast(params(1),'like',x);
b = cast(params(2),'like',x);
c = cast(params(3),'like',x);
y = zeros(size(x),'like',x);
eps = 10^-6;
% Left slope
if (a ~= b)
    index = (a < x & x < b);
    y(index) = (x(index)-a)*(1/(b-a+eps));
end

% right slope
if (b ~= c)
    index = (b < x & x < c);
    y(index) = (c-x(index))*(1/(c-b+eps));
end

% Center (y = 1)
y(x == b) = 1;

end