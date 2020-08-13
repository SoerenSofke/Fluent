% Soeren Sofke, IBS
% Reference: https://www.youtube.com/watch?v=qy0fDqoMJx8

close all;
clc

%%
load patients
patients = Fluent(table(Gender, Smoker, Height, Weight));
p1 = patients.group('Gender', 'Smoker')
p2 = patients.group('Smoker').mean
p3 = patients.col('Smoker', 'Height')
p4 = patients.group('Gender').group('Smoker').mean

%%
drinks = Fluent('https://bit.ly/drink-csv');
disp(drinks)

d1 = drinks.head(2) %% Instance itself is not mutated
d2 = drinks.tail(1) %% Instance itself is not mutated
d3 = drinks.head(4).tail(3) %% Instance itself is not mutated, but along the method chain states mutate
d4 = drinks.col('beer_servings', 'spirit_servings', 'wine_servings').head()
d5 = drinks.col('beer_servings', 'wine_servings').mean.round
d6 = drinks.row(12:15, 20).col('beer_servings')
d7 = drinks.group('continent').col('beer_servings').mean
d8 = drinks.row(12:15, 20).min
d9 = drinks.row(12:15, 20).mean
d10 = drinks.row(12:15, 20).max
d11 = drinks.row(12:15, 20).floor
d12 = drinks.row(12:15, 20).round
d13 = drinks.row(12:15, 20).ceil
d14 = drinks.row(12:15, 20).mean.round

Fluent('https://bit.ly/drink-csv').group('continent').mean.bar('continent').print('drinks.svg')