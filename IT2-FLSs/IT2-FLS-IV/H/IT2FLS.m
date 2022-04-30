classdef IT2FLS < nnet.layer.Layer
    
    properties (Learnable)
        parameterList
    end
    properties 
        t2fis
        mask
        consequents
    end
    methods
        function layer = IT2FLS(num_channels,name,data,fis)
            layer.Type = 'Single Input Interval Type2 Fuzzy Rectifying Unit';
            if nargin <= 3
                layer.t2fis=layer.getT1Fis(nargin,'');
            else
                layer.t2fis=layer.getT1Fis(nargin,fis);
            end
                nc = layer.t2fis.rule(end).antecedent;
                [~,centers] = kmeans(data,nc(1));
                c = centers(:,1:end-1);
                s = std(data(:,1:end-1));
                s = repelem(s,nc(1))';
            if nargin > 1
                layer.Name = name;
            end
            [layer] = initilizeLearnableMFParams(layer,c,s);
            layer.consequents = [];
            % Layer description.
            layer.Description = "Single Input Interval Type2 Fuzzy Unit with " + ...
                num_channels + " channels";
           
        end
        
        function Z = predict(layer,Xi)
            % Forward input data through the layer at prediction time and
            % output the result
            %
            % Inputs:
            %         layer    -    Layer to forward propagate through
            %         X        -    Input data
            % Output:
            %         Z        -    Output of layer forward function
            eps=10^-6;
            rules = cat(1,layer.t2fis.rule.antecedent);
            TRMethod = layer.getTRmethod(); 
            nRule= size(rules,1);
            input = Xi;
            [r,c]=size(input);
            
            mfs=[];
            cmfs=[];
            layer = updateLearnableMFParams(layer,1);
            nout = size(layer.t2fis.output,2);
            for i=1:r
                mfType = cat(1,layer.t2fis.input(i).mf.type);
                mfParams = cat(1,layer.t2fis.input(i).mf.params);
                heightofMF = mfParams(:,end);
                antecedentMFParams = mfParams(:,1:end-1);
                mf = heightofMF.*helper.evalMfTypeHelper2(mfType,input(i,:),antecedentMFParams);
                mf=reshape(mf,1,[])';
                mfs=[mfs mf];
%                
            end
            fs = prod(mfs,2);
            fs_u = fs(1:2:end,:); 
            fs_l = fs(2:2:end,:); 
            for i=1:nout
                cmf = cat(1,layer.t2fis.output(i).mf.params);
                cmfs = [cmfs cmf];
            end
            cmfs_l=cmfs(:,1);cmfs_u=cmfs(:,2);
            [z_l, z_u] = feval(TRMethod,fs_u,fs_l,cmfs_u,cmfs_l,nRule,c);
            Z = [(z_u+z_l)./2;z_l;z_u];         

        end
        
        function t2fis = getT1Fis(layer, n, t2fis)
             if n<=3
                t2fispath=cellstr(ls('*.fis'));
                if isempty(t2fispath)
                    t2fispath='*.fis';
                else
                    t2fispath=t2fispath{end,1};
                end
                [path,~]=fileparts(which(t2fispath));
                t2fis=readdeepfis(t2fispath,path);
                %     warning('function needs 2 input')
                %     return
            end
            if n > 3
                if ~isempty(which([t2fis '.fis']))
                    [path,~]=fileparts(which([t2fis '.fis']));
                    t2fis=readdeepfis([t2fis '.fis'],path);
                end
            end
        end
        
         function  [layer] = getConsequents(layer, cmfs)
                    layer.consequents = cmfs;
         end

 
        function [layer] = initilizeLearnableMFParams(layer, c, s)
        layer.mask={};
        memberList={};
        indexlist={};
%         t2fis=layer.t2fis;
        for i=1:length(layer.t2fis.learnableParameters)
            lp = layer.t2fis.learnableParameters{i}; 
            mf = lp{1};
            if mf == 'Z'
                member = string(c(1));
                c=c(2:end);
