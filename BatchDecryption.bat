@ECHO OFF & CHCP 65001
ECHO Usage: python3 x64 decrypt.
PAUSE & CLS

REM python364 Dencrypt_fix.py %*
REM python3 Dencrypt_fix.py %*
REM python Dencrypt_fix.py %*

python364 Dencrypt_fix.py encrypt.bat
PAUSE & CLS

python364 Dencrypt_fix.py decrypt_Encrypted.bat
PAUSE & EXIT