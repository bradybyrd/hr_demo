echo off
echo #--------------------------------------------#
echo #      DBmaestro Hook Processor           #
echo #--------------------------------------------#
set PWD=%~dp0
REM echo PWD is %PWD%
java -cp ".;%PWD%..\lib\*;%PWD%..\lib\groovy-all-2.4.7.jar" groovy.ui.GroovyMain "%PWD%dbm_hook.groovy" %*
IF %ERRORLEVEL% NEQ 0 ( 
   echo Groovy Script failed code: %ERRORLEVEL%
   EXIT /b %ERRORLEVEL% 
)
