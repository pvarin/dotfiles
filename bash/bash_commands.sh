build_meshcat_video(){
    # Usage:
    #   build_meshcat_video input.zip [output_name]
    #
    # Converts a zip file downloaded by meshcat to a video and gif. Places the resulting files in the ~/Videos/meshcat/
    new_name=${2:-$1}
    mkdir -p /tmp/meshcat
    mkdir -p ~/Videos/meshcat
    tar -C /tmp/meshcat -xvf $1
    ffmpeg -r 60 -i /tmp/meshcat/%07d.png -vcodec libx264 -preset slow -crf 18 ~/Videos/meshcat/$(basename -- $new_name).mp4
    to_gif ~/Videos/meshcat/$(basename -- $new_name).mp4
    rm /tmp/meshcat/*.png
    mv $1 ~/Videos/meshcat
}

to_gif(){
    # Usage:
    #   to_gif input_file [output_file.gif]
    #
    # If output is not specified the basename of the output file will be the same as the input file with the ".gif" extension
    output_name=${2:-${1%.*}.gif}
    palette="/tmp/palette.png"
    filters="fps=30,scale=1080:-1:flags=lanczos"

    ffmpeg -v warning -i "$1" -vf "$filters,palettegen" -y "$palette"
    ffmpeg -v warning -i "$1" -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y "$output_name"
}
