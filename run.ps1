# 動画idを使ってファイルの読み込みなどをしたい
$pattern = "^.*(?:watch\?)(?:v=)?([a-zA-Z0-9=_-]+)$"
if ($Args[0] -match $pattern) {
    $id = $matches[1]
} else {
    $id = $Args[0]
}

function Clip-Video {
    param([string]$Filename)
    New-Item "${Filename}.txt" -type file -Force 
    Import-Csv .\${Filename}.csv -Encoding UTF8 | ForEach-Object {
        # -copytsオプション付けたら-c copyでconcatしてもずれなくなる
        ffmpeg -ss $($_.start) -to $($_.end) -i "${id}.mp4" -c copy -copyts "${id}_$($_.start).mp4"
        Add-Content -Path "${Filename}.txt" -Value "file '${id}_$($_.start).mp4'"
    }
    ffmpeg -safe 0 -f concat -i "${Filename}.txt" -c copy "out-${Filename}.mp4"
}

Push-Location $PSScriptRoot
yt-dlp -f bv[ext*=mp4]+ba[ext*=mp4] "$id" -o "%(id)s.%(ext)s" --write-sub --sub-lang live_chat --write-info-json
if (-not $?) {
    Write-Error "yt-dlp error"
    Pop-Location
    exit
}
# ffmpeg -i "$id.mp4" "$id.wav"

uv run --no-dev .\main.py $id

# Clip-Video -Filename ${id}-sound
Clip-Video -Filename ${id}-chat
# Clip-Video -Filename ${id}-heatmap

$shell = New-Object -ComObject Shell.Application
$trash = $shell.NameSpace(10)
Resolve-Path ${id}* | ForEach-Object {
    $trash.MoveHere($_.Path)
}

Pop-Location
