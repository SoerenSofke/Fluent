% Soeren Sofke, IBS

close all;
clear;

%% Load Data from web
thisFilename = websave(tempname, 'http://bit.ly/drinksbycountry');
thisTable = readtable(thisFilename);

%% Identify groups across continents
[g, tid] = findgroups(thisTable(:, 'continent'));
numContinents = height(tid);

%% Determine average alcohol consume per continent
thisTable = removevars(thisTable, {'country', 'continent'});
variableNames = thisTable.Properties.VariableNames;
numVariables = numel(variableNames);

averageConsume = nan(numContinents, numVariables);
for idx = 1:numVariables
    thisVariableName = variableNames{idx};
    averageConsume(:, idx) = splitapply(@mean, thisTable.(thisVariableName), g);
end

%% Plot alcohol consume and beautify the figrue
hFigure = figure();
positionSize = hFigure.OuterPosition;
goldenFactor = (1 + sqrt(5)) * 0.5;

positionSize(3) = positionSize(4) * goldenFactor; %% make wider
positionSize(2) = positionSize(2) / 2; %% move down
hFigure.OuterPosition = positionSize;

hold on; box on; grid on;
bar(averageConsume)
legend(variableNames, 'interpreter', 'none', 'location', 'northeastoutside')
xticklabels(tid{:,'continent'})
set(gca, 'LooseInset', get(gca, 'TightInset'))

%% Finally, print the figrue to svg
print('drinks', '-dsvg')
