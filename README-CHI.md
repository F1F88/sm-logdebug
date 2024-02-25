# sm-logdebug

基于 Sourcemod 的简易 Log 框架

### 特性

- 支持自定义日志信息输出的级别。

    > Trace, Debug, Info, Waring, Error, Fatal
    > 当 `sm_log_level` 对应的 bit 位是 1 时才会输出。
    > 若 `sm_log_level` == 0 ，则不会输出任何信息。

- 支持输出堆栈信息

	> 当日志级别为 Trace，Fatal 时，会在输出用户信息后，额外输出堆栈调用信息（类似 LogStackTrace ）。

- 支持自定义日志输出的位置。


    > server console, all client console, all admin console, all client chat, all admin chat, log file
    > 服务器控制台、全部玩家控制台、管理员控制台、全部玩家聊天框、管理员聊天框、日志文件。
    > 当 `sm_log_location` 对应的 bit 位是 1 时才会输出。
    > 若 `sm_log_location` == 0 ，则不会输出任何信息。

- 支持自定义日志信息组成部分。

    > time, tick count, log level, caller location
    > 时间（可自定义格式），TickCount，日志级别，调用者文件名::函数名::行号。
    > 当 `sm_log_parts` 对应的 bit 位是 1 时才会输出。
    > 若 `sm_log_parts` == 0 ，则只输出用户传递的日志信息。

- 支持自定义日志信息组成部分-时间的格式

    > 初始化时传递参数给 `timeFormat`
    > 默认为 ""，使用 `sm_datetime_format`

- 日志信息会根据调用者文件名不同而写入不同的日志

    > 文件存放在 "./game/addons/sourcemod/logs/{CallerFileName}.log"

### 安装

- 将 `log.smx` 上传到 `./addons/sourcemod/plugins/`；

- 重启服务器或使用 `sm plugins load log` 来载入插件；

- 在其他插件中使用 `log_native.inc` 提供的 native 输出日志。


### 使用

- 参考 `log-example.sp`
