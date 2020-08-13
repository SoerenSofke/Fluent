%% Load data from web
thisFilename = websave(tempname, 'https://bit.ly/drink-csv');
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
hFigure.OuterPosition = positionSize;

hold on; box on; grid on;
bar(averageConsume)
legendString = cellfun(@(x) strrep(x, '_', ' '), variableNames, 'UniformOutput', false);
legend(legendString, 'interpreter', 'none', 'location', 'northeastoutside')
xticklabels(tid{:,'continent'})
set(gca, 'LooseInset', get(gca, 'TightInset'))

%% Finally, print the figrue to svg
print('drinks', '-dsvg')
