# POI Pusher Skill

**Rôle:** Pousser les POIs approuvés d'un fichier scout vers la base de données Supabase.

## Quand utiliser ce skill

Utilise ce skill quand:
- Un fichier scout a été complété (scout → writer → checker)
- Tous les POIs sont marqués ✅ APPROUVÉ
- On veut insérer les données dans la BD de production

## Input

| Paramètre | Description | Exemple |
|-----------|-------------|---------|
| `filePath` | Chemin vers le fichier scout | `content/saint-lambert-quebec-canada/scout-histoire.md` |

## Processus

### 1. Valider le fichier

Avant de pousser, vérifier que:
- Le fichier existe
- Tous les POIs ont un verdict ✅ APPROUVÉ (pas de ⚠️ ou ❌)

```bash
# Compter les verdicts
grep -c "APPROUVÉ" {filePath}
grep -c "À RÉVISER\|REJETÉ" {filePath}  # Doit être 0
```

Si des POIs ne sont pas approuvés, **ARRÊTER** et lister les problèmes.

### 2. Extraire le city_id

Le dossier du fichier contient le slug de la ville: `{ville}-{province}-{pays}`

Exemple: `content/saint-lambert-quebec-canada/scout-histoire.md` → slug = `saint-lambert-quebec-canada`

Utiliser le script pour lookup le city_id:
```bash
cd ~/.openclaw/workspace/app-voyage
python3 skills/poi-pusher/scripts/push.py --lookup-city "saint-lambert-quebec-canada"
```

Si la ville n'existe pas, **ARRÊTER** et demander à l'utilisateur de la créer d'abord.

### 3. Exécuter le push

```bash
cd ~/.openclaw/workspace/app-voyage
python3 skills/poi-pusher/scripts/push.py --file "{filePath}"
```

Le script va:
1. Parser tous les blocs `### 🗄️ Données BD` (POI data)
2. Parser tous les blocs `### 🗄️ Scripts BD` (scripts trilingues)
3. Insérer chaque POI dans la table `points`
4. Insérer les 3 scripts (FR/EN/ES) dans la table `scripts`
5. Afficher un résumé des insertions

### 4. Vérifier les résultats

Le script affiche:
- Nombre de POIs insérés
- Nombre de scripts insérés
- Erreurs éventuelles

### 5. Mettre à jour le fichier scout

Après un push réussi, ajouter en haut du fichier:
```markdown
> ✅ **PUSHED TO DB:** {date} — {n} POIs, {n*3} scripts
```

### 6. Git push

```bash
cd ~/.openclaw/workspace/app-voyage
git add content/
git commit -m "pushed: {ville} {catégorie} — {n} POIs to Supabase" --author="Admin Rayv <admin@rayv.ca>"
git push origin main
```

## Supabase Config

```
Project URL: https://lfwnpyttyoefqvhfqajb.supabase.co
Service Role Key: (dans le script, ne pas exposer)
```

## Tables concernées

### points
```sql
INSERT INTO points (city_id, name, lat, lng, trigger_radius_m, type, categories, image_url, logistics, is_published)
```

### scripts
```sql
INSERT INTO scripts (point_id, language, content, persona)
-- voice_id reste NULL (résolu à la génération audio)
-- word_count est auto-calculé par Postgres
```

## Gestion des erreurs

| Erreur | Action |
|--------|--------|
| Ville non trouvée | Demander à l'utilisateur de créer la ville d'abord |
| POI déjà existe (même nom + ville) | Skip et log warning |
| Script déjà existe (même point + langue) | Update le content |
| JSON invalide | Afficher l'erreur et le POI concerné |

## Exemple d'output

```
🔍 Parsing: content/saint-lambert-quebec-canada/scout-histoire.md
📍 City: Saint-Lambert (19b90c91-43bd-48d3-8874-26d8949eee28)

Pushing POIs...
  ✅ Maison Marsil (abc123...)
  ✅ Église Saint-Lambert (def456...)
  ✅ Pont Victoria (ghi789...)
  ...

Pushing Scripts...
  ✅ Maison Marsil: fr, en, es
  ✅ Église Saint-Lambert: fr, en, es
  ...

📊 Summary:
  - POIs inserted: 13
  - Scripts inserted: 39
  - Errors: 0

✅ Push complete!
```
