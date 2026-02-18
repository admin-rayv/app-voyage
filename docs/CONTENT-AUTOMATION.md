# 🤖 AUTOMATISATION DU CONTENU — App Voyage

> Explorer les options pour automatiser la création de contenu avec révision humaine

---

## Vision

**Objectif:** L'IA génère le contenu, les humains révisent et approuvent.

```
┌─────────────────────────────────────────────────────────────────┐
│                    PIPELINE DE CONTENU                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   🤖 AI GÉNÈRE          →    👀 HUMAIN RÉVISE    →    ✅ PUBLIÉ │
│                                                                 │
│   • Recherche POIs           • Valide les infos      • En prod  │
│   • Rédige scripts           • Corrige le ton        • Visible  │
│   • Traduit                  • Approuve              • Jouable  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Étapes du processus

### 1. Recherche de POIs

| Approche | Description | Effort humain | Qualité |
|----------|-------------|---------------|---------|
| **100% Manuel** | Pierre recherche chaque POI | 🔴 Élevé | ⭐⭐⭐⭐⭐ |
| **AI + Révision** | AI trouve les POIs, humain valide | 🟢 Faible | ⭐⭐⭐⭐ |
| **100% AI** | AI trouve et insère automatiquement | 🟢 Très faible | ⭐⭐⭐ |

#### Option recommandée: AI + Révision

**Comment ça marche:**
1. L'AI recherche sur Google/Wikipedia/sites locaux
2. L'AI génère une liste de POIs candidats avec:
   - Nom du lieu
   - Coordonnées GPS (via Google Maps API ou geocoding)
   - Pourquoi c'est intéressant (2-3 lignes)
   - Sources
3. L'humain révise dans un tableau/Trello
4. L'humain approuve → POI inséré dans la DB

**Sources de données pour l'AI:**
- Google Places API
- Wikipedia (articles locaux)
- Sites des villes (ex: ville.sainte-julie.qc.ca)
- TripAdvisor / Google Reviews
- OpenStreetMap (POIs tagués)
- Articles de journaux locaux

**Output format suggéré:**
```json
{
  "poi_candidates": [
    {
      "name": "Église Sainte-Julie",
      "lat": 45.5847,
      "lng": -73.3361,
      "type": "building",
      "why_interesting": "Construite en 1852, c'est le plus vieux bâtiment de la ville. Le clocher original a été frappé par la foudre en 1923.",
      "sources": ["ville.sainte-julie.qc.ca/patrimoine", "wikipedia"],
      "confidence": "high",
      "status": "pending_review"
    }
  ]
}
```

---

### 2. Génération des scripts audio

| Approche | Description | Effort humain | Qualité |
|----------|-------------|---------------|---------|
| **100% Manuel** | Pierre écrit chaque script | 🔴 Élevé | ⭐⭐⭐⭐⭐ |
| **AI + Révision** | AI rédige, humain peaufine | 🟡 Moyen | ⭐⭐⭐⭐ |
| **AI + Guidelines stricts** | AI rédige avec prompts détaillés | 🟢 Faible | ⭐⭐⭐⭐ |

#### Option recommandée: AI + Guidelines stricts + Révision légère

**Prompt template pour génération de scripts:**

```markdown
Tu es un guide touristique passionné qui raconte l'histoire de {ville}.

TON STYLE:
- Tu tutoies l'auditeur
- Tu es enthousiaste mais pas surexcité  
- Tu racontes des anecdotes, pas des dates sèches
- Tu poses des questions rhétoriques ("Tu vois ce bâtiment?")
- Tu donnes des conseils pratiques
- Tu fais des références à ce que l'auditeur peut VOIR

CONTRAINTES:
- Maximum 150-180 mots (60-90 secondes parlé)
- Commence par capter l'attention (hook)
- Termine par une transition vers le prochain point
- Inclus au moins une anecdote surprenante
- Mentionne un détail visuel à observer

INFORMATIONS SUR LE POI:
- Nom: {poi_name}
- Type: {poi_type}
- Histoire: {poi_history}
- Anecdotes connues: {poi_anecdotes}
- Ce qu'on peut voir: {poi_visual_elements}

