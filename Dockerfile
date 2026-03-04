ARG ATOMICPARSLEY_RELEASE=20240608.083822.1ed9031
ARG DENO_VERSION=2.7.3
ARG YT_DLP_RELEASE=2026.03.03
ARG CREATED=unknown

FROM debian:trixie-slim AS runner
LABEL org.opencontainers.image.title="yt-dlp-docker"
LABEL org.opencontainers.image.description="yt-dlp with it's dependencies"
LABEL org.opencontainers.image.authors="Santeri Hetekivi <docker@hetekivi.com>"
LABEL org.opencontainers.image.url="https://github.com/SanteriHetekivi/yt-dlp-docker"
LABEL org.opencontainers.image.source="https://github.com/SanteriHetekivi/yt-dlp-docker"
LABEL org.opencontainers.image.licenses="Apache-2.0"
ARG DENO_VERSION
LABEL org.opencontainers.image.version="${DENO_VERSION}"
ARG CREATED
LABEL org.opencontainers.image.created="${CREATED}"

# Install dependencies for yt-dlp.
RUN apt-get --assume-yes update
# FFmpeg
RUN apt-get --assume-yes install curl && curl --version
RUN apt-get --assume-yes install xz-utils && tar --version
RUN curl  \
    -L https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz \
    -o ffmpeg-master-latest-linux64-gpl.tar.xz \
    && tar -xf ffmpeg-master-latest-linux64-gpl.tar.xz \
    && mv ffmpeg-master-latest-linux64-gpl/bin/ffmpeg /usr/local/bin/ffmpeg \
    && mv ffmpeg-master-latest-linux64-gpl/bin/ffprobe /usr/local/bin/ffprobe \
    && chmod +x /usr/local/bin/ffprobe \
    && chmod +x /usr/local/bin/ffmpeg \
    && rm -rf ffmpeg-master-latest-linux64-gpl* \
    && ffmpeg -version \
    && ffprobe -version
RUN apt-get --assume-yes remove xz-utils
# yt-dlp-ejs: External JavaScript for yt-dlp supporting many runtimes.
RUN apt-get --assume-yes install unzip && unzip -v
ENV DENO_INSTALL="/root/.deno"
ENV PATH="${DENO_INSTALL}/bin:${PATH}"
ARG DENO_VERSION
RUN curl -fsSL https://deno.land/install.sh | sh -s "v${DENO_VERSION}" \
    && deno --version
RUN apt-get --assume-yes install python3 && python3 --version
RUN apt-get --assume-yes install python3-pip && pip3 --version
RUN pip3 install \
    --no-cache-dir \
    --break-system-packages \
    --root-user-action=ignore \
    --upgrade \
    yt-dlp-ejs  \
    && python3 -c "import yt_dlp_ejs; print(yt_dlp_ejs._version)"
# Certifi: Python SSL Certificates.
RUN pip3 install \
    --no-cache-dir \
    --break-system-packages \
    --root-user-action=ignore \
    --upgrade \
    certifi  \
    && python3 -c "import certifi; print(certifi.where())"
# Brotli: Generic-purpose lossless compression algorithm.
RUN apt-get --assume-yes install brotli && brotli --version
# websockets: Library for building WebSocket servers and clients.
RUN pip3 install \
    --no-cache-dir \
    --break-system-packages \
    --root-user-action=ignore \
    --upgrade \
    websockets  \
    && python3 -c "import websockets; print(websockets.__version__)"
# Requests: Simple, yet elegant, HTTP library.
RUN pip3 install \
    --no-cache-dir \
    --break-system-packages \
    --root-user-action=ignore \
    --upgrade \
    requests  \
    && python3 -c "import requests; print(requests.__version__)"
# curl_cffi: Python binding for curl-impersonate fork via cffi.
RUN pip3 install \
    --no-cache-dir \
    --break-system-packages \
    --root-user-action=ignore \
    --upgrade \
    curl_cffi  \
    && python3 -c "import curl_cffi; print(curl_cffi.__version__)"
# mutagen: Python module to handle audio metadata.
RUN pip3 install \
    --no-cache-dir \
    --break-system-packages \
    --root-user-action=ignore \
    --upgrade \
    mutagen  \
    && python3 -c "import mutagen; print(mutagen.version)"
# AtomicParsley: Lightweight command line program for reading, parsing and setting metadata into MPEG-4 files.
ARG ATOMICPARSLEY_RELEASE
RUN curl \
    -L https://github.com/wez/atomicparsley/releases/download/$ATOMICPARSLEY_RELEASE/AtomicParsleyLinux.zip \
    -o AtomicParsleyLinux.zip \
    && unzip AtomicParsleyLinux.zip \
    && chmod +x AtomicParsley \
    && mv AtomicParsley /usr/local/bin/AtomicParsley \
    && rm -rf AtomicParsleyLinux* \
    && AtomicParsley --version
RUN apt-get --assume-yes remove unzip
# PyCryptodome: Self-contained Python package of low-level cryptographic primitives.
RUN pip3 install \
    --no-cache-dir \
    --break-system-packages \
    --root-user-action=ignore \
    --upgrade \
    pycryptodomex  \
    && python3 -c "import Cryptodome; print(Cryptodome.__version__)"
# SecretStorage: Python bindings to FreeDesktop.org Secret Service API.
RUN pip3 install \
    --no-cache-dir \
    --break-system-packages \
    --root-user-action=ignore \
    --upgrade \
    SecretStorage  \
    && python3 -c "import secretstorage; print(secretstorage.__version__)"
# yt-dlp itself.
ARG YT_DLP_RELEASE
RUN curl \
    -L https://github.com/yt-dlp/yt-dlp/releases/download/$YT_DLP_RELEASE/yt-dlp \
    -o /usr/local/bin/yt-dlp \
    && chmod +x /usr/local/bin/yt-dlp \
    && yt-dlp --version

# Clean up apt cache to reduce image size.
RUN rm -rf /var/lib/apt/lists/*

# Directories for yt-dlp.
# All intermediary files are first downloaded to the temp path
RUN mkdir -p /data/temp
# and then the final files are moved over to the home path after download is finished.
RUN mkdir -p /data/home
# Directory for storing download archive files.
RUN mkdir -p /data/archive
WORKDIR /data/home
