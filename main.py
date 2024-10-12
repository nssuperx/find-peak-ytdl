import sys
from typing import Iterable
import json
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


def find_peak_live_chat(filename: str, point: int) -> Iterable[int]:
    with open(f"{filename}.live_chat.json", encoding="utf-8") as f:
        chat_jsons = (json.loads(line) for line in f)
        timestamps = [
            t.get("replayChatItemAction", {}).get("videoOffsetTimeMsec", 0) for t in chat_jsons
        ]
    timestamps = np.array(timestamps, dtype=np.int32)
    # 0は配信開始前だから抜く
    timestamps = timestamps[timestamps > 0]
    # 秒にする
    timestamps = timestamps / 1000
    # 上記のでfloatになるからintにする
    timestamps = timestamps.astype(np.int32)

    # 1秒ごとのチャット数をカウントしてピーク出す
    counts = np.zeros(timestamps[-1], dtype=np.int32)
    np.add.at(counts, timestamps - 1, 1)
    peaks, _ = find_peaks(counts, distance=60)

    # 大きい順で並び替えて時間順にする
    desc = np.argsort(counts[peaks])[::-1]
    chronological = np.sort(peaks[desc][:point])
    return (int(i) for i in chronological)


def gen_cut_info(
    peak_time_sec: Iterable[int], id: str, postfix: str = "", before: int = 10, after: int = 5
) -> None:
    peak_time_span = ((t - before, t + after) for t in peak_time_sec)
    time_csv = open(f"{id}{postfix}.csv", "w", encoding="utf-8")
    time_csv.write("start,end\n")
    for start, end in peak_time_span:
        time_csv.write(f"{start},{end}\n")
    time_csv.close()


def main():
    id = sys.argv[1]
    peak_time_sec = find_peak_time(id, 5)
    gen_cut_info(peak_time_sec, id)
    peak_time_sec_chat = find_peak_live_chat(id, 5)
    gen_cut_info(peak_time_sec_chat, id, "-chat", 20, 5)


if __name__ == "__main__":
    main()
