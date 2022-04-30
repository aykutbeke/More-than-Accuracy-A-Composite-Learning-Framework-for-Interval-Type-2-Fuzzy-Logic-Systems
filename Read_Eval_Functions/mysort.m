function [x, index] = mysort(x) 
    len= length(x);
    xt=x;
    for n = 1:len
      minind = n;
      minval = xt(n);
      for i = 1:len     % Start at n+1
        if xt(i) < minval
            minval = xt(i);
            minind = i;   % Remember index
        end
      end
      tmp  = x(n);        % Swap current with minimal element
      xt(minind)=inf;
      index(n) = minind;
      x(n) = minval;
      x(minind) = tmp;
    end
end