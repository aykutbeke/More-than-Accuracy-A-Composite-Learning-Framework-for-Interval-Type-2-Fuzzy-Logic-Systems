clc; close all; clear 

%% add to path helpers
warning off
rmpath(genpath('.'))
addpath('Read_Eval_Functions') 
addpath('helperFunctions') 
%% add to path the parametric IT2_FLS
models = ["H-C","H-L","H-IV","H-IVL","S-C","S-L","S-IV","S-IVL","HS-C","HS-L","HS-IV","HS-IVL"];
% Select the parametric IT2-FLS
% 1->H-C, 2->H-L, 3->H-IV, 4->H-IVL, 5->S-C , 6->S-L, 7->S-IV, 8->S-IVL, 9->HS-C, 10->HS-L, 11->HS-IV, 12->HS-IVL
model=2;
parametricModel=getpath(model);
addpath(parametricModel)


%%
function p = getpath(model)   
     switch model
                    case 1
                        p='IT2-FLSs/IT2-FLS-C/H/';
                    case 2
                        p='IT2-FLSs/IT2-FLS-L/H/';
                    case 3
                        p='IT2-FLSs/IT2-FLS-IV/H/';
                    case 4
                        p='IT2-FLSs/IT2-FLS-IVL/H/';
                    case 5
                        p='IT2-FLSs/IT2-FLS-C/S/';
                    case 6
                        p='IT2-FLSs/IT2-FLS-L/S/';
                    case 7
                        p='IT2-FLSs/IT2-FLS-IV/S/';
                    case 8
                        p='IT2-FLSs/IT2-FLS-IVL/S/';
                    case 9
                        p='IT2-FLSs/IT2-FLS-C/HS/';
                    case 10
                        p='IT2-FLSs/IT2-FLS-L/HS/';
                    case 11
                        p='IT2-FLSs/IT2-FLS-IV/HS/';
                    otherwise
                        p='IT2-FLSs/IT2-FLS-IVL/HS/';
     end
end