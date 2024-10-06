# find-audio-peak-ytdl

```
.\run.ps1 <動画url>
```

## 環境構築

- ffmpeg
- yt-dlp
- uv

```
uv sync
```

## docker

```
docker build -t find-peak-ytdl .
```

```
docker run --rm -v "$(pwd):/out" find-peak-ytdl <動画url>
```
