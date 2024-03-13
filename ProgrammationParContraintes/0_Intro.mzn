include "globals.mzn";

var 1000..9999: nombre;

array[1..4] of var 1..9: chiffres;

%Le nombre est la représentation des 4 chiffres
constraint nombre = chiffres[4] + 10 * chiffres[3] + 100 * chiffres[2] + 1000 * chiffres[1];
%Le nombre est pair
constraint chiffres[4] = 0 \/ chiffres[4] = 2 \/ chiffres[4] = 4 \/ chiffres[4] = 6 \/ chiffres[4] = 8;
%Tous les chiffres sont différents
constraint alldifferent(chiffres);
%Le chiffre des milliers est > à celui des centaines
constraint chiffres[1] > chiffres[2];
%Le chiffres des dizaines est < à celui des unités
constraint chiffres[3] < chiffres[4];
%La somme des chiffres est supérieure à 15
constraint sum(chiffres) > 15;

%Le produit des trois derniers chiffres doit être minimisée
solve minimize chiffres[2] * chiffres[3] * chiffres[4];

output [
  show(nombre)
];