%                 c = c(c~=c(1));
            elseif mf == 'Sigma'
                member = string(s(1));
                s=s(2:end);
%                 s = s(s~=s(1));
            else
                member = initializeMemberShips(layer,i);
            end
            if iscell(lp{end})
                memberList{end+1} = {str2double(member) str2double(member)};
            else
                memberList{end+1} = str2double(member);
            end
            
            
%  [{pattern(i)},{num2str(varIndex)},{num2str(MFIndex)},{'o'},{MFName}]
            if lp{end-1} == 'o'
                if iscell(lp{end})
                    varIndex1 = lp{2}{1};
                    MFIndex1 = lp{3}{1};
                    varIndex2 = lp{2}{2};
                    MFIndex2 = lp{3}{2};
                    MFParams1 = layer.t2fis.output(str2double(varIndex1)).mf(str2double(MFIndex1)).params;
                    MFParams2 = layer.t2fis.output(str2double(varIndex2)).mf(str2double(MFIndex2)).params;
                    indexlist{end+1} = {append('0.00',string(i)),append('0.00',string(i*11))};
%                     indexlist{end+1} = ;
                    MFParams1=strrep(MFParams1,lp{1},append('0.00',string(i)));
                    MFParams2=strrep(MFParams2,lp{1},append('0.00',string(i*11)));
                    layer.t2fis.output(str2double(varIndex1)).mf(str2double(MFIndex1)).params = MFParams1;
                    layer.t2fis.output(str2double(varIndex2)).mf(str2double(MFIndex2)).params = MFParams2;
                else
                    varIndex = lp{2};
                    MFIndex = lp{3};
                    MFParams = layer.t2fis.output(str2double(varIndex)).mf(str2double(MFIndex)).params;
                    indexlist{end+1} = append('0.00',string(i));
                    MFParams=strrep(MFParams,lp{1},append('0.00',string(i)));
                    layer.t2fis.output(str2double(varIndex)).mf(str2double(MFIndex)).params = MFParams;
                end
            else
