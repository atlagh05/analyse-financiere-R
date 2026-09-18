## =============================================================
## ANALYSE FINANCIÈRE ET BOURSIÈRE AVEC R / RSTUDIO
## Rendements, volatilité, performance et indicateurs financiers
## =============================================================
## Adapte les tickers, la période et les commentaires à ton propre
## contexte avant de le présenter comme ton projet.

## -------------------------------------------------------------
## 1. INSTALLATION ET CHARGEMENT DES PACKAGES
## -------------------------------------------------------------
# Décommente la ligne suivante si les packages ne sont pas installés :
# install.packages(c("quantmod", "tidyverse", "PerformanceAnalytics"))

library(quantmod)             # récupération des données boursières
library(tidyverse)            # manipulation de données + ggplot2
library(PerformanceAnalytics) # indicateurs de performance financière

## -------------------------------------------------------------
## 2. COLLECTE DES DONNÉES
## -------------------------------------------------------------
# On choisit 4 actions du CAC 40 à titre d'exemple.
# Remplace ces tickers par ceux que tu as réellement étudiés.
tickers <- c("MC.PA",   # LVMH
             "OR.PA",   # L'Oréal
             "AIR.PA",  # Airbus
             "SAN.PA")  # Sanofi

date_debut <- "2023-01-01"
date_fin   <- Sys.Date()

# Téléchargement des prix ajustés depuis Yahoo Finance
donnees <- lapply(tickers, function(t) {
  getSymbols(t, src = "yahoo", from = date_debut, to = date_fin,
             auto.assign = FALSE)[, 6]  # colonne "Adjusted"
})
names(donnees) <- tickers

# Fusion en un seul data frame (une colonne par action)
prix <- do.call(merge, donnees)
colnames(prix) <- tickers

## -------------------------------------------------------------
## 3. NETTOYAGE DES DONNÉES
## -------------------------------------------------------------
# Suppression des lignes avec valeurs manquantes (jours sans cotation commune)
prix <- na.omit(prix)

# Conversion en data frame "long" pour ggplot2
prix_df <- data.frame(date = index(prix), coredata(prix)) %>%
  pivot_longer(-date, names_to = "action", values_to = "prix_ajuste")

## -------------------------------------------------------------
## 4. CALCUL DES RENDEMENTS
## -------------------------------------------------------------
# Rendements journaliers logarithmiques (standard en finance)
rendements <- Return.calculate(prix, method = "log")
rendements <- na.omit(rendements)

rendements_df <- data.frame(date = index(rendements), coredata(rendements)) %>%
  pivot_longer(-date, names_to = "action", values_to = "rendement")

## -------------------------------------------------------------
## 5. CALCUL DE LA VOLATILITÉ
## -------------------------------------------------------------
# Volatilité annualisée = écart-type des rendements journaliers * racine(252 jours de bourse)
volatilite_annuelle <- sapply(rendements, sd) * sqrt(252)
volatilite_df <- data.frame(
  action = tickers,
  volatilite_annuelle_pct = round(volatilite_annuelle * 100, 2)
)

## -------------------------------------------------------------
## 6. INDICATEURS DE PERFORMANCE
## -------------------------------------------------------------
# Rendement cumulé sur toute la période
rendement_cumule <- sapply(rendements, function(x) prod(1 + x) - 1)

# Rendement annualisé
n_annees <- as.numeric(difftime(max(index(rendements)),
                                 min(index(rendements)), units = "days")) / 365.25
rendement_annualise <- (1 + rendement_cumule)^(1 / n_annees) - 1

# Ratio de Sharpe (avec un taux sans risque supposé de 2%/an)
taux_sans_risque <- 0.02
ratio_sharpe <- (rendement_annualise - taux_sans_risque) / volatilite_annuelle

