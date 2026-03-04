#!/bin/bash
docker run \
      --rm \
      --name yt-dlp \
      -v "/mnt/SSD_450G/media/videos/series/internet:/data/home" \
      -v "/mnt/SSD_450G/yt-dlp/archive:/data/archive" \
      -v "/mnt/SSD_450G/yt-dlp/temp:/data/temp" \
      ghcr.io/santerihetekivi/yt-dlp-docker:2026.03.03 \
            yt-dlp \
                  --update \
                  --no-abort-on-error \
                  --live-from-start \
                  --yes-playlist \
                  --download-archive "/data/archive/archive.txt" \
                  --no-break-on-existing \
                  --lazy-playlist \
                  --no-batch-file \
                  --paths "home:/data/home" \
                  --paths "temp:/data/temp" \
                  --output "%(channel)s/%(channel)s - %(upload_date>%Y-%m-%d)s – %(title)s [%(id)s].%(ext)s" \
                  --continue \
                  --part \
                  --merge-output-format "mkv" \
                  --sub-langs "en.*,fi" \
                  --remux-video "mkv" \
                  --no-keep-video \
                  --embed-subs \
                  --embed-thumbnail \
                  --embed-metadata \
                  --embed-chapters \
                  --embed-info-json \
                  --sponsorblock-remove "sponsor,intro,outro,selfpromo,preview,interaction,hook" \
                  "https://www.youtube.com/playlist?list=PL_90BCfd6ZLiDDsG5UvWhzg4slaAwYU4B"
