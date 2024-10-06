# 動画idを使ってファイルの読み込みなどをしたい
$pattern = "^.*(?:watch\?)(?:v=)?([a-zA-Z0-9=_-]+)$"
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

Import-Csv .\${id}.csv -Encoding UTF8 | ForEach-Object {
    # エンコードしないとキーフレームの関係でずれる
    ffmpeg -ss $($_.start) -to $($_.end) -i "${id}.mp4" -vcodec libx264 -crf 22 -acodec aac -ab 128k "${id}_$($_.start).mp4"
}
ffmpeg -safe 0 -f concat -i "${id}.txt" -c copy "out-${id}.mp4"

$shell = New-Object -ComObject Shell.Application
$trash = $shell.NameSpace(10)
Resolve-Path ${id}* | ForEach-Object {
    $trash.MoveHere($_.Path)
}

Pop-Location
