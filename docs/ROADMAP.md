# 🗺️ ROADMAP — App Voyage

> **Statut (2026-07-03):** Phase 0 quasi complétée — le contenu (81 POIs, bien au-delà
> des 15-20 visés) et l'app (carte, audio, GPS auto-trigger) sont livrés. Il reste le
> **test terrain** (Sprint 4) pour valider le geofencing, puis l'**offline** (Sprint 5).
> Voir [SPRINTS.md](./SPRINTS.md) pour le détail et [CODE-REVIEW.md](./CODE-REVIEW.md)
> pour les correctifs à faire avant le test terrain.

## Philosophie

**POI-first.** On collecte des points d'intérêt autonomes, on valide le GPS/geofencing, et l'utilisateur explore librement. Les tours curatés viennent après, quand on a assez de data et de contenu.

**MVP = Minimum Viable Product** — La version la plus simple qui prouve que le concept fonctionne.  
On ne build pas tout. On build juste assez pour valider avec de vrais utilisateurs.

---

## 🥚 Phase 0: Prototype — Collecte POIs + GPS (2-3 semaines)

**Objectif:** Collecter tous les POIs d'une ville test (Saint-Lambert) et valider le déclenchement GPS par proximité.

- [ ] Collecter 15-20 POIs standalone pour Saint-Lambert
- [ ] Scripts audio auto-contenus pour chaque POI (pas de transitions, pas d'ordre)
- [ ] App barebones: carte + POIs affichés + lecture audio par proximité GPS
- [ ] Catégoriser chaque POI (patrimoine, religieux, infrastructure, nature, etc.)
- [ ] Test en personne à Saint-Lambert — se promener librement
- [ ] Valider: est-ce que le geofencing trigge au bon moment?
- [ ] Feedback → itérer sur les rayons de trigger

**Livrable:** APK/TestFlight pour test interne  
**Pas inclus:** Offline, sync, multi-langue, joli UI, paiements

**Métriques de succès:**
- 5 tests terrain complétés
- Taux de trigger GPS correct > 80%
- Chaque POI fonctionne de façon indépendante

---

## 🐣 Phase 1: MVP — Tous les POIs d'une ville + Auto-trigger + Offline (4-6 semaines)

**Objectif:** Version utilisable par des beta testers. Une ville complète avec tous ses POIs, téléchargeable offline, déclenchement automatique fiable.

### Features MVP
- [ ] 1 ville complète: Saint-Lambert (15-20 POIs)
- [ ] 2e ville en cours: Montréal — Vieux-Montréal (20-30 POIs)
- [ ] Mode découverte: se promener, l'audio se déclenche automatiquement
- [ ] Filtrage POIs par catégorie
- [ ] Mode piéton (défaut)
- [ ] Français (EN en préparation)
- [ ] Téléchargement offline de tous les POIs d'une ville
- [ ] POIs visités / non-visités (suivi de progression)
- [ ] UI propre mais simple
- [ ] Onboarding basique ("l'app déclenche l'audio quand tu t'approches d'un POI")

### Pas inclus (reporté)
- ❌ Sync multi-appareils (V2)
- ❌ Tours curatés (V2)
- ❌ Mode vélo/auto
- ❌ Paiements
- ❌ Autres villes que Saint-Lambert + Montréal

**Livrable:** Beta publique (TestFlight + Google Play Beta)

**Métriques de succès:**
- 50 beta testers actifs
- 70%+ des POIs écoutés par les testeurs
- Taux de complétion d'une ville > 30%

---

## 🐥 Phase 2: V1.0 — Tours curatés, Paiements, Sync (6-8 semaines après MVP)

**Objectif:** Première version publique avec monétisation et features premium.

### Nouvelles features
- [ ] **Tours curatés** (V2 du modèle): collections thématiques de POIs avec ordre + transitions
- [ ] Sync multi-appareils (mode Host — notre killer feature)
- [ ] Mode vélo
- [ ] 50+ POIs Montréal (plusieurs quartiers)
- [ ] Système de favoris (POIs sauvegardés)
- [ ] Freemium: X POIs gratuits par ville, pack ville payant
- [ ] Acheter un tour curaté (7.99$ CAD) ou un pack ville (14.99$ CAD)
- [ ] Intégration paiement (in-app purchase)
- [ ] Verrouillage serveur du contenu: comptes + table d'achats + RLS sur
      `points`/`scripts` (aujourd'hui la base est en lecture publique).
      Note: les sessions « Écouter ensemble » sont déjà prêtes — le contenu
      est relayé par l'hôte via Realtime, les invités n'ont pas besoin
      d'accès à la ville (voir ARCHITECTURE.md, sync groupe).
- [ ] Anglais disponible
- [ ] Analytics (comprendre l'usage: quels POIs populaires, quels ignorés)

**Livrable:** App Store + Google Play (public)

**Métriques de succès:**
- 500 downloads
- 4.0+ stars
- Premiers revenus (achats in-app)
- Taux de conversion free → paid > 5%

---

## 🐓 Phase 3: V2.0 — Growth (3-6 mois post-launch)

### Features envisagées
- [ ] Mode auto (narration continue, type road trip)
- [ ] Plus de villes (Québec, Ottawa, Paris, etc.)
- [ ] Espagnol
- [ ] POIs personnalisés (AI qui suggère selon tes intérêts / catégories favorites)
- [ ] Social: partager ses découvertes, POIs favoris
- [ ] Reviews/ratings des POIs
- [ ] B2B: dashboard pour offices de tourisme (uploader leurs propres POIs)
- [ ] Contribution communautaire: locaux suggèrent des POIs

---

## 📊 Métriques de succès par phase

| Phase | Métrique cible |
|-------|---------------|
| Phase 0 (Proto) | 5 tests terrain, trigger GPS > 80% fiable |
| Phase 1 (MVP) | 50 beta testers actifs, POIs écoutés > 70% |
| Phase 2 (V1.0) | 500 downloads, 4.0+ stars, premiers revenus |
| Phase 3 (V2.0) | 5000 downloads, expansion géographique |

---

## Timeline estimée

```
Fév 2026     Mar 2026     Avr 2026     Mai 2026     Juin 2026
    |------------|------------|------------|------------|
    [Phase 0    ][--Phase 1--][---Phase 2---]  [Phase 3 planning]
    Collecte POIs  MVP: ville   V1: tours,
    + GPS proto    complète     paiements,
                   + offline    sync groupe
```

*Les dates sont indicatives. On ajuste selon la vélocité réelle.*

---

*Dernière mise à jour: 2026-02-23*
