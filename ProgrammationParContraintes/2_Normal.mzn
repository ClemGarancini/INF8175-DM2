% LEBLANC_ANTOINE (2310186)
% GARANCINI_CLEMENT (2315136)

include "globals.mzn";

% États possibles pour une case du terrain
% V = Vide
% B = Tour bleue
% R = Tour rouge
enum etat = {V, B, R};

% Dimension du terrain (carré)
int: n;
set of int: dim = 1..n;

% État du terrain
array[dim, dim] of var etat: terrain;

% Variable objectif à maximiser
var int: total_commun;

%-----------------------------------------------------------------------------%
% Partie étudiant
%-----------------------------------------------------------------------------%

var int: nb_bleues; % Nombre de tours bleues
var int: nb_rouges; % Nombre de tours rouges
constraint nb_bleues = sum(i in dim, j in dim)(terrain[i,j] = B); 
constraint nb_rouges = sum(i in dim, j in dim)(terrain[i,j] = R);



% Il y autant de tour bleues que rouges
constraint nb_bleues = nb_rouges;

% Set des diagonales
set of int: diag = 2..2*n;

% Contraintes pour les lignes
constraint forall(i in dim)(
   count(terrain[i, dim],B) >= 1 -> count(terrain[i, dim],R) == 0
);

% Contraintes pour les colonnes
constraint forall(j in dim)(
   count(terrain[dim, j],B) >= 1 -> count(terrain[dim, j],R) == 0
);

% Contraintes pour les diagonales SO-NE
constraint forall(d in diag)(
   count([terrain[i, d - i]| i in max(1,d-n)..min(d-1,n)],B) >= 1 -> 
    count([terrain[i, d - i]| i in max(1,d-n)..min(d-1,n)],R) == 0
);

% Contraintes pour les diagonales SE-NO
constraint forall(d in diag)(
   count([terrain[i, d + i - (n+1)]| i in max(1,n+2-d)..min(2*n+1-d,n)],B) >= 1 -> 
    count([terrain[i, d + i - (n+1)]| i in max(1,n+2-d)..min(2*n+1-d,n)],R) == 0
);

% Fonction objectif
constraint total_commun = nb_bleues;

solve maximize total_commun;

%-----------------------------------------------------------------------------%
output 
["Terrain :\n"]
++
[if j = 1 then "["  endif ++ if fix(terrain[i,j]) == V then "_" else show(terrain[i,j]) endif ++ if j = n then "]\n" else "," endif | i in 1..n, j in 1..n]
++
["\n"]
++
["Total de tours commun: " ++ show(total_commun)]
