% LEBLANC_ANTOINE (2310186)
% GARANCINI_CLEMENT (2315136)

include "globals.mzn";

% Nombre de fréquences à placer
int: m;
% Placements possibles selon le nombre de fréquences
int: n = m*m;

% Définition de la plage de fréquences 
array[1..m] of var 0..n: frequences;

% Calcul des distances entre les différentes fréquences
array[1..(m*(m-1)) div 2] of var 0..n: distances =
    [ frequences[j] - frequences[i] | i in 1..m, j in i+1..m];

% Variable objectif à minimiser
var int: longueur = frequences[m];

%-----------------------------------------------------------------------------%
% Partie étudiant
%-----------------------------------------------------------------------------%
%La premiere frequence est 0
constraint frequences[1] = 0;
%Les fréquences sont croissantes
constraint increasing(frequences);
%Toutes les distances sont différents
constraint alldifferent(distances);


solve minimize longueur;
%-----------------------------------------------------------------------------%

output 
  [show(frequences)]
  ++
  ["\nLongueur de la plage = ", show(longueur)];
