function [ classValue, errorRate ] = bayesLearning(X, Y, category)
%bayesLearning
%   Detailed explanation goes here
%1 subtlety, 2 sphericity, 3 margin, 4 lobulation, 5 spiculation, 6 texture, 7 malignancy

Y = Y(:,category);

%Perform random sampling by just jumbling up the data then slicing the new
%set into 4ths or nths.
divisions = 10;
numSamples = size(X,1);
testSize = round(numSamples/divisions);

%get a random order of our rows
randomRows = randsample(numSamples, numSamples);

%get vector of row order to undo the scrambling of the rows
for i = 1:numSamples
    restoreRows(i) = find(i == randomRows);
end

Xmixed = X(randomRows,:);
Ymixed = Y(randomRows,:);


%perform process repeatedly with the test set different each time untill
%all are covered.
classValue = 0;
testrows = cell(divisions,1);
for i = 1:(divisions - 1) %perform all iterations guaranteeed to have a full share
    %start with testing at the beginning rows, then cycle down
    fprintf('Bayes learning %d0%%\n', i);
    testrows{i} = [(i-1)*testSize + 1:i*testSize];
    
    Xtest = Xmixed(testrows{i}, :);
    Ytest = Ymixed(testrows{i}, :);
    
    Xtrain = Xmixed;
    Xtrain(testrows{i},:) = [];
    Ytrain = Ymixed;
    Ytrain(testrows{i},:) = [];
    
    nb = NaiveBayes.fit(Xtrain, Ytrain, 'Distribution', 'kernel'); %'Distribution', 'kernel') or 'mvmn'
    [post,classValueTemp] = posterior(nb, Xtest, 'HandleMissing', 'On'); %returns classValue, an N-by-1 vector, containing the class to which each row of test has been assigned. cpre has the same type as nb.CLevels.
    classValue = vertcat(classValue, classValueTemp);
end
%collect all the remaining rows. Could be undersized, but eliminates
%problems of some rows getting lost
testrows{divisions} = [(divisions-1)*testSize + 1:numSamples];
    
Xtest = Xmixed(testrows{divisions}, :);
Ytest = Ymixed(testrows{divisions}, :);

Xtrain = Xmixed;
Xtrain(testrows{divisions},:) = [];
Ytrain = Ymixed;
Ytrain(testrows{divisions},:) = [];
    
nb = NaiveBayes.fit(Xtrain, Ytrain, 'Distribution', 'kernel');
%returns classValue, an N-by-1 vector, containing the class to which each row of test has been assigned. cpre has the same type as nb.CLevels.
%Also told to ignore collumns with NaN results and calculate on the rest of
%the columns
[post,classValueTemp] = posterior(nb, Xtest, 'HandleMissing', 'On'); 
classValue = vertcat(classValue(2:end,:), classValueTemp); %Chop off the zero we put at the beginning

%Resort everything to the original order so we can compare against other
%algorithms
classValue = classValue(restoreRows,:);

%perform RMSE on allll the samples
errorRate = RMSE(classValue, Y); %RMSE error. Maybe better as an array so we can combine in the future


end


