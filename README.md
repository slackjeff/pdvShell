
## 🌐 Translations

🇩🇪 [Deutsch](usr/share/doc/pdvshell/README/README.de.md)  
🇬🇧 [English](usr/share/doc/pdvshell/README/README-en.md)  
🇪🇸 [Español](usr/share/doc/pdvshell/README/README.es.md)  
🇫🇷 [Français](usr/share/doc/pdvshell/README/README.fr.md)  
🇮🇹 [Italiano](usr/share/doc/pdvshell/README/README.it.md)  
🇯🇵 [日本語](usr/share/doc/pdvshell/README/README.ja.md)  
🇰🇷 [한국어](usr/share/doc/pdvshell/README/README-ko.md)  
🇵🇹 [Português](usr/share/doc/pdvshell/README/README.pt.md)  
🇧🇷 [Português brasileiro](usr/share/doc/pdvshell/README/README.pt_BR.md)  
🇷🇺 [Русский](usr/share/doc/pdvshell/README/README.ru.md)  
🇺🇦 [Українська](usr/share/doc/pdvshell/README/README.uk.md)  
🇨🇳 [中文](usr/share/doc/pdvshell/README/README.zh.md)
  

Configure the terminal to 160×47.  


💾 Backup

Use cron to generate a `.tar.gz` archive of the `$HOME/.config/pdvshell` directory at the time the cash register is closed.

$ crontab -e
```
0 22 * * * cd $HOME && tar -zcvf "pdvshell-config-$(date +%x | sed 's|/|-|g').tar.gz" ".config/pdvshell/"
```

**Important:** The `22:00` time is only an example. It is recommended to configure the time according to the store's actual cash register closing time.


To check the scheduled task:

$ crontab -l

------------------------------------------------------------------------------------------

pdvshell-config-2026-09-20.tar.gz  
pdvshell-config-2026-09-21.tar.gz  
pdvshell-config-2026-09-22.tar.gz  