Génère le script audio en français québécois.
```

**Workflow:**
1. AI reçoit les infos du POI (de l'étape 1)
2. AI génère le script avec le prompt template
3. Script ajouté en status "draft" dans la DB
4. Humain révise dans une interface (ou Trello)
5. Humain approuve → status "approved"

---

### 3. Traduction

| Approche | Description | Effort humain | Qualité |
|----------|-------------|---------------|---------|
| **Traducteur pro** | Humain traduit tout | 🔴 Très élevé | ⭐⭐⭐⭐⭐ |
| **AI + Révision** | Claude/GPT traduit, humain révise | 🟡 Moyen | ⭐⭐⭐⭐ |
| **AI seul** | AI traduit automatiquement | 🟢 Très faible | ⭐⭐⭐ |

#### Option recommandée: AI + Révision pour langues prioritaires

**Stratégie par langue:**
- **Français → Anglais:** AI + révision légère (qualité AI excellente)
- **Français → Espagnol:** AI + révision par hispanophone
- **Autres langues:** AI seul (acceptable pour MVP)

**Prompt template pour traduction:**

```markdown
Traduis ce script de guide audio du français vers l'anglais.

RÈGLES:
- Garde le même ton conversationnel et enthousiaste
- Adapte les expressions idiomatiques (ne traduis pas littéralement)
- Garde le tutoiement → "you" informel
- Les noms propres restent en français
- Adapte les références culturelles si nécessaire

SCRIPT ORIGINAL:
{script_fr}

Traduis en anglais naturel, comme si un guide anglophone racontait la même histoire.
```

---

### 4. Génération audio (TTS)

| Approche | Description | Effort humain | Coût |
|----------|-------------|---------------|------|
| **Voix humaine** | Acteur enregistre | 🔴 Très élevé | $$$$ |
| **ElevenLabs** | TTS haute qualité | 🟢 Faible | $$ |
| **Google TTS** | TTS standard | 🟢 Très faible | $ |

#### Option recommandée: ElevenLabs avec cache

**Déjà planifié dans l'architecture:**
- Scripts stockés en texte dans Supabase
- Audio généré à la demande via Edge Function
- Cache local sur l'appareil

**Automatisation possible:**
- Pré-générer les audios populaires en batch
- Régénérer automatiquement si script modifié

---

## Options d'automatisation

### Option A: Pipeline manuel assisté par AI

```
┌─────────────────────────────────────────────────────────────────┐
│  1. Humain demande à l'AI: "Trouve 10 POIs à Sainte-Julie"      │
│                           ↓                                      │
│  2. AI retourne une liste dans le chat                          │
│                           ↓                                      │
│  3. Humain copie/colle dans Trello pour révision                │
│                           ↓                                      │
│  4. Humain approuve → copie dans Supabase manuellement          │
└─────────────────────────────────────────────────────────────────┘
```

**Avantages:** Simple, contrôle total
**Inconvénients:** Beaucoup de copier/coller

---

### Option B: Interface de révision dédiée

```
┌─────────────────────────────────────────────────────────────────┐
│  1. Script/cron lance la génération AI périodiquement           │
│                           ↓                                      │
│  2. Contenu généré → inséré en status "pending" dans DB         │
│                           ↓                                      │
│  3. Interface web affiche le contenu à réviser                  │
│     [Approuver] [Modifier] [Rejeter]                            │
│                           ↓                                      │
│  4. Humain clique Approuver → status "approved"                 │
└─────────────────────────────────────────────────────────────────┘
```

**Avantages:** Workflow clair, historique, plusieurs réviseurs
**Inconvénients:** Nécessite de builder une interface

---

### Option C: Trello comme interface de révision

```
┌─────────────────────────────────────────────────────────────────┐
│  TRELLO BOARD: "Contenu App Voyage"                             │
│                                                                  │
│  [À réviser]     [En révision]    [Approuvé]    [En prod]       │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐   ┌──────────┐   │
│  │ POI #12  │    │ POI #08  │    │ POI #05  │   │ POI #01  │   │
│  │ Script   │    │ Script   │    │ Script   │   │ Script   │   │
│  │ 🤖 Auto  │    │ 👀 Pierre│    │ ✅ OK    │   │ 🚀 Live  │   │
│  └──────────┘    └──────────┘    └──────────┘   └──────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

