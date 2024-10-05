# 動画idを使ってファイルの読み込みなどをしたい
$pattern = "^.*(?:watch\?)(?:v=)?([a-zA-Z0-9-=_]+)$"
if ($Args[0] -match $pattern) {
    $id = $matches[1]
} else {
    $id = $Args[0]
}

Push-Location $PSScriptRoot

yt-dlp -f bv[ext*=mp4]+ba[ext*=mp4] "$id" -o "%(id)s.%(ext)s"

if (-not $?) {
    Write-Error "yt-dlp error"
    Pop-Location
    exit
}

ffmpeg -i "$id.mp4" "$id.wav"

uv run main.py $id

$cutTimes = Import-Csv .\time.csv -Encoding UTF8 | ForEach-Object {
    ffmpeg -ss $($_.start) -to $($_.end) -i "${id}.mp4" -c copy "${id}_$($_.start).mp4"
}

ffmpeg -safe 0 -f concat -i merge.txt -c copy "$id-out.mp4"

Pop-Location