%                 [{pattern(i)},{num2str(varIndex)},{num2str(MFIndex1)},{num2str(MFIndex2)},{'i'},{MFName}]
                if iscell(lp{end})
                    varIndex1 = lp{2}{1};
                    varIndex2 = lp{2}{2};
                    MFIndex11 = lp{3}{1};MFIndex12 = lp{3}{2};
                    MFIndex21 = lp{4}{1};MFIndex22 = lp{4}{2};
                    MFParams1 = layer.t2fis.input(str2double(varIndex1)).mf(str2double(MFIndex11),str2double(MFIndex21)).params;
                    MFParams2 = layer.t2fis.input(str2double(varIndex2)).mf(str2double(MFIndex12),str2double(MFIndex22)).params;
                    indexlist{end+1} = {append('0.00',string(i)),append('0.00',string(i*11))};
                    MFParams1=strrep(MFParams1,lp{1},append('0.00',string(i)));
                    MFParams2=strrep(MFParams2,lp{1},append('0.00',string(i*11)));
                    layer.t2fis.input(str2double(varIndex1)).mf(str2double(MFIndex11),str2double(MFIndex21)).params=MFParams1;
                    layer.t2fis.input(str2double(varIndex2)).mf(str2double(MFIndex12),str2double(MFIndex22)).params=MFParams2;
                else
                    varIndex = lp{2};
                    MFIndex1 = lp{3};
                    MFIndex2 = lp{4};
                    MFParams = layer.t2fis.input(str2double(varIndex)).mf(str2double(MFIndex1),str2double(MFIndex2)).params;
                    indexlist{end+1} = append('0.00',string(i));
                    MFParams=strrep(MFParams,lp{1},append('0.00',string(i)));
                    layer.t2fis.input(str2double(varIndex)).mf(str2double(MFIndex1),str2double(MFIndex2)).params=MFParams;
                end
              
            end
        end

        for i=1:length(layer.t2fis.learnableParameters)
             lp = layer.t2fis.learnableParameters{i};
             numberofChannels = 1;
             if lp{end-1} == 'o'
                if lp{1} == 'delta'
                    layer.parameterList(i,:) = rand(numberofChannels,1)*0.01+memberList{i};
                    layer.mask{end+1} = i1;
                else
                     if iscell(lp{end})
                        varIndex1 = lp{2}{1};
                        MFIndex1 = lp{3}{1};
                        varIndex2 = lp{2}{2};
                        MFIndex2 = lp{3}{2};
                        MFParams1 = layer.t2fis.output(str2double(varIndex1)).mf(str2double(MFIndex1)).params;
                        MFParams2 = layer.t2fis.output(str2double(varIndex2)).mf(str2double(MFIndex2)).params;
                        if isstring(MFParams1)
                            MFParams1= eval(MFParams1);
                        end
                        if isstring(MFParams2)
                            MFParams2= eval(MFParams2);
                        end
                        i1 = find(MFParams1==double(indexlist{i}{1}));
                        i2 = find(MFParams2==double(indexlist{i}{2}));
                        layer.mask{end+1} = {i1,i2};
                        MFParams1(i1) = memberList{i}{1};
                        MFParams2(i2) = memberList{i}{2};
                        r1 = rand(numberofChannels,1)*0.01+memberList{i}{1};
                        r2 = rand(numberofChannels,1)*0.01+memberList{i}{2};
                        layer.parameterList(i,:) = [r1-abs(r2) r1+abs(r2)];
                        layer.t2fis.output(str2double(varIndex1)).mf(str2double(MFIndex1)).params = MFParams1;
                        layer.t2fis.output(str2double(varIndex2)).mf(str2double(MFIndex2)).params = MFParams2;
                     else
                        varIndex = lp{2};
                        MFIndex = lp{3};
                        MFParams = layer.t2fis.output(str2double(varIndex)).mf(str2double(MFIndex)).params;
                        if isstring(MFParams)
                            MFParams= eval(MFParams);
                        end
                        i1 = find(MFParams==double(indexlist{i}));
                        layer.mask{end+1} = i1;
                        MFParams(i1) =memberList{i};
                        r = rand(numberofChannels,1)*0.01+memberList{i};
                        layer.parameterList(i,:) = [r];
                        layer.t2fis.output(str2double(varIndex)).mf(str2double(MFIndex)).params = MFParams;
                     end
                end
             else
                 if iscell(lp{end})
                    varIndex1 = lp{2}{1};
                    varIndex2 = lp{2}{2};
                    MFIndex11 = lp{3}{1};MFIndex12 = lp{3}{2};
                    MFIndex21 = lp{4}{1};MFIndex22 = lp{4}{2};
                    MFParams1 = layer.t2fis.input(str2double(varIndex1)).mf(str2double(MFIndex11),str2double(MFIndex21)).params;
                    MFParams2 = layer.t2fis.input(str2double(varIndex2)).mf(str2double(MFIndex12),str2double(MFIndex22)).params;
                    if isstring(MFParams1)
                        MFParams1= eval(MFParams1);
                    end
                     if isstring(MFParams2)
                        MFParams2= eval(MFParams2);
                     end
                    i1 = find(MFParams1==double(indexlist{i}{1}));
                    i2 = find(MFParams2==double(indexlist{i}{2}));
                    layer.mask{end+1} = {i1,i2};
                    MFParams1(i1) = memberList{i}{1};
                    MFParams2(i2) = memberList{i}{2};
