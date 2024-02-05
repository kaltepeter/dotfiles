#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail
[[ ${DEBUG:-false} == true ]] && set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

error() {
  echo "Error: $1"
  exit "$2"
} >&2

# https://engineering.giphy.com/how-to-make-gifs-with-ffmpeg/
# https://gist.github.com/dergachev/4627207

icloud_quicktime_path="${HOME}/Library/Mobile Documents/com~apple~QuickTimePlayerX/Documents"
default_out_path="${HOME}/Documents/gifs"

[[ -d "${default_out_path}" ]] || mkdir "${default_out_path}"

[[ -z "${1:-}" ]] && error "Must provide .mov input file as first argument, assumes path is in ${icloud_quicktime_path}." 1
mov_input="${1}"
gif_output="${1/%mov/gif}"

fps="${2:-10}"
echo "Using fps: ${fps}"
scale="width=1920:height=-2"
filter="[0:v] fps=${fps},scale=${scale},split [a][b];[a] palettegen [p];[b][p] paletteuse"

# ffmpeg -i "${mov_input}" -filter_complex "[0:v] palettegen" palette.png
# ffmpeg -i "${mov_input}" -i palette.png -filter_complex "[0:v][1:v] paletteuse" "${default_out_path}/${gif_output}"
ffmpeg -i "${mov_input}" -filter_complex "${filter}" "${default_out_path}/${gif_output}"

gifsicle --optimize=3 "${default_out_path}/${gif_output}" -o "${default_out_path}/${gif_output/%.gif/-opt.gif}"

echo "Your gif is here: \"${default_out_path}/${gif_output}\""

#  cleanup
#  rm palette.png
