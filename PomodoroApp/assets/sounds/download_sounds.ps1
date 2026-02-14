# Pomodoro App Sound Downloader
# Downloads free CC0/royalty-free sounds from Pixabay

Write-Host "Downloading sound files for Pomodoro App..." -ForegroundColor Cyan

$soundsDir = $PSScriptRoot

# Sound URLs from Pixabay (royalty-free, no attribution required)
# Note: These are example URLs - you may need to find your own preferred sounds
$sounds = @{
    # Timer sounds (if missing)
    # "completion.mp3" = "https://cdn.pixabay.com/audio/2022/03/15/audio_c8c8a73467.mp3"
    # "break.mp3" = "https://cdn.pixabay.com/audio/2022/03/10/audio_c9b53b16f3.mp3"
    # "tick.mp3" = "https://cdn.pixabay.com/audio/2021/08/04/audio_0625c1e5c2.mp3"

    # Ambient sounds
    "forest.mp3" = "https://cdn.pixabay.com/audio/2022/08/04/audio_2dae70b7d6.mp3"
    "ocean.mp3" = "https://cdn.pixabay.com/audio/2024/11/09/audio_5f2c66b8a6.mp3"
    "fireplace.mp3" = "https://cdn.pixabay.com/audio/2022/10/30/audio_a0141c3bcc.mp3"
    "cafe.mp3" = "https://cdn.pixabay.com/audio/2024/02/21/audio_fd6bcfc3dd.mp3"
    "white_noise.mp3" = "https://cdn.pixabay.com/audio/2022/03/13/audio_4d0c9dee2f.mp3"
    "night.mp3" = "https://cdn.pixabay.com/audio/2024/10/24/audio_c7268e9ca5.mp3"
}

foreach ($sound in $sounds.GetEnumerator()) {
    $filePath = Join-Path $soundsDir $sound.Key

    if (Test-Path $filePath) {
        Write-Host "  [SKIP] $($sound.Key) already exists" -ForegroundColor Yellow
    } else {
        Write-Host "  [DOWN] Downloading $($sound.Key)..." -ForegroundColor Green
        try {
            Invoke-WebRequest -Uri $sound.Value -OutFile $filePath -UseBasicParsing
            Write-Host "         Done!" -ForegroundColor Green
        } catch {
            Write-Host "         Failed: $_" -ForegroundColor Red
        }
    }
}

# Note about lofi - typically longer/copyrighted, suggest finding your own
Write-Host ""
Write-Host "Note: 'lofi.mp3' needs to be added manually." -ForegroundColor Yellow
Write-Host "You can find royalty-free lo-fi music at:" -ForegroundColor Yellow
Write-Host "  - https://pixabay.com/music/search/lofi/" -ForegroundColor Cyan
Write-Host "  - https://www.chosic.com/free-music/lofi/" -ForegroundColor Cyan
Write-Host ""
Write-Host "All done! Sound files are in: $soundsDir" -ForegroundColor Green
