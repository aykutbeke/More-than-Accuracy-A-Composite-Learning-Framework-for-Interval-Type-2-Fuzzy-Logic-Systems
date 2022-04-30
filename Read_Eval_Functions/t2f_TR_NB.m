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
function [yLeft, yRight] = t2f_TR_NB(fs_u,fs_l,cmfs_u, cmfs_l,nRule,c)
eps = 10^-6;
sfs_u = sum(reshape(fs_u,[nRule c])',2);
sfs_l = sum(reshape(fs_l,[nRule c])',2);
if length(sfs_u) == 1 
    sfss_u = repelem(sfs_u,nRule)';
    sfss_l = repelem(sfs_l,nRule)';
else
    sfss_u = repelem(sfs_u,nRule);
    sfss_l = repelem(sfs_l,nRule);
end
fss_u=fs_u./(sfss_u+eps);
fss_l=fs_l./(sfss_l+eps);
yLeft = (reshape(fss_l,[nRule,c])'*cmfs_l)';
yRight = (reshape(fss_u,[nRule,c])'*cmfs_u)';



