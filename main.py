import sys
import yt_find_peak as yfp
import yt_find_peak.util as yfpu


def main():
    id = sys.argv[1]
    # peak_sound = yfp.find_peak_sound(id, 5)
    # yfpu.gen_concat_csv(sorted(peak_sound), f"{id}-sound")
    peak_chat = yfp.find_peak_live_chat(id, 5)
    yfpu.gen_concat_csv(sorted(peak_chat), f"{id}-chat", 20, 5)
    # peak_heatmap = yfp.find_peak_heatmap(id, 5)
    # yfpu.gen_concat_csv(sorted(peak_heatmap), f"{id}-heatmap")


if __name__ == "__main__":
    main()
