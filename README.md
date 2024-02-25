# Sm logdebug

A Simple Log Framework Based on Source Mod

### Features

- Support the level of custom log information output.

    > Trace, Debug, Info, Waring, Error, Fatal
    > will only output when the bit corresponding to `sm_log_level` is 1.
    > If `sm_log_level==0` no information will be output.

- Support outputting stack information

    > When the log level is Trace, Fatal, additional stack call information (similar to LogStackTrace) will be output after outputting user information.

- Support custom log output location.

    > Server console, all client console, all admin console, all client chat, all admin chat, log file.
    > It will only output when the bit corresponding to `sm_log_location` is 1.
    > If `sm_log_location` == 0, no information will be output.

- Support custom log information components.

    > Time, tick count, log level, caller location time (customizable format), TickCount, log level, caller file name::function name::line number.
    > The output will only occur when the bit corresponding to `sm_log_parts` is 1.
    > If `sm_log_parts` == 0, only the log information passed by the user will be output.

- Support custom log information components - time format

    > convar - sm_datetime_format

- The log information will be written to different logs based on the caller's file name

    > The file is stored in "./name/additions/sourcemod/logs/{CallerFileName}.log"

### install

- Upload log.smx to/ Addins/sourcemod/plugins/;

- Restart the server or use sm plugins load log to load plugins;

- Use the native output log provided by log_dative.inc in other plugins.

### Use

Refer to log [example.sp](./scripting/log-example.sp)
