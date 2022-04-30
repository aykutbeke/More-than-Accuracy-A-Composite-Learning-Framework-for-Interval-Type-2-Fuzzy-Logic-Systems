function x = randl(m, n)
% function: x  = randl(m, n)
% m - number of matrix rows
% n - number of matrix columns
% x - matrix with Laplacian distributed random numbers 
%     with mean mu = 0 and std sigma = 1 (columnwise)
% generation of two i.i.d. sequences
u1 = rand(m, n);
u2 = rand(m, n);
% generation of a matrix with Laplacian
% distributed random numbers (columwise)
x = log(u1./u2);
x = bsxfun(@minus, x, mean(x));
x = bsxfun(@rdivide, x, std(x));
end