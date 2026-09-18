@echo off
echo =========================================
echo    Otomatik Push ve Release Olusturucu
echo =========================================
echo.

REM 1. Kullanicidan commit mesaji al
set /p commitMsg="Lutfen commit mesajinizi girin: "

echo.
echo [1/3] Degisiklikler kaydediliyor (git add ve commit)...
git add .
git commit -m "%commitMsg%"

echo.
echo [2/3] GitHub'a yukleniyor (git push)...
git push

echo.
echo [3/3] Release (.zip) dosyasi olusturuluyor...
REM 'git archive' komutu sadece repodaki dosyalari alir, gereksiz klasorleri zip'e dahil etmez.
git archive --format=zip --output=rose-temp-release.zip HEAD

echo.
echo =========================================
echo Islem Basarili! 
echo Kodlar GitHub'a yuklendi ve "rose-temp-release.zip" adli release dosyasi olusturuldu.
echo =========================================
pause
