# find-peak-ytdl

YouTubeの動画の音量が大きいところとチャット数が多いところを数か所切り抜いてつなげる

```
.\run.ps1 <動画url>
```

## 環境構築

- ffmpeg
- yt-dlp
- uv

```
uv sync --no-dev
```

## docker

```
docker build -t find-peak-ytdl .
```

```
docker run --rm -v "$(pwd):/out" find-peak-ytdl <動画url>
```
