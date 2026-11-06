# Série « Fruit enquêteur privé » — Kit de production

Format : **vertical 9:16 (1080×1920)**, épisodes de **1 min 30 à 2 min**, publication TikTok / Reels / Shorts.

## 1. Analyse de la vidéo de référence (108 s)

| Élément | Constat | Ce qu'on reprend |
|---|---|---|
| Format | 576×1024, 30 i/s, 1 min 48 | Même durée, mais export en 1080×1920 |
| Style | Anime 3D « film d'animation » : peau lisse, lumière dorée de fin d'après-midi, profondeur de champ | Même famille de rendu, avec nos propres personnages |
| Concept | Lycéens « humanisés » à partir de fruits (pomme = cheveux blancs + queue de pomme, fraise = barrette fraise, peau verte = kiwi/citron vert) | Chaque personnage = un fruit reconnaissable par 1 ou 2 détails |
| Rythme | ~30 plans, soit un plan toutes les **3 à 4 s** | Prévoir 25 à 35 plans par épisode |
| Narration | Voix off + dialogues, pauses courtes (0,5 à 0,9 s) entre les répliques | Voix off du héros, dialogues courts |
| Structure | Mise en place en classe → tension (rival, téléphone volé) → sortie des cours → rue au coucher du soleil → **couteau = cliffhanger** | Accroche à 3 s, tension au milieu, cliffhanger final systématique |
| Plans | Gros plans visages (réactions), plans d'ensemble des décors, inserts (main + objet) | Règle « 1 visage, 1 décor, 1 insert » répétée |

> Note : je n'ai pas pu transcrire l'audio automatiquement (le modèle de transcription n'est pas téléchargeable depuis cet environnement). L'analyse audio repose sur le rythme des silences.

## 2. Ce que Claude peut faire / ce qu'il faut faire sur des sites

**Claude peut le faire directement :**
- la bible de la série (personnages, univers, style) → `01_bible/`
- les scénarios, découpages plan par plan et **prompts image/vidéo prêts à copier** → `02_episodes/`
- les sous-titres `.srt`
- le **montage final automatique** (assemblage des clips, voix, musique, sous-titres, format 9:16) → `outils/montage.sh`

**À faire sur des sites spécialisés** (Claude n'a pas de générateur d'images, de vidéo ni de voix ici) :

| Étape | Outils recommandés | Rôle |
|---|---|---|
| Fiches personnages (images) | **Midjourney** (option `--cref` pour garder le même visage), **Leonardo.ai**, **Ideogram** | Créer 1 image de référence par personnage, à réutiliser partout |
| Images des plans | Les mêmes, avec l'image de référence du personnage | 1 image par plan |
| Animation image → vidéo | **Kling AI** (le meilleur rapport qualité/prix pour ce style), **Hailuo / MiniMax**, **Runway Gen-4**, **Google Veo 3** (génère aussi le son) | Clips de 5 s par plan |
| Voix | **ElevenLabs** (voix françaises, une voix fixe par personnage) | Voix off + dialogues |
| Musique | **Suno** ou **Udio** (instrumental), ou la bibliothèque de CapCut | Ambiance |
| Montage manuel (option) | **CapCut** (sous-titres auto, transitions TikTok) | Si on ne passe pas par `montage.sh` |

Coût indicatif pour un épisode : ~30 images + ~30 clips de 5 s, soit environ 10 à 25 € d'abonnements par mois pour une série régulière (Midjourney Basic + Kling Standard + ElevenLabs Starter).

## 3. Chaîne de production d'un épisode

1. Lire `02_episodes/epXX.md` (scénario + découpage + prompts).
2. Générer les images de chaque plan → les ranger dans `03_assets/clips/epXX/`.
3. Animer chaque image (Kling/Hailuo) → `03_assets/clips/epXX/01.mp4`, `02.mp4`, … (dans l'ordre).
4. Générer la voix (ElevenLabs) → `03_assets/voix/epXX.mp3`.
5. Musique → `03_assets/musique/epXX.mp3`.
6. Lancer le montage :
   ```bash
   ./serie/outils/montage.sh ep01
   ```
   → résultat dans `04_rendus/ep01.mp4`.

## 4. Arborescence

```
serie/
├── 01_bible/          univers, personnages, style visuel, prompt de base
├── 02_episodes/       scénarios + découpages + prompts + sous-titres
├── 03_assets/
│   ├── personnages/   images de référence des personnages
│   ├── decors/        images de référence des lieux
│   ├── clips/epXX/    clips vidéo animés, numérotés dans l'ordre
│   ├── voix/          epXX.mp3
│   └── musique/       epXX.mp3
├── 04_rendus/         épisodes finis (.mp4)
└── outils/            montage.sh
```

Pour Google Drive : créer un dossier « Fruit enquêteur privé » et y recopier exactement la même arborescence (ou synchroniser ce dossier avec Google Drive pour ordinateur).
