import sys
from typing import Iterable
import numpy as np
from scipy.io import wavfile
from scipy.signal import find_peaks


def find_peak_time(filename: str, point: int) -> Iterable[int]:
    rate, sound = wavfile.read(f"{filename}.wav")
    sound_l_abs = np.abs(sound[:, 0])
    percentile_height = np.percentile(sound_l_abs, 99.999)
    peaks, _ = find_peaks(sound_l_abs, height=percentile_height, distance=rate * 60)

    # 大きい順で並び替えて時間順にする
    desc = np.argsort(sound_l_abs[peaks])[::-1]
    chronological = np.sort(peaks[desc][:point])
    return (int(i) for i in (chronological // rate))


def gen_cut_info(peak_time_sec: Iterable[int], id: str) -> None:
    peak_time_span = ((t - 10, t + 5) for t in peak_time_sec)
    time_csv = open(f"{id}.csv", "w", encoding="utf-8")
    time_csv.write("start,end\n")
    for start, end in peak_time_span:
        time_csv.write(f"{start},{end}\n")
    time_csv.close()


def main():
    id = sys.argv[1]
    peak_time_sec = find_peak_time(id, 5)
    gen_cut_info(peak_time_sec, id)


if __name__ == "__main__":
    main()
