function x = vandermonde(x,order)   
    if order>0
        x(:,order+1)=1;
    else
        order=abs(order);
    end
    x(:,order)=x(:,1); %flipped LR instead of 
    for ii=order-1:-1:1
        x(:,ii)=x(:,order).*x(:,ii+1);
    end
end