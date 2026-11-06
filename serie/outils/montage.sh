#!/usr/bin/env bash
# Montage automatique d'un épisode au format 9:16 (1080x1920).
# Usage : ./serie/outils/montage.sh ep01
# Entrées :
#   serie/03_assets/clips/ep01/*.mp4     clips numérotés (01.mp4, 02.mp4, ...)
#   serie/02_episodes/ep01.durees        (optionnel) durée en s de chaque plan, une par ligne
#   serie/03_assets/voix/ep01.mp3        (optionnel) voix off + dialogues
#   serie/03_assets/musique/ep01.mp3     (optionnel) musique, baissée sous la voix
#   serie/02_episodes/ep01.srt           (optionnel) sous-titres incrustés
# Sortie : serie/04_rendus/ep01.mp4
set -euo pipefail
EP="${1:?Usage: montage.sh epXX}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLIPS="$ROOT/03_assets/clips/$EP"
DUREES="$ROOT/02_episodes/$EP.durees"
VOIX="$ROOT/03_assets/voix/$EP.mp3"
MUSIQUE="$ROOT/03_assets/musique/$EP.mp3"
SRT="$ROOT/02_episodes/$EP.srt"
OUT="$ROOT/04_rendus/$EP.mp4"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

mapfile -t FILES < <(find "$CLIPS" -maxdepth 1 -type f \( -iname '*.mp4' -o -iname '*.mov' \) | sort -V)
[ "${#FILES[@]}" -gt 0 ] || { echo "Aucun clip dans $CLIPS"; exit 1; }
DUR=(); [ -f "$DUREES" ] && mapfile -t DUR < "$DUREES"

# 1. Normaliser chaque plan : 1080x1920, 30 i/s, coupé à sa durée, sans son
: > "$TMP/liste.txt"
for i in "${!FILES[@]}"; do
  d="${DUR[$i]:-}"; T=(); [ -n "$d" ] && T=(-t "$d")
  ffmpeg -v error -y -i "${FILES[$i]}" "${T[@]}" -an \
    -vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,fps=30,setsar=1,format=yuv420p" \
    -c:v libx264 -preset veryfast -crf 18 "$TMP/p$i.mp4"
  echo "file '$TMP/p$i.mp4'" >> "$TMP/liste.txt"
  echo "Plan $((i+1))/${#FILES[@]} : $(basename "${FILES[$i]}") ${d:+($d s)}"
done
ffmpeg -v error -y -f concat -safe 0 -i "$TMP/liste.txt" -c copy "$TMP/video.mp4"

# 2. Audio : voix + musique (baissée automatiquement quand la voix parle)
IN=(-i "$TMP/video.mp4"); FC=""; MAP=(-map 0:v)
if [ -f "$VOIX" ] && [ -f "$MUSIQUE" ]; then
  IN+=(-i "$VOIX" -stream_loop -1 -i "$MUSIQUE")
  FC="[1:a]asplit[v1][v2];[2:a]volume=0.35[m];[m][v2]sidechaincompress=threshold=0.05:ratio=8[md];[v1][md]amix=inputs=2:duration=first:normalize=0,apad[a]"
  MAP+=(-map "[a]")
elif [ -f "$VOIX" ]; then IN+=(-i "$VOIX"); FC="[1:a]apad[a]"; MAP+=(-map "[a]")
elif [ -f "$MUSIQUE" ]; then IN+=(-stream_loop -1 -i "$MUSIQUE"); FC="[1:a]volume=0.6,apad[a]"; MAP+=(-map "[a]")
fi

# 3. Sous-titres + fondu final
VF="fade=t=out:st=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$TMP/video.mp4" | awk '{print ($1>1)?$1-1:0}'):d=1"
if [ -f "$SRT" ]; then
  cp "$SRT" "$TMP/sub.srt"
  VF="subtitles=$TMP/sub.srt:force_style='FontName=DejaVu Sans,FontSize=13,Bold=1,Outline=2,MarginV=70',$VF"
fi
ARGS=("${IN[@]}")
[ -n "$FC" ] && ARGS+=(-filter_complex "$FC")
ffmpeg -v error -y "${ARGS[@]}" "${MAP[@]}" -vf "$VF" -c:v libx264 -preset medium -crf 20 \
  -c:a aac -b:a 192k -shortest -movflags +faststart "$OUT"
echo "Épisode prêt : $OUT"
