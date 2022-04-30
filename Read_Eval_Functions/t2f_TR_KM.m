%  IT2-FLS Toolbox is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     IT2-FLS Toolbox is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with IT2-FLS Toolbox.  If not, see <http://www.gnu.org/licenses/>.
function [yLeft,yRight]=t2f_TR_KM(fs_u,fs_l,cmfs_u, cmfs_l,nRule,c)
%% KM Algorithm for Computing Y Left
eps = 0.01;
% a) Sort lower matrix
[~, indl] = mysort(cmfs_l);
[~, indr] = mysort(cmfs_u);
%
cmfs_l_l = cmfs_l(indl,:);
fs_l = reshape(fs_l,[nRule,c]);
sortedf_ls = fs_l(indl,:);
sortedf_l = reshape(sortedf_ls,1,[])';
%
cmfs_u_l = cmfs_u(indl,:);
fs_u = reshape(fs_u,[nRule,c]);
sortedf_us = fs_u(indl,:);
sortedf_u = reshape(sortedf_us,1,[])';
% b) Initialize fn by setting and computing
fs_o = (sortedf_u+sortedf_l)./2;
sfs_o = sum(reshape(fs_o,[nRule c])',2);
if length(sfs_o) == 1 
    sfss_o = repelem(sfs_o,nRule)';
else
    sfss_o = repelem(sfs_o,nRule);
end
fss_o=fs_o./(sfss_o+10^-6);
yns = (reshape(fss_o,[nRule,c])'*cmfs_l_l)';
yLeft = [];
sPointLeft = 1;
for k=1:length(yns)
yn = yns(k);   
counter=1;
    while(1)
     fn=[];
    % c) Find switch point k (1 <= k <= N ? 1) such that yk <= y <= yk+1
        for i=1:nRule-1;
            if yn>=cmfs_l_l(i) && yn<=cmfs_l_l(i+1)
                sPointLeft = i;
                break
            end
        end
        % d) Compute
        for i=1:nRule
            if i<=sPointLeft
                fn = [fn; sortedf_us(i,k)];
            elseif i>sPointLeft
                fn = [fn; sortedf_ls(i,k)];
            end

        end

        sfs_n = sum(reshape(fn,[nRule 1])',2);
        if length(sfs_n) == 1 
            sfss_n = repelem(sfs_n,nRule)';
        else
            sfss_n = repelem(sfs_n,nRule);
        end
        fss_n=fn./(sfss_n+10^-6);
        ynPrime = (reshape(fss_n,[nRule,1])'*cmfs_l_l)';

        % e) if yn==ynPrime stop else go to c)
        if(abs(yn-ynPrime)<eps)
            yL = yn;
%             sPointLeft;
            break;
        else
            yn=ynPrime;
        end
        if counter==6
            fss_n=fss_o./(sfss_n+10^-6);
            ynPrime = (reshape(fss_n,[nRule,1])'*cmfs_l_l)';
            yL=ynPrime;
            break;
        end
       counter=counter+1;
    end
    yLeft = [yLeft yL];
    counter=counter+1;
end


%% KM Algorithm for Computing Y Right
% a) Sort Y matrix
eps=0.01;
cmfs_l_r = cmfs_l(indr,:);
fs_l = reshape(fs_l,[nRule,c]);
sortedf_ls = fs_l(indr,:);
sortedf_l = reshape(sortedf_ls,1,[])';
%
cmfs_u_r = cmfs_u(indr,:);
fs_u = reshape(fs_u,[nRule,c]);
sortedf_us = fs_u(indr,:);
sortedf_u = reshape(sortedf_us,1,[])';
% b) Initialize fn by setting and computing
fs_o = (sortedf_u+sortedf_l)./2;
sfs_o = sum(reshape(fs_o,[nRule c])',2);
if length(sfs_o) == 1 
    sfss_o = repelem(sfs_o,nRule)';
else
    sfss_o = repelem(sfs_o,nRule);
end
fss_o=fs_o./(sfss_o+10^-6);
yns = (reshape(fss_o,[nRule,c])'*cmfs_u_r)';
yRight = [];
for k=1:length(yns)
yn = yns(k);
counter=1;
    while(1)
        fn=[];
        % c) Find switch point k (1 <= k <= N ? 1) such that yk <= y <= yk+1
        sPointRight = 0;
        for i=1:nRule-1;
            if yn>=cmfs_u_r(i) && yn<=cmfs_u_r(i+1)
                sPointRight = i;
                break
            end
        end
        % d) Compute
        for i=1:nRule
            if i<=sPointRight
                fn = [fn; sortedf_ls(i,k)];
            elseif i>sPointRight
                fn = [fn; sortedf_us(i,k)];
            end

        end

        sfs_n = sum(reshape(fn,[nRule 1])',2);
        if length(sfs_n) == 1 
            sfss_n = repelem(sfs_n,nRule)';
        else
            sfss_n = repelem(sfs_n,nRule);
        end
        fss_n=fn./(sfss_n+10^-6);
        ynPrime = (reshape(fss_n,[nRule,1])'*cmfs_u_r)';

        % e) if yn==ynPrime stop else go to c)
      
       if(abs(yn-ynPrime)<eps)
            yR = yn;
%             R = sPointRight;
            break;
        else
            yn=ynPrime;
       end 
       if counter==6
            fss_n=fss_o./(sfss_n+10^-6);
            ynPrime = (reshape(fss_n,[nRule,1])'*cmfs_u_r)';
            yR=ynPrime;
            break;
       end
        counter=counter+1;
    end
    yRight = [yRight yR];
end
