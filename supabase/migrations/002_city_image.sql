-- ============================================
-- App Voyage — Photo de ville
-- Migration: 002_city_image.sql
-- Date: 2026-07-03
-- ============================================

-- Photo affichée sur la carte de la ville (écran d'accueil).
-- Utiliser une image libre de droits (Wikimedia Commons, photo perso...)
-- et renseigner le crédit pour l'attribution.
ALTER TABLE cities ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE cities ADD COLUMN IF NOT EXISTS image_credit TEXT;

-- Exemple:
-- UPDATE cities SET
--   image_url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/.../1200px-....jpg',
--   image_credit = 'Photo: Nom Auteur, CC BY-SA 4.0, via Wikimedia Commons'
-- WHERE slug = 'saint-lambert-quebec-canada';