performance_df <- data.frame(
  action = tickers,
  rendement_cumule_pct = round(rendement_cumule * 100, 2),
  rendement_annualise_pct = round(rendement_annualise * 100, 2),
  volatilite_annuelle_pct = round(volatilite_annuelle * 100, 2),
  ratio_sharpe = round(ratio_sharpe, 2)
)

print(performance_df)

## -------------------------------------------------------------
## 7. VISUALISATIONS AVEC GGPLOT2
## -------------------------------------------------------------

## 7.1 Évolution des prix ajustés
graphique_prix <- ggplot(prix_df, aes(x = date, y = prix_ajuste, color = action)) +
  geom_line(linewidth = 0.8) +
  labs(title = "Évolution du prix ajusté des actions",
       x = "Date", y = "Prix ajusté (€)", color = "Action") +
  theme_minimal()

## 7.2 Rendement cumulé (indice de performance base 100)
prix_indexe <- prix_df %>%
  group_by(action) %>%
  mutate(indice = prix_ajuste / first(prix_ajuste) * 100)

graphique_performance <- ggplot(prix_indexe, aes(x = date, y = indice, color = action)) +
  geom_line(linewidth = 0.8) +
  labs(title = "Performance comparée (base 100 au début de la période)",
       x = "Date", y = "Indice de performance", color = "Action") +
  theme_minimal()

## 7.3 Distribution des rendements journaliers (analyse du risque)
graphique_distribution <- ggplot(rendements_df, aes(x = rendement, fill = action)) +
  geom_histogram(bins = 60, alpha = 0.6, position = "identity") +
  facet_wrap(~ action, scales = "free_y") +
  labs(title = "Distribution des rendements journaliers",
       x = "Rendement journalier", y = "Fréquence") +
  theme_minimal() +
  theme(legend.position = "none")

## 7.4 Comparaison de la volatilité annualisée (barres)
graphique_volatilite <- ggplot(volatilite_df, aes(x = action, y = volatilite_annuelle_pct, fill = action)) +
  geom_col() +
  labs(title = "Volatilité annualisée par action",
       x = "Action", y = "Volatilité annualisée (%)") +
  theme_minimal() +
  theme(legend.position = "none")

## Affichage des graphiques
print(graphique_prix)
print(graphique_performance)
print(graphique_distribution)
print(graphique_volatilite)

## Sauvegarde des graphiques en image (pour le rapport ou le GitHub)
ggsave("evolution_prix.png", graphique_prix, width = 8, height = 5)
ggsave("performance_comparee.png", graphique_performance, width = 8, height = 5)
ggsave("distribution_rendements.png", graphique_distribution, width = 8, height = 5)
ggsave("volatilite_annuelle.png", graphique_volatilite, width = 8, height = 5)

## -------------------------------------------------------------
## 8. INTERPRÉTATION ET REPORTING SYNTHÉTIQUE
## -------------------------------------------------------------
cat("\n===== SYNTHÈSE DE L'ANALYSE =====\n")

for (i in seq_along(tickers)) {
  cat(sprintf(
    "\n%s :\n  - Rendement cumulé sur la période : %.2f %%\n  - Rendement annualisé : %.2f %%\n  - Volatilité annualisée : %.2f %%\n  - Ratio de Sharpe : %.2f\n",
    performance_df$action[i],
    performance_df$rendement_cumule_pct[i],
    performance_df$rendement_annualise_pct[i],
    performance_df$volatilite_annuelle_pct[i],
    performance_df$ratio_sharpe[i]
  ))
}

# Exemple de lecture à adapter selon tes résultats réels :
# "L'action avec le ratio de Sharpe le plus élevé offre le meilleur couple
#  rendement/risque sur la période observée. Une volatilité annualisée
#  supérieure à 25-30% traduit un risque élevé, à mettre en regard du
#  rendement obtenu avant toute recommandation d'allocation."

## -------------------------------------------------------------
## 9. EXPORT DES RÉSULTATS (pour Excel ou le rapport)
## -------------------------------------------------------------
write.csv(performance_df, "synthese_performance.csv", row.names = FALSE)
