function member = evalMfTypeHelper( type,input,mfParams )
switch type
    case 'gaussmf'
         member =helper.mfs.gaussmf(input, mfParams);
    case 'zmf'
         member =helper.mfs.zmf(input, mfParams);
    case 'trapmf'
         member =helper.mfs.trapmf(input, mfParams);
     case 'trimf'
        member =helper.mfs.trimf(input, mfParams);
     case 'sigmf'
        member =helper.mfs.sigmf(input, mfParams);
     case 'smf'
        member =helper.mfs.smf(input, mfParams);
     case 'psigmf'
        member =helper.mfs.psigmf(input, mfParams);
     case 'pimf'
        member =helper.mfs.pimf(input, mfParams);
     case 'gbellmf'
        member =helper.mfs.gbellmf(input, mfParams);
     case 'gauss2mf'
        member =helper.mfs.gauss2mf(input, mfParams);
     case 'dsigmf'
        member =helper.mfs.dsigmf(input, mfParams);              
end
end
