% Soeren Sofke, IBS
% Reference: https://www.youtube.com/watch?v=qy0fDqoMJx8

close all;

h = FluentDataFrame();
h.read_csv('http://bit.ly/drinksbycountry') ...    
	.head();

h = FluentDataFrame();
h.read_csv('http://bit.ly/drinksbycountry') ...
    .copy_to('frame') ...
    .spirit_servings ...
    .head;

h = FluentDataFrame();
h.read_csv('http://bit.ly/drinksbycountry') ...
    .groupby('continent') ...
    .beer_servings ...
    .mean;

h = FluentDataFrame();
h.read_csv('http://bit.ly/drinksbycountry') ...
    .groupby('continent') ...
    .beer_servings ...
    .agg('mean', 'min', 'max');