%                     r=rand(numberofChannels,1)*0.1*-2+0.1;
                    r=rand(numberofChannels,1)*0.01;
                    r1 = r+memberList{i}{1};
                    r2 = r+memberList{i}{2};
                    layer.parameterList(i,:) = [r1 r2];
                    layer.t2fis.input(str2double(varIndex1)).mf(str2double(MFIndex11),str2double(MFIndex21)).params=MFParams1;
                    layer.t2fis.input(str2double(varIndex2)).mf(str2double(MFIndex12),str2double(MFIndex22)).params=MFParams2;
                 else
                    varIndex = lp{2};
                    MFIndex1 = lp{3};
                    MFIndex2 = lp{4};
                    MFParams = layer.t2fis.input(str2double(varIndex)).mf(str2double(MFIndex1),str2double(MFIndex2)).params;
                    if isstring(MFParams)
                        MFParams= eval(MFParams);
                    end
                    i1 = find(MFParams==double(indexlist{i}));
                    layer.mask{end+1} = i1;
                    MFParams(i1) =memberList{i};
                    r = rand(numberofChannels,1)*0.01+memberList{i};
                    layer.parameterList(i,:) = [r];
                    layer.t2fis.input(str2double(varIndex)).mf(str2double(MFIndex1),str2double(MFIndex2)).params=MFParams;
                 end
             end
        end
%                 layer.mask = layer.mask./2;
        end
    
        function [layer] = updateLearnableMFParams(layer,k)
            
            eps = 10^-6;
            for i=1:length(layer.t2fis.learnableParameters)
                 lp = layer.t2fis.learnableParameters{i};
                  if lp{end-1} == 'o'
                    if iscell(lp{end})
                        varIndex1 = lp{2}{1};
                        MFIndex1 = lp{3}{1};
                        varIndex2 = lp{2}{2};
                        MFIndex2 = lp{3}{2};
%                         k1=str2double(MFIndex1);k2=str2double(MFIndex2);
                        MFParams1 = layer.t2fis.output(str2double(varIndex1)).mf(str2double(MFIndex1)).params;
                        MFParams2 = layer.t2fis.output(str2double(varIndex2)).mf(str2double(MFIndex2)).params;
                        MFParams1 = MFParams1.*(layer.parameterList(i,k)+eps)./(layer.parameterList(i,k)+eps);
                        MFParams2 = MFParams2.*(layer.parameterList(i,k)+eps)./(layer.parameterList(i,k)+eps);
                        MFParams1(layer.mask{i}{1}) = layer.parameterList(i,1);
                        MFParams2(layer.mask{i}{2}) = layer.parameterList(i,2);
                        layer.t2fis.output(str2double(varIndex1)).mf(str2double(MFIndex1)).params = MFParams1-abs(MFParams2);
                        layer.t2fis.output(str2double(varIndex2)).mf(str2double(MFIndex2)).params = MFParams1+abs(MFParams2);
                    else
                        varIndex = lp{2};
                        MFIndex = lp{3};
%                         k=str2double(MFIndex);
                        MFParams = layer.t2fis.output(str2double(varIndex)).mf(str2double(MFIndex)).params;
                        MFParams = MFParams.*(layer.parameterList(i,k)+eps)./(layer.parameterList(i,k)+eps);
                        ln_params = MFParams(layer.mask{i});
                        if lp{1} == 'delta'
                            MFParams(layer.mask{i}) = [ln_params(1)-abs(layer.parameterList(i,k)), ln_params(2)+abs(layer.parameterList(i,k))];
                        else
                            r1=layer.parameterList(i,k);
                            MFParams(layer.mask{i}) = r1;
                        end
                        layer.t2fis.output(str2double(varIndex)).mf(str2double(MFIndex)).params = MFParams;
                    end
                 else
                    if iscell(lp{end})
                        varIndex1 = lp{2}{1};
                        varIndex2 = lp{2}{2};
                        MFIndex11 = lp{3}{1};MFIndex12 = lp{3}{2};
                        MFIndex21 = lp{4}{1};MFIndex22 = lp{4}{2};
                        MFParams1 = layer.t2fis.input(str2double(varIndex1)).mf(str2double(MFIndex11),str2double(MFIndex21)).params;
                        MFParams2 = layer.t2fis.input(str2double(varIndex2)).mf(str2double(MFIndex12),str2double(MFIndex22)).params;
                        MFParams1 = MFParams1.*(layer.parameterList(i,k)+eps)./(layer.parameterList(i,k)+eps);
                        MFParams2 = MFParams2.*(layer.parameterList(i,k)+eps)./(layer.parameterList(i,k)+eps);
                        MFParams1(layer.mask{i}{1}) = layer.parameterList(i,k);
                        MFParams2(layer.mask{i}{2}) = layer.parameterList(i,k);
                        layer.t2fis.input(str2double(varIndex1)).mf(str2double(MFIndex11),str2double(MFIndex21)).params=MFParams1;
                        layer.t2fis.input(str2double(varIndex2)).mf(str2double(MFIndex12),str2double(MFIndex22)).params=MFParams2;
                    else
                        varIndex = lp{2};
                        MFIndex1 = lp{3};
                        MFIndex2 = lp{4};
                        MFParams = layer.t2fis.input(str2double(varIndex)).mf(str2double(MFIndex1),str2double(MFIndex2)).params;
                        MFParams = MFParams.*(layer.parameterList(i,k)+eps)./(layer.parameterList(i,k)+eps);
                        r=layer.parameterList(i,k);
                        r = sigmoid(r);                        

