@echo off

:reinput

set input=

set /p input=������ commit ��Ϣ��

if "%input%"=="" goto reinput

:reconfirm

set confirm=

set /p confirm=��ȷ��������Ϣ��%input%����Y / N��

if %confirm% == N goto reinput
if %confirm% == n goto reinput
if %confirm% neq Y (if %confirm% neq y goto reconfirm )

git add . && git commit -m "%input%" && git push

pause