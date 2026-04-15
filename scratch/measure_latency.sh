#!/bin/bash
URL="https://api.simrsrsudbaubau.online/api/jadwal"
echo "Measuring latency for $URL..."
for i in {1..5}
do
  curl -o /dev/null -s -w "Request $i: %{time_total}s\n" "$URL"
done
