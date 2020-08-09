% Soeren Sofke, IBS
% Reference: https://www.youtube.com/watch?v=qy0fDqoMJx8

close all;

drinks = Fluent('http://bit.ly/drinksbycountry');
d1 = drinks.head(2) %% Instance itself is not mutated
d2 = drinks.tail(1) %% Instance itself is not mutated


d3 = drinks.head(4).tail(3) %% Instance itself is not mutated, but alog the method chaing states mutate

disp(drinks)



% h = Fluent();
% h.read_csv('http://bit.ly/drinksbycountry') ...
%     .copy_to('frame') ...
%     .spirit_servings ...
%     .head;
% 
% h = Fluent();
% h.read_csv('http://bit.ly/drinksbycountry') ...
%     .groupby('continent') ...
%     .beer_servings ...
%     .mean;
% 
% h = Fluent();
% h.read_csv('http://bit.ly/drinksbycountry') ...
%     .groupby('continent') ...
%     .beer_servings ...
%     .agg('mean', 'min', 'max');






