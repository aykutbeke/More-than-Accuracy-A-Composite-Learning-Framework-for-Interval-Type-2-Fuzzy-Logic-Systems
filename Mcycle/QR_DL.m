clc;clear;h= findall(groot,'Type','Figure');close(h)
rng('default')
%% Load
load mcycle.mat
% xn=(x-min(x))./(max(x)-min(x));
% yn = (y-min(y))./(max(y)-min(y));
x = data(:,3);
y = data(:,4);
xn=(x-mean(x))/(std(x));
yn = (y-mean(y))/(std(y));
data = [xn yn];
[m,~] = size(data);
P = 2/3;
deg=10;
idx = randperm(m)  ;
Training = data(idx(1:round(P*m)),:) ; 
Testing = data(idx(round(P*m)+1:end),:);
%%  FFNetwork
nout = 3;
inputRegressor = Training(:,1:end-1);
prediction=1;
FF_NetworkLayers = [ ...
    sequenceInputLayer(size(inputRegressor',1),'Name','FF-Giris')
      IT2FLS(nout, 'SIT2', Training)
    ];
lgraph = layerGraph(FF_NetworkLayers);
dlnet = dlnetwork(lgraph);


miniBatchSize = 32;
lr=0.1;
tau=[0.1 0.9];
numEpochs = 100;
XTrain = Training(:,1:end-1)';
YTrain = Training(:,end)';
XTest = Testing(:,1:end-1)';
YTest = Testing(:,end)';

numObservations = numel(YTrain);
numIterationsPerEpoch = floor(numObservations./miniBatchSize);
executionEnvironment = "auto";
averageGrad = [];
averageSqGrad = [];
vel=[];
Traloss=[];
Testloss=[];
m=[];
plots = "training-progress";
if plots == "training-progress"
    lineLossTrain = animatedline;
    xlabel("Total Iterations")
    ylabel("Loss")
end

 XTrain = dlarray(XTrain, 'CT');
 XTest = dlarray(XTest, 'CT');
 iteration = 1;
 n=1;
for epoch = 1:numEpochs
%     Shuffle data.
    idx = randperm(numel(YTrain));
    XTrain = XTrain(:,idx);
    YTrain = YTrain(idx);
    if epoch == 70
     lr=lr*0.1;
    end
    for i = 1:numIterationsPerEpoch
        
        % Read mini-batch of data and convert the labels to dummy
        % variables.
        idx = (i-1)*miniBatchSize+1:i*miniBatchSize;
        X = XTrain(:,idx);
        Y = YTrain(idx);
        

        % Convert mini-batch of data to dlarray.
        if (executionEnvironment == "auto" && canUseGPU) || executionEnvironment == "gpu"
            dlX = gpuArray(single(X));
            dlXt = gpuArray(single(XTest));

        end
        
        % Evaluate the model gradients and loss using dlfeval and the
        % modelGradients function.
        [grad,loss] = dlfeval(@modelGradients,dlnet,dlX,Y,tau);
        Traloss = [Traloss;loss];
        if n == 3         
            [~,loss_t] = dlfeval(@modelGradients,dlnet,dlXt,YTest,tau);
            Testloss = [Testloss;loss_t];
            n=1;
            m=[m;iteration];
        end
        % Update the network parameters using the Adam optimizer.
        [dlnet,averageGrad,averageSqGrad] = adamupdate(dlnet,grad,averageGrad,averageSqGrad,iteration,lr);
        % Display the training progress.
        if plots == "training-progress"
            addpoints(lineLossTrain,iteration,double(gather(extractdata(loss))))
            title("Loss During Training: Epoch - " + epoch + "; Iteration - " + i)
            drawnow
        end
        % Increment iteration counter
        iteration = iteration + 1;
        n=n+1;
    end
end
%%
PredFF_train = forward(dlnet, gpuArray(single(dlarray(Training(:,1:end-1)','CT'))));
PredFF_test = forward(dlnet, gpuArray(single(dlarray(Testing(:,1:end-1)','CT'))));
PredFF_train = double(gather(PredFF_train.extractdata));
PredFF_test = double(gather(PredFF_test.extractdata));

plot_train=sortrows([Training(:,1) Training(:,end) PredFF_train']);
plot_test=sortrows([Testing(:,1) Testing(:,end) PredFF_test']);  
i_tr = plot_train(:,1); o_tr = plot_train(:,2); y_mtr = plot_train(:,3); y_l_tr = plot_train(:,4); y_u_tr = plot_train(:,5);    
i_ts = plot_test(:,1); o_ts = plot_test(:,2); y_mts= plot_test(:,3); y_l_ts = plot_test(:,4); y_u_ts = plot_test(:,5);    
%%
figure
plot(1:iteration-1,double(gather(Traloss.extractdata)),'k')
hold on
plot(m,double(gather(Testloss.extractdata)),'r')
figure
subplot(1,2,1)
plot(Training(:,1),Training(:,end),'X',plot_train(:,1), plot_train(:,3:end))
title('Train RMSE:'+string(double(rmse(o_tr,y_mtr))) + ', MAE:'+string(double(mae(o_tr,y_mtr))) + ', NMSE:'+string(double(nmse(o_tr,y_mtr))) + ', PICP:'+string(double(PICP(o_tr,y_l_tr,y_u_tr))) + ', PINAW:'+string(double(PINAW(y_l_tr,y_u_tr))))
subplot(1,2,2)
plot(Testing(:,1),Testing(:,end),'X',plot_test(:,1), plot_test(:,3:end))
title('Train RMSE:'+string(double(rmse(o_ts,y_mts))) + ', MAE:'+string(double(mae(o_ts,y_mts))) + ', NMSE:'+string(double(nmse(o_ts,y_mts))) + ', PICP:'+string(double(PICP(o_ts,y_l_ts,y_u_ts))) + ', PINAW:'+string(double(PINAW(y_l_ts,y_u_ts))))


% plotT2Layers(FF_NetworkLayers, FF_Network)


function [gradients,loss] = modelGradients(dlnet,dlX,Y,tau)

dlYPred = forward(dlnet,dlX);
r = Y-dlYPred;
loss = getLoss(r,tau,3);
gradients = dlgradient(loss,dlnet.Learnables);

end

function l = getLoss(r,tau,m)
    switch m 
        case 1
              l1 = mean((r(1,:)).^2);
              l2 = 0;
                  for i=2:length(tau)+1
                       l2 = l2 + sum(abs(r(i,:).*(tau(i-1)-(r(i,:)<0))));
                  end
              l = l1+l2;
        case 2
              l1 = mean(abs(r(1,:)));
              l2 = 0;
                  for i=2:length(tau)+1
                       l2 = l2 + sum(abs(r(i,:).*(tau(i-1)-(r(i,:)<0))));
                  end
              l = l1+l2;
         case 3
              l1 = sum(log(cosh(r(1,:))));
              l2 = 0;
                  for i=2:length(tau)+1
                       l2 = l2 + sum(abs(r(i,:).*(tau(i-1)-(r(i,:)<0))));
                  end
              l = l1+l2;

    end


end





