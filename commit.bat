@echo off

:reinput

set /p input=������ commit ��Ϣ��

if "%input%"=="" goto reinput

git add . && git commit -m "%input%" && git push

pause