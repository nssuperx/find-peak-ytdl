#!/bin/bash

pattern='^.*watch\?v=([a-zA-Z0-9=_-]+)$'
if [[ $1 =~ $pattern ]]; then
    id=${BASH_REMATCH[1]}
else
    id=$1
fi

if ! yt-dlp -f 'bv[ext*=mp4]+ba[ext*=mp4]' "$id" -o '%(id)s.%(ext)s' --write-sub --sub-lang live_chat --write-info-json; then
    echo "yt-dlp error" >&2
    exit 1
fi

ffmpeg -i "$id.mp4" "$id.wav"

uv run main.py $id

while IFS=, read -r start end; do
    # エンコードしないとキーフレームの関係でずれる
    # 最後の </dev/null がないと1回しか実行されない
    ffmpeg -ss $start -to $end -i "${id}.mp4" -vcodec libx264 -crf 22 -acodec aac -ab 128k "${id}_${start}.mp4" </dev/null
    echo "file '${id}_${start}.mp4'" >> ${id}.txt
done < <(tail -n +2 ${id}.csv)
ffmpeg -safe 0 -f concat -i ${id}.txt -c copy "out-${id}.mp4"

while IFS=, read -r start end; do
    ffmpeg -ss $start -to $end -i "${id}.mp4" -vcodec libx264 -crf 22 -acodec aac -ab 128k "${id}_${start}.mp4" </dev/null
    echo "file '${id}_${start}.mp4'" >> ${id}-chat.txt
done < <(tail -n +2 ${id}-chat.csv)
ffmpeg -safe 0 -f concat -i ${id}-chat.txt -c copy "out-chat-${id}.mp4"

# コンテナを使わないなら不要
cp out-${id}.mp4 /out/
cp out-chat-${id}.mp4 /out/
