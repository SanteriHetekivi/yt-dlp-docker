#!/bin/bash
docker run \
      --rm \
      --name yt-dlp \
      -v "/mnt/SSD_450G/media/videos/series/internet:/output" \
      -v "/mnt/SSD_450G/yt-dlp/archive:/root/archive" \
      -v "/mnt/SSD_450G/yt-dlp/temp:/root/temp" \
      ghcr.io/santerihetekivi/yt-dlp-docker:2026.02.21 \
            yt-dlp \
                  --update \
                  --no-abort-on-error \
                  --live-from-start \
                  --yes-playlist \
                  --download-archive "/root/archive/archive.txt" \
                  --no-break-on-existing \
                  --lazy-playlist \
                  --no-batch-file \
                  --paths "home:/output" \
                  --paths "temp:/root/temp" \
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
chmod -R 777 /mnt/SSD_450G/media/videos/series/internet