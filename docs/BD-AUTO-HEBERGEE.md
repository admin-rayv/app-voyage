# BD auto-hébergée (voyagedb.bjpr.ca)

Créée le 2026-11-21 pour remplacer le projet supabase.com `lfwnpyttyoefqvhfqajb`.

## Où
- **VPS :** `cee-staging` (149.56.96.76, OVH), partagé avec le staging du Carnet d'Entretien Électronique.
- **Dossier :** `/srv/supabase/app-voyage` (projet Docker **`voyage`**, conteneurs `voyage-*`).
- **Adresse publique :** https://voyagedb.bjpr.ca (Caddy → `localhost:8100`, Kong).
- **Tableau de bord (Studio) :** https://voyagedb.bjpr.ca, utilisateur `voyage` (mot de passe dans le `.env`).

## Services
Supabase allégée : `db`, `kong`, `auth`, `rest`, `realtime`, `storage`, `meta`, `studio`.
Retirés par rapport à la pile complète : analytics, vector, edge functions, pooler, imgproxy.

## Secrets
- Sur le VPS : `/srv/supabase/app-voyage/.env` (root, 600).
- Copie locale : `~/.config/app-voyage/voyagedb.env` (600).
- **Ne jamais mettre la clé `SERVICE_ROLE_KEY` dans ce dépôt (public).** La clé `ANON_KEY` peut aller dans l'app.

## Commandes
```bash
ssh cee-staging
cd /srv/supabase/app-voyage
sudo docker compose -p voyage ps          # toujours -p voyage : le CEE utilise le projet « supabase »
sudo docker exec -it voyage-supabase-db psql -U postgres
```
Appliquer une migration :
```bash
ssh cee-staging "sudo docker exec -i voyage-supabase-db psql -U postgres -d postgres" < supabase/migrations/XYZ.sql
```

## Sauvegardes
- `/usr/local/bin/backup-app-voyage.sh`, tous les jours à 3 h 30 (`/etc/cron.d/backup-app-voyage`).
- Sortie : `/srv/backups/app-voyage/` (dump SQL `public` + `storage`, archive des fichiers), 14 jours gardés.
- ⚠️ Les sauvegardes restent sur le même VPS : en copier ailleurs régulièrement.

## Migration initiale (2026-11-21)
- Schéma : `supabase/migrations/001_initial_schema.sql` (002 n'était pas appliquée sur supabase.com, donc pas appliquée ici non plus).
- Données : cities 2, points 135, scripts 405 (tours, tour_points, voice_config vides). Contenu comparé : identique.
- Fichiers : bucket public `releases` (app-voyage-v0.2.0.apk, SHA-256 identique).
- Temps réel (diffusion + présence des sessions de groupe) testé.
- Mémoire : 4 Go de swap ajoutés au VPS (`/swapfile`).
