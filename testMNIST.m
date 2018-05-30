% Prep training data
trainImages = loadMNISTImages('mnist/train-images.idx3-ubyte');
trainLabels = loadMNISTLabels('mnist/train-labels.idx1-ubyte');
trainLabels = trainLabels';
trainLabels(trainLabels==0) = 10;    % replace all 0 with 10
trainLabels = dummyvar(trainLabels)';      % make a matrix 60000x10

% Load validation data
validatimages = loadMNISTImages('mnist/t10k-images.idx3-ubyte');
validatLabels = loadMNISTLabels('mnist/t10k-labels.idx1-ubyte');
validatLabels = validatLabels';
validatLabels(validatLabels==0) = 10;    % replace all 0 with 10
validatLabels = dummyvar(validatLabels)';      % make a matrix 60000x10



% When launching this script for the first time, matlab needs to initialize
% and train NN
% Upon consequent launch set the var first_time_launch to false to avoid retraining
first_time_launch = false;

if first_time_launch == true
    % Init NN and train it
    tn = ToyNet(2,784,10,20);    % Input params: i_numHiddenLayers, i_inputLayerSize, i_outputLayerSize, i_hiddenLayersSize
    % train(tn, trainImages, trainLabels, 1000000, 0.06);   % slow but accurate training
    disp('training...');
    train(tn, trainImages, trainLabels, 400000, 0.12);      % fast but not accurate training
end

% Pick image then forwardProp image and print result in the console.
index = 33;     % Pick some image by its index
testImg =  validatimages(:,index);
[~,digitNumber] = max(validatLabels(:,index))
perturbedImg = testImg;
classifRes = ones(10,1);

disp('working...');
while classifRes(digitNumber) > 0.5
% for i=1:500000
    forwardProp(tn, perturbedImg);
    perturbedImg = adversBackProp(tn, perturbedImg,validatLabels(:,index), 0.5);
    classifRes = forwardProp(tn, perturbedImg);
    classifRes(digitNumber);
end

% Didsplay picked image
figure;
subplot(1,3,1);
digit = reshape(perturbedImg, [28,28]);    % row = 28 x 28 image
imshow(digit*255, [0 255])      % show the image
title('perturbed');

subplot(1,3,2);
digit = reshape(testImg, [28,28]);    % row = 28 x 28 image
imshow(digit*255,[0 255])      % show the image
title('original');

subplot(1,3,3);
noisyImg = min(testImg + 0.3*rand(784,1), 1);   % limit the range from 0 to 1

digit = reshape(noisyImg, [28,28]);    % row = 28 x 28 image
imshow(digit*255,[0 255])      % show the image
title('random noise');

classificationResultPerturb = forwardProp(tn, perturbedImg)
classificationResultOrig = forwardProp(tn, testImg)
classificationResultNoisy = forwardProp(tn, noisyImg)
% celldisp(classificationResultPerturb)
% celldisp(classificationResultOrig)
% celldisp(classificationResultNoisy)
