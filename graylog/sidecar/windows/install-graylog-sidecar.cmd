@REM set working dir to this dir
cd /d "%~dp0"

del graylog_sidecar_installer.exe

@REM Download
@REM NOTE: this appears to be very slow (vs downloading in a web browser or wget/curl), unsure why. Using this method since we can't gaurentee curl/wget are available.
@REM Find the latest file via:
@REM https://github.com/Graylog2/collector-sidecar/releases
powershell -Command "& {Invoke-WebRequest -URI https://github.com/Graylog2/collector-sidecar/releases/download/1.5.1/graylog_sidecar_installer_1.5.1-1.exe -OutFile graylog_sidecar_installer.exe}"

@REM Install
"%~dp0graylog_sidecar_installer.exe" /S -SERVERURL=https://GRAYLOGSERVER.DOMAIN.COM/api -APITOKEN=YOURAPITOKEN
@REM note: previous versions required explicitly installing and starting the service. this is no longer required.
@REM "C:\Program Files\Graylog\sidecar\graylog-sidecar.exe" -service install