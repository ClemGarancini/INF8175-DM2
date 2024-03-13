from uflp import UFLP
import random
from typing import List, Tuple
import math

# LEBLANC ANTOIN (2310186)
# GARANCINI CLEMENT (2315136)

def solve(problem: UFLP) -> Tuple[List[int], List[int]]:
    """
    Votre implementation, doit resoudre le probleme via recherche locale.

    Args:
        problem (UFLP): L'instance du probleme à résoudre

    Returns:
        Tuple[List[int], List[int]]: 
        La premiere valeur est une liste représentant les stations principales ouvertes au format [0, 1, 0] qui indique que seule la station 1 est ouverte
        La seconde valeur est une liste représentant les associations des stations satellites au format [1 , 4] qui indique que la premiere station est associée à la station pricipale d'indice 1 et la deuxieme à celle d'indice 4
    """
    # Définition de la fonction permettant d'obtenir les voisisn : 
    def get_neighbor(state):
        G = []
        n_station = problem.n_main_station
        n_satellite = problem.n_satellite_station

        for i in range(n_station):
            neighbor = state[0][:i] + [1 - state[0][i]] + state[0][i+1:]

            if neighbor.count(1) > 0:
                open_stations = [i for i in range(n_station) if neighbor[i] == 1]
                new_satellite = state[1]
                for j in range(n_satellite):
                    x2,y2 = problem.satellite_stations_connection_coordinates[j]
                    distances = []
                    for station in open_stations :
                        x1,y1 = problem.main_stations_coordinates[station]
                        distances.append(problem.coordinates_to_cost(x1, y1, x2, y2))

                    distance_min = min(distances)
                    indice = distances.index(distance_min)
                    best_main_station = open_stations[indice]
                    new_satellite = new_satellite[:j] + [best_main_station] + new_satellite[j+1:]

                G.append([neighbor,new_satellite])

        return G
    
    # Définition de la fonction permettant d'obtenir les voisisn : 
    def filter_of_neighbor(G,state):
        L = []
        for neighbor in G:
            if problem.solution_checker(neighbor[0], neighbor[1]):
                L.append(neighbor)
        return L

    # définition des hyperparamètres
    t0 = 100
    alpha = 0.99
    theta = 100

    # Ouverture aléatoire des stations principales
    main_stations_opened = [random.choice([0,1]) for _ in range(problem.n_main_station)]

    # Si, par hasard, rien n'est ouvert, on ouvre une station aléatoirement
    if sum(main_stations_opened) == 0:
        main_stations_opened[random.choice(range(problem.n_main_station))] = 1

    # Association aléatoire des stations satellites aux stations principales ouvertes
    indices = [i for i in range(len(main_stations_opened)) if main_stations_opened[i] == 1]
    satellite_station_association = [random.choice(indices) for _ in range(problem.n_satellite_station)]
    
    # On intialise la température, l'état et le meilleur état
    state = [main_stations_opened,satellite_station_association]
    best_state = state
    t = t0

    # On initialise la liste des voisins visités
    Visited = [state]
    k=0 

    while k <= theta:
        G = get_neighbor(state)
        V = filter_of_neighbor(G,state)
        new_state = random.choices(V)[0]
        Delta = problem.calcultate_cost(new_state[0],new_state[1]) - problem.calcultate_cost(state[0],state[1])
        if Delta <= 0:
            state = new_state
            k=0
        elif Delta >0:
            p_selection = math.exp(-Delta/t)
            if random.random() < p_selection :
                state = new_state
                k=0
        if problem.calcultate_cost(state[0],state[1]) < problem.calcultate_cost(best_state[0],best_state[1]):
            best_state = state
        t = alpha*t
        k+=1
    return best_state[0], best_state[1]

