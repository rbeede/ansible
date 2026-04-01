alias ll='ls --all -l --classify --full-time'

alias smashthem='7z a -mx=9 -myx=9 -ms=on -mhc=on -m0=LZMA2 -mmt=on -mtc=on -t7z'

# WSL2
alias cdwin="cd \`powershell.exe -c 'Write-Host -NoNewLine \$env:userprofile' | tr '\\134' '/' | xargs wslpath\`"
