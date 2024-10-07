FROM debian:stable as build

WORKDIR /tmp

RUN apt-get update && apt-get install -y curl xz-utils
RUN curl -sSL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux -o /tmp/yt-dlp

RUN curl -sSL https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz -o /tmp/ffmpeg.tar.xz && \
    tar -xf /tmp/ffmpeg.tar.xz --strip-components 1


FROM debian:stable-slim

COPY --from=build /tmp/yt-dlp /usr/local/bin
RUN chmod 755 /usr/local/bin/yt-dlp
COPY --from=build /tmp/ffmpeg /usr/local/bin
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv
COPY main.py .
COPY run.sh .
COPY pyproject.toml .
COPY uv.lock .
RUN chmod 755 /run.sh

RUN uv sync --no-dev

RUN mkdir /out

ENTRYPOINT ["/run.sh"]
CMD ["url"]
