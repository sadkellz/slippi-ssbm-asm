@echo off
echo Building bone_data.json...
gecko build -c bone_data.json -defsym "STG_EXIIndex=1" -batched
echo.

pause