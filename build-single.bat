@echo off
echo Building single.json...
gecko build -c single.json -defsym "STG_EXIIndex=1" -batched
echo.

pause