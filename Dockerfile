FROM debian:stable as build

WORKDIR /tmp

RUN apt-get update && apt-get install -y curl xz-utils git binutils
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/bin/
RUN curl -sSL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux -o /tmp/yt-dlp
RUN curl -sSL https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz -o /tmp/ffmpeg.tar.xz && \
    tar -xf /tmp/ffmpeg.tar.xz --strip-components 1
COPY pyproject.toml .
COPY uv.lock .
COPY main.py .
RUN uv sync --no-dev --extra build
RUN uv run pyinstaller main.py --onefile


FROM debian:stable-slim

COPY --from=build /tmp/yt-dlp /usr/bin
RUN chmod 755 /usr/bin/yt-dlp
COPY --from=build /tmp/ffmpeg /usr/bin
COPY --from=build /tmp/dist/main /find_peak
COPY run.sh .
RUN sed -i 's/uv run main.py/\.\/find_peak/g' run.sh
RUN chmod 755 /run.sh

RUN mkdir /out

ENTRYPOINT ["/run.sh"]
CMD ["url"]
