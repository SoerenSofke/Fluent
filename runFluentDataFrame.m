% Soeren Sofke, IBS
% Reference: https://www.youtube.com/watch?v=qy0fDqoMJx8

close all;
clc

drinks = Fluent('http://bit.ly/drinksbycountry');
d1 = drinks.head(2) %% Instance itself is not mutated
d2 = drinks.tail(1) %% Instance itself is not mutated
d3 = drinks.head(4).tail(3) %% Instance itself is not mutated, but along the method chain states mutate
d4 = drinks.col('beer_servings', 'spirit_servings', 'wine_servings').head()
d5 = drinks.col('beer_servings', 'wine_servings').mean.round
d6 = drinks.row(12:15, 20).col('beer_servings')
d6 = drinks.row(12:15, 20).col('beer_servings').mean
d7 = drinks.group('continent', 'country').col('beer_servings').mean


%disp(drinks)

%%
load patients
patients = Fluent(table(Gender, Smoker, Height, Weight));
p1 = patients.group('Gender', 'Smoker')
p2 = patients.group('Gender', 'Smoker').col('Height').mean





