from typing import Iterable


def gen_command(peak_time_sec: Iterable[int], url: str) -> None:
    peak_time_span = ((t - 10, t + 10) for t in peak_time_sec)
    for a in peak_time_span:
        print(
            f'yt-dlp.exe -f bv+ba --download-sections "*{a[0]}-{a[1]}" "{url}" -o "%(id)s_{a[0]}.%(ext)s" &&'
        )
