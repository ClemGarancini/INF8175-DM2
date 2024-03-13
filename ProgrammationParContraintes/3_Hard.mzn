% LEBLANC_ANTOINE (2310186)
% GARANCINI_CLEMENT (2315136)

include "globals.mzn";

% Énumérations des équipes participant au tournoi
enum equipes = {CO, TA, HO, DA, NA, MU, AL, UT};

% Lieux de rencontres des equipes (0 = pas de rencontre).
% Tout lieu i, tel que 0 < i <= card(equipes), 
% est designé comme le domicile de l'équipe associée par la relation to_enum(equipe, i)
set of int: terrains = 0..card(equipes);

% Étendue du tournoi (en jours)
int: d = 16;
set of int: jours = 1..d;

% Calendrier de placement des matchs
array[equipes, jours] of var terrains: calendrier;

% Nombres de rencontres entre deux equipes
array[equipes, equipes] of var 0..2: rencontres;

% Tuples des dates de match entre deux équipes
array[equipes, equipes] of var tuple (0..d, 0..d): dates;

% Variable objectif à maximiser
var int: objectif_match_espaces;

%-----------------------------------------------------------------------------%
% Partie étudiant
%-----------------------------------------------------------------------------%

% Le terrain n'est utilisé qu'une seule fois par jour, les terrains n'accueillent que deux équipes ou 0.
constraint forall(jour in jours)(forall(terrain in terrains)(
   terrain != 0 -> ((count(calendrier[equipes, jour],terrain) == 2) \/ (count(calendrier[equipes, jour],terrain) == 0))
));


% Le match se déroule à domicile pour une des deux équipes
constraint 
forall(i,j in 1..card(equipes) where j < i)( 

    (dates[equipes[i],equipes[j]].1 != 0 -> (
      (calendrier[equipes[i],dates[equipes[i],equipes[j]].1] == i) \/
      (calendrier[equipes[i],dates[equipes[i],equipes[j]].1] == j))
     ) /\
    (dates[equipes[i],equipes[j]].2 != 0 -> (
      (calendrier[equipes[i],dates[equipes[i],equipes[j]].2] == i) \/
      (calendrier[equipes[i],dates[equipes[i],equipes[j]].2] == j)) 
    )
);

% Une équipe ne joue pas contre elle-même
constraint forall(equipe1 in equipes)(
  dates[equipe1,equipe1] = (0,0)
);

% Une équipe ne peut pas jouer plus de 7 jours sur son propre terrain
constraint forall(i in 1..card(equipes))(
  count(calendrier[equipes[i], jours],i) <= 7
);

% Les équipes doivent jouer deux fois l'une contre l'autre et les matchs doivent être espacés de 3 jours minimum et symétrie de dates
constraint forall(i, j in 1..card(equipes) where j < i)(
  (dates[equipes[i],equipes[j]].1 != 0 /\ dates[equipes[i],equipes[j]].2 != 0) /\
  (dates[equipes[i],equipes[j]].2 >= dates[equipes[i],equipes[j]].1 + 3 ) /\
  (dates[equipes[i],equipes[j]] == dates[equipes[j],equipes[i]])
);

% Les deux rencontres doivent avoir lieu sur des terrains différents et si deux équipes jouent ensemble elles sont sur le même terrain.
constraint forall(i, j in 1..card(equipes) where j < i)(
  (calendrier[equipes[i],dates[equipes[i],equipes[j]].1] != calendrier[equipes[i],dates[equipes[i],equipes[j]].2]) 
  /\ 
  (dates[equipes[i],equipes[j]].1 != 0 -> (
    calendrier[equipes[i],dates[equipes[i],equipes[j]].1] == calendrier[equipes[j],dates[equipes[i],equipes[j]].1])
  )
  /\
  (dates[equipes[i],equipes[j]].1 != 0 -> (
    calendrier[equipes[i],dates[equipes[i],equipes[j]].2] == calendrier[equipes[j],dates[equipes[i],equipes[j]].2])
  )
);

% Définition de la fonction objectif
constraint objectif_match_espaces = 
  sum(i, j in 1..card(equipes) where (j<i) /\ (dates[equipes[i],equipes[j]].2 >= dates[equipes[i],equipes[j]].1 + 6) /\ (equipes[i] != equipes[j]))(1);
  
solve maximize objectif_match_espaces;

%-----------------------------------------------------------------------------%

% Affichage du calendrier par equipes et par jours puis du résultat de la fonction objectif.
% Lorsqu'une équipe ne joue pas, l'emplacement de match reste vide sinon elle contient le nom de l'équipie adverse.
% Si une équipe ne joue pas à domicile, un "@" précède le nom de l'équipe adverse.
output 
["Calendrier:\n"]
++
[if j = 1 then "   " else "" endif ++ if j < 10 then "  j" ++ show(j) else " j" ++ show(j) endif ++ if j = d then "\n" else "" endif | j in jours ]
++
[if j = 1 then show(e1) ++ ":" else "" endif ++ if fix(calendrier[e1,j]) = 0 then "    " else if fix(calendrier[e1,j]) = e1 then "  " ++ concat([if e1 != e2 /\ fix(calendrier[e2,j]) = e1 then show(e2) else "" endif | e2 in equipes])  else " @" ++ show(to_enum(equipes, calendrier[e1,j])) endif endif ++ if j = d then "\n" else "" endif | e1 in equipes, j in jours ]
++
["\nMatchs retour espacés de 6 jours ou plus = " ++ show(objectif_match_espaces) ++ "\n"]
;