%                         if r<0.1 || r>0.9
%                             a=0;
%                             r = l_p(i,k);
%                             layer.parameterList(i,k)=r;
%                         end
%                         if r>1
%                             a=0;
%                         end
%                         r(r<0) = 0.1; r(r>1) = 0.9;
                        layer.parameterList(i,k)=r;
                        MFParams(layer.mask{i}) = r;
                        layer.t2fis.input(str2double(varIndex)).mf(str2double(MFIndex1),str2double(MFIndex2)).params=MFParams;

                    end
                 end
            end
%             layer.consequents = cmfs;
        end
        
        function TRMethodfunc = getTRmethod(layer)
                TRMethod = layer.t2fis.typeRedMethod;
                switch TRMethod
                    case 'Karnik-Mendel'
                        TRMethodfunc='t2f_TR_KM';
                    case 'KM'
                        TRMethodfunc='t2f_TR_KM';
                    case 'EKM'
                        TRMethodfunc='t2f_TR_EKM';
                    case 'IASC'
                        TRMethodfunc='t2f_TR_IASC';
                    case 'EIASC'
                        TRMethodfunc='t2f_TR_EIASC';
                    case 'EODS'
                        TRMethodfunc='t2f_TR_EODS';
                    case 'WM'
                        TRMethodfunc='t2f_TR_WM';
                    case 'NT'
                        TRMethodfunc='t2f_TR_NT';
                    case 'BMM'
                        TRMethodfunc='t2f_TR_BMM';
                    case 'SM'
                        TRMethodfunc='t2f_TR_NB';
                    otherwise
                        TRMethodfunc=TRMethod;
                end
        end
        
        function member = initializeMemberShips(layer,i)
            lp = layer.t2fis.learnableParameters{i};
            mf = lp{1};
            switch mf
                case "delta"
                     member = '0';
                case "N"
                     member = '-2';
                case "Z"
                     member = '0';
                case 'P'
                     member = '0.1';
                case 'ps'
                     member = '0.3';
                case 'ns'
                     member = '-0.3';
                case 'nm'
                     member = '-0.5';
                case 'pm'
                     member = '0.5';
                case 'Sigma'
                      member = '0.1';                 
                case 'Center'
                      if iscell(lp{end})
                         if (contains(lp{end}{1},'1'))
                             member = '-0.5';
                         elseif (contains(lp{end}{1},'2'))
                             member = '0';
                         elseif (contains(lp{end}{1},'3'))
                             member = '0.5';
                         end
                     else
                         if (contains(lp{end},'1'))
                             member = '-0.5';
                        elseif (contains(lp{end},'2'))
                             member = '0';
                         elseif (contains(lp{end},'3'))
                             member = '0.5';
                         end
                     end
            end
           if contains(mf,'o')
               member='0';
           end
        end
        
    end
end