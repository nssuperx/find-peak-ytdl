from typing import Iterable
import numpy as np
from scipy.io import wavfile
from scipy.signal import find_peaks

from misc import gen_command


def find_peak_time(point: int) -> Iterable[int]:
    rate, sound = wavfile.read("test.wav")
    sound_l_abs = np.abs(sound[:, 0])
    percentile_height = np.percentile(sound_l_abs, 99.999)
    peaks, _ = find_peaks(sound_l_abs, height=percentile_height, distance=rate * 60)

    # 大きい順で並び替えて時間順にする
    desc = np.argsort(sound_l_abs[peaks])[::-1]
    chronological = np.sort(peaks[desc][:point])
    return (int(i) for i in (chronological // rate))


def main():
    peak_time_sec = find_peak_time(5)
    gen_command(peak_time_sec, "")


if __name__ == "__main__":
    main()
