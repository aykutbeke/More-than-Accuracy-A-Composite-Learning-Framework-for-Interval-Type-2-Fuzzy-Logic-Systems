function y = myGaussmf(x, params)
eps = 10^-6;
sigma = cast(params(1),'like',x); 
c = cast(params(2),'like',x);
y = exp(-(x - c).^2/(2*(sigma)^2)+eps);
end