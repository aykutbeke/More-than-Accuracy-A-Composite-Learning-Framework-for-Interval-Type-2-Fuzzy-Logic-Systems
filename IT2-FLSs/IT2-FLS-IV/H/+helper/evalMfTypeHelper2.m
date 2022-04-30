function members = evalMfTypeHelper2(types,input,mfParams)
members = [];
for i=1:size(types,1)
    type = types(i,:);
    switch type
        case 'gaussmf'
             member =helper.mfs.myGaussmf(input, mfParams(i,:));
        case 'zmf'
             member =helper.mfs.zmf(input, mfParams(i,:));
        case 'trapmf'
             member =helper.mfs.trapmf(input, mfParams(i,:));
         case 'trimf'
            member =helper.mfs.myTriMF(input, mfParams(i,:));
         case 'sigmf'
            member =helper.mfs.sigmf(input, mfParams(i,:));
         case 'smf'
            member =helper.mfs.smf(input, mfParams(i,:));
         case 'psigmf'
            member =helper.mfs.psigmf(input, mfParams(i,:));
         case 'pimf'
            member =helper.mfs.pimf(input, mfParams(i,:));
         case 'gbellmf'
            member =helper.mfs.gbellmf(input, mfParams(i,:));
         case 'gauss2mf'
            member =helper.mfs.gauss2mf(input, mfParams(i,:));
         case 'dsigmf'
            member =helper.mfs.dsigmf(input, mfParams(i,:));              
    end
    members = [members; member];
end
end

