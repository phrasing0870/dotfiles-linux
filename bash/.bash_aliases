# --- General ---

alias ll='ls -lah'
alias la='ls -A'

alias fd='fdfind'
alias bat='batcat'

alias update='sudo apt update && sudo apt upgrade'
alias cleanup='sudo apt autoremove && sudo apt autoclean'

alias ..='cd ..'
alias ...='cd ../..'

alias cls='clear'
alias dotfiles='cd ~/Documents/dotfiles-linux'


# --- Git ---

alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'


# --- yt-dlp ---

# 1080p H.264 preferred
alias dlvid="yt-dlp -f 'bestvideo[vcodec^=avc1][height<=1080]+bestaudio[ext=m4a]/bestvideo[height<=1080]+bestaudio/best'"

# 720p
alias dlvid720="yt-dlp -f 'bestvideo[vcodec^=avc1][height<=720]+bestaudio[ext=m4a]/bestvideo[height<=720]+bestaudio/best'"

# 4K, best available quality
alias dlvid4k="yt-dlp -f 'bestvideo[height<=2160]+bestaudio/bestvideo[height<=2160]+bestaudio/best'"

# Best quality MP3
alias dlmp3="yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-thumbnail"

# 1080p playlist
alias dlplaylist="yt-dlp --yes-playlist -f 'bestvideo[vcodec^=avc1][height<=1080]+bestaudio[ext=m4a]/bestvideo[height<=1080]+bestaudio/best' -o '~/Downloads/%(playlist_title)s/%(playlist_index)03d - %(title)s.%(ext)s'"

# 720p playlist
alias dlplaylist720="yt-dlp --yes-playlist -f 'bestvideo[vcodec^=avc1][height<=720]+bestaudio[ext=m4a]/bestvideo[height<=720]+bestaudio/best' -o '~/Downloads/%(playlist_title)s/%(playlist_index)03d - %(title)s.%(ext)s'"