AI génère → Carte créée dans "À réviser"
Humain déplace vers "Approuvé"
Script sync Trello → Supabase
```

**Avantages:** 
- Pas de nouvelle interface à builder
- Trello déjà utilisé pour le projet
- Mobile-friendly
- Notifications intégrées

**Inconvénients:**
- Nécessite un script de sync Trello ↔ Supabase
- Limites de l'API Trello (rate limits)

---

### Option D: GitHub Issues comme révision

```
┌─────────────────────────────────────────────────────────────────┐
│  GITHUB REPO: app-voyage/content                                 │
│                                                                  │
│  Issues:                                                         │
│  #12 [POI] Église Sainte-Julie          [needs-review]          │
│  #11 [Script] Parc municipal            [approved]              │
│  #10 [POI] Maison ancestrale            [in-progress]           │
│                                                                  │
│  AI crée une Issue avec le contenu                              │
│  Humain review et ajoute label "approved"                       │
│  GitHub Action sync vers Supabase                               │
└─────────────────────────────────────────────────────────────────┘
```

**Avantages:**
- Versioning du contenu
- Discussions/commentaires
- GitHub Actions pour automation
- Gratuit

**Inconvénients:**
- Moins user-friendly que Trello
- Pierre doit connaître GitHub

---

## Recommandation

### Pour le MVP (maintenant)

**Option C: Trello comme interface de révision**

1. **Créer un board Trello "Contenu Sainte-Julie"**
   - Liste: À générer
   - Liste: À réviser  
   - Liste: Approuvé
   - Liste: En production

2. **Workflow:**
   - Je (Molty) génère le contenu et crée les cartes
   - Vous révisez et déplacez vers "Approuvé"
   - Je sync vers Supabase

3. **Format des cartes:**
   ```
   Titre: [POI] Église Sainte-Julie
   
   Description:
   📍 Coordonnées: 45.5847, -73.3361
   🏷️ Type: building
   
   📝 Script FR:
   [Le script complet ici]
   
   📚 Sources:
   - ville.sainte-julie.qc.ca
   - Wikipedia
   
   ✏️ Notes de révision:
   [Vous ajoutez vos commentaires ici]
   ```

### Pour V2 (plus tard)

**Option B: Interface de révision dédiée**

- Dashboard web simple
- Liste des contenus à réviser
- Preview audio (TTS)
- Boutons Approuver/Modifier/Rejeter
- Sync automatique vers Supabase

---

## Prochaines étapes

1. **Créer le board Trello "Contenu Sainte-Julie"**
2. **Je génère les 8-10 POIs candidats**
3. **Vous révisez**
4. **Je génère les scripts pour les POIs approuvés**
5. **Vous révisez les scripts**
6. **Je sync vers Supabase**

---

## Estimation des coûts AI

| Tâche | Tokens/unité | Coût Claude | Pour 10 POIs |
|-------|--------------|-------------|--------------|
| Recherche POI | ~2000 | ~$0.06 | $0.60 |
| Script FR | ~1500 | ~$0.05 | $0.50 |
| Traduction EN | ~1000 | ~$0.03 | $0.30 |
| **Total par POI** | | | **~$0.14** |

**Pour Sainte-Julie (10 POIs):** ~$1.40 en tokens AI
**Pour Montréal (50 POIs):** ~$7.00 en tokens AI

*Coûts négligeables comparé au temps humain économisé.*

---

## Questions ouvertes

1. **Qui révise?** Pierre seul? Vous deux? 
2. **Niveau de révision?** Juste valider ou réécrire si nécessaire?
3. **Fréquence?** Batch (tout d'un coup) ou graduel (quelques POIs par jour)?
4. **Interface préférée?** Trello? GitHub? Autre?

---

*Document créé le 2026-02-18*
