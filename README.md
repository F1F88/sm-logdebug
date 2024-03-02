- # Logger | [中文](./README-CHI.md)

  A simple Log framework based on Sourcemod

  ### Feature

  - Supports customizable levels of logging information output.

    > Trace, Debug, Info, Waring, Error, Fatal Output occurs only when the corresponding bit of `sm_log_level` is 1. If `sm_log_level` == 0, no information will be output.
  
  - Supports outputting stack information.

    > When the log level is Trace, Fatal, it will output stack call information (similar to LogStackTrace) in addition to user information.

  - Supports customizing the output location of logs.
  
    > If `sm_log_location` == 0, nothing will happen. Logs will be output to the corresponding location only if the corresponding bit of `sm_log_location` is 1.
  
  - Supports customizing the components of logging information.
  
    > If `sm_log_parts` == 0, only user logs will be output.
    >
    > Other information will be attached to the message header only if the corresponding bit of `sm_log_parts` is 1.
  
  - Supports specifying what permissions administrators must have to receive logs.
  
    > If `sm_log_admin_flags` == 0, all clients can receive logs. (Not recommended, as it may duplicate with LogLocation_Client***)
    >
    > Logs will be received according to administrator permissions if `sm_log_admin_flags` != 0.
  
  - Supports adding message headers.
  
    > A message header can be added between parts and user logs by specifying logTag. Used for identification, such as [SM].
  
  - Supports customizing the format of time in logs.
  
    > The time format depends on `sm_datetime_format`.
  
  - Supports customizing the log file name.

    > By default, logs will be written to different files based on the caller's filename.
    >
    > Files are stored in "./game/addons/sourcemod/logs/{File}.log".

  ### Methodmap & Native

  - Methodmap is more convenient to use, has more comprehensive functions, and slightly higher occupancy performance, but its impact is not significant. Recommended use
  - Native requires the introduction of plugins, which are not fully functional and have low usage performance. Suggest using only when high performance requirements are required
  
  ###### Similarities
  
  - The usage method is the same: only need to modify the include when switching.
  - Same API: both provide 1 factory method and 6 logging levels.
  - Same output format: only depends on the value of convar - parts.
  
  ###### Differences
  
  - Methodmap usage only requires including log_methodmap.inc in the plugin.
  - Methodmap version additionally supports each plugin to control logging output with its own exclusive convar.
  - The version number of the methodmap version depends on the version of log_methodmap.inc included.
  - Methodmap version optimizes when outputting to multiple locations simultaneously, making the output results more visually appealing.
  - In the factory method of the methodmap version, convarTag and failOnCustomConVarExists are used to generate exclusive log control convars.
  - Methodmap version creates 4 global convars + number of imported plugins * 6 exclusive convars.
  - Methodmap version uses global variables for caching, avoiding redundant creation of char arrays.
  - Native usage requires including log_native.inc and adding the log.smx plugin.
  - Native version can only control logging output with global convars.
  - The version number of the native version depends on the version of log.sp.
  - Native version does not optimize for outputting to multiple locations simultaneously, resulting in higher performance but messages may be less convenient to view.
  - In the factory method of the native version, convarTag and failOnCustomConVarExists are reserved parameters with no practical effect.
  - Native version only creates 4 global convars.
  - Native version creates char arrays in stack space as needed every time a function is called.

  |        Version Comparison         |  log_native.inc  | log_methodmap.inc  |                         Description                          |
  | :-------------------------------: | :--------------: | :----------------: | :----------------------------------------------------------: |
  |  Global Convar Controls Logging   |        Y         |         Y          | sm_log_level<br>sm_log_location<br>sm_log_parts<br>sm_log_admin_flags |
  | Exclusive Convar Controls Logging |        N         |         Y          |           sm_{tag}_global_contral<br>sm_{tag}_***            |
  |       Global Convar Version       |        Y         |         N          |                        sm_log_version                        |
  |     Exclusive Convar Version      |        N         |         Y          |                     sm_{tag}_log_version                     |
  |   Multiple Location Format Opt.   |        N         |         Y          | Optimized logs look more visually appealing<br>but slightly slower performance |
  |      Chat date optimization       |        Y         |         Y          | Remove part date from chat logs <br/>Avoid logs that are too long<br>Part - tick count is not affected |
  |         Import Difficulty         | Header + log.smx | Only import header |                                                              |
  |           Runtime Time            | Relatively Less  |  Relatively More   |                                                              |
  |           Memory Usage            | Relatively Less  |  Relatively More   |                                                              |

  ### Installation and Usage
  
  ##### Methodmap
  
  - Simply import the `log_methodmap.inc` header file into your plugin.
  - Write your plugin using the API provided by `log_methodmap.inc`.
  - Upload your compiled plugin's smx file to `./addons/sourcemod/plugins/`.
  - Restart the server or use `sm plugins load {pluginsName}` to load the plugin.
  
  ##### Native
  
  - Import the `log_native.inc` header file into your plugin.
  - Write your plugin using the API provided by `log_native.inc`.
  - Upload your compiled plugin's smx file to `./addons/sourcemod/plugins/`.
  - Also, upload `log.smx` to `./addons/sourcemod/plugins/`.
  - Restart the server or use `sm plugins load log` to load the dependency plugin.
  - Restart the server or use `sm plugins load {pluginsName}` to load the plugin.

  ### API Usage
  
  - Refer to `log-***-example.sp`.
  
  

`This article is translated by ChatGPT`
