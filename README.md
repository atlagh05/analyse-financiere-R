# Analyse financière et boursière avec R

## Objectif du projet

Ce projet consiste à analyser la performance et le risque de 4 actions du CAC 40 
(Airbus, LVMH, L'Oréal, Sanofi) sur la période 2023-2026, à l'aide de R et RStudio.

## Méthodologie

- Collecte des données boursières via le package `quantmod`
- Nettoyage et calcul des rendements logarithmiques
- Calcul de la volatilité annualisée, du rendement cumulé et annualisé
- Calcul du ratio de Sharpe (taux sans risque : 2%) pour mesurer le couple rendement/risque
- Visualisations avec `ggplot2` : évolution des prix, performance comparée, 
  distribution des rendements, volatilité par action

## Résultats

| Action | Rendement annualisé | Volatilité annuelle | Ratio de Sharpe |
|--------|---------------------|----------------------|------------------|
| Airbus (AIR.PA) | -15,15% | 29,1% | -0,589 |
| LVMH (MC.PA) | 2,49% | 23,2% | 0,021 |
| L'Oréal (OR.PA) | 14,22% | 25,7% | **0,475** |
| Sanofi (SAN.PA) | -3,88% | 24,0% | -0,246 |

**Conclusion** : L'Oréal (OR.PA) présente le meilleur couple rendement/risque sur la 
période étudiée, avec le ratio de Sharpe le plus élevé (0,475) combiné à une 
volatilité maîtrisée.

## Outils utilisés

R, RStudio, quantmod, ggplot2, tidyverse

## Fichiers du projet

- `analyse_financiere_boursiere.R` : script complet de l'analyse
- `evolution_prix.png`, `performance_comparee.png`, `distribution_rendements.png`, 
  `volatilite_annuelle.png` : visualisations générées
- `synthese_performance.csv` : tableau récapitulatif des indicateurs calculés

## Auteure

Sana Atlagh — Licence Finance et Économie internationale (UVSQ)
