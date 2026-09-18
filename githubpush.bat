@echo off
echo =========================================
echo    Otomatik Push ve Release Olusturucu
echo =========================================
echo.

REM Kullanicidan proje klasorunun yolunu al
set /p projectPath="Lutfen projenin tam dosya yolunu girin (Orn: C:\fxserver\proje): "

REM Girilen yola gecis yap
cd /d "%projectPath%"
if errorlevel 1 (
    echo.
    echo HATA: Girilen dosya yolu bulunamadi! Lutfen dogru yazdiginizdan emin olun.
    pause
    exit /b
)

echo.
REM 1. Kullanicidan commit mesaji al
set /p commitMsg="Lutfen commit mesajinizi girin: "

echo.
echo [1/3] Degisiklikler kaydediliyor (git add ve commit)...
git add .
git commit -m "%commitMsg%"

echo.
echo [2/3] GitHub'daki son degisiklikler aliniyor (git pull)...
git pull --rebase

echo.
echo [3/3] GitHub'a kod yukleniyor (git push)...
git push

echo.
echo =========================================
echo Islem Basarili!
echo GitHub arkaplanda otomatik olarak Release (Zip) dosyasini olusturacaktir.
echo =========================================
pause
