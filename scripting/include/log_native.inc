#if defined _log_native_by_f1f88_included
 #endinput
#endif
#define _log_native_by_f1f88_included

#pragma newdecls required
#pragma semicolon 1

/**
 * Adapted from:
 *      by Dr. McKay  : https://forums.alliedmods.net/showthread.php?t=258855
 *      by Alienmario : https://github.com/Alienmario/sm-logdebug
 */

enum
{
    LogLevel_OFF                                    = 0,
    LogLevel_Trace                                  = 1,
    LogLevel_Debug                                  = 2,
    LogLevel_Info                                   = 4,
    LogLevel_Warn                                   = 8,
    LogLevel_Error                                  = 16,
    LogLevel_Fatal                                  = 32,
    LogLevel_ALL                                    = 63
}

enum
{
    LogLocation_OFF                                 = 0,    /**< Do nothing */
    LogLocation_ServerConsole                       = 1,    /**< Message will be routed to server console */
    LogLocation_ClientConsoleAll                    = 2,    /**< Message will be routed to all clients' consoles */
    LogLocation_AdminConsoleAll                     = 4,    /**< Message will be routed to consoles of admins with a flag specified by plugin */
    LogLocation_ClientChatAll                       = 8,    /**< Message will be routed to all clients' chat boxes (and consequently consoles) */
    LogLocation_AdminChatAll                        = 16,   /**< Message will be routed to chat boxes of admins with a flag specified by plugin */
    LogLocation_File                                = 32,   /**< Message will be routed to plugin's debug log */
    LogLocation_ALL                                 = 63
}

enum
{
    LogParts_OFF                                    = 0,    /**< Message only */
    LogParts_Time                                   = 1,    /**< Message will include current time */
    LogParts_TickCount                              = 2,    /**< Message will include current tick count */
    LogParts_Level                                  = 4,    /**< Message will include log level */
    LogParts_StackCallerFile                        = 8,    /**< Message will include full location in the following syntax sourcefile (Multiple stack caller bits prioritize selecting smaller bits)*/
    LogParts_StackCallerFileAndFunc                 = 16,   /**< Message will include full location in the following syntax sourcefile::function (Multiple stack caller bits prioritize selecting smaller bits)*/
    LogParts_StackCallerFileAndFuncAndLine          = 32,   /**< Message will include full location in the following syntax sourcefile::function::line (Multiple stack caller bits prioritize selecting smaller bits)*/
    LogParts_ALL                                    = 39
}

#define LOG_LEVEL_NAME_TRACE                        "Trace"
#define LOG_LEVEL_NAME_DEBUG                        "Debug"
#define LOG_LEVEL_NAME_INFO                         "Info"
#define LOG_LEVEL_NAME_WARN                         "Warn"
#define LOG_LEVEL_NAME_ERROR                        "Error"
#define LOG_LEVEL_NAME_FATAL                        "Fatal"

// 可以适当调整这些值
// #define LOG_MAX_CONVAR_TAG                          32
#define LOG_MAX_CONVAR                              64
#define LOG_MAX_LOG_TAG                             64
#define LOG_MAX_FILE_NAME                           64
#define LOG_MAX_USER_MESSAGE                        2048

#define LOG_MAX_TIME_FORMAT                         64
#define LOG_MAX_TICK_COUNT                          16
#define LOG_MAX_LEVEL_NAME                          10
#define LOG_MAX_FILE                                PLATFORM_MAX_PATH
#define LOG_MAX_FUNCTION                            128
#define LOG_MAX_CALLER_BRIEF                        LOG_MAX_FILE + LOG_MAX_FUNCTION

// 只在本文件内使用, 缓存
static char _logTag[LOG_MAX_LOG_TAG];
static char _logFilePath[LOG_MAX_FILE];
static char _userMessage[LOG_MAX_USER_MESSAGE];

// Log Api
methodmap Logger
{
    /**
     * 建议在 OnPluginStart() 时调用。
     *
     * @param convarTag                     保留参数。与 methodmap 保持一致，这样在切换到 log_methodmap.inc 时可以减少改动。
     * @param failOnCustomConVarExists      保留参数。与 methodmap 保持一致，这样在切换到 log_methodmap.inc 时可以减少改动。
     * @param logTag                        日志信息的标签，将被放在消息头，默认为空 ""。
     * @param logFileName                   日志信息如果写入的文件名, 默认为空 "" 时，使用调用者的文件名作为日志文件名称。
     */
    public static Logger GetLogger(const char[] convarTag, bool failOnCustomConVarExists = false, const char[] logTag = "", const char[] logFileName = "")
    {
        strcopy(_logTag, sizeof(_logTag), logTag);

        if( ! logFileName[0] )
        {
            FrameIterator frames = new FrameIterator();
            frames.Next();  // 跳出 0 -  :: FrameIterator.FrameIterator
            frames.Next();  // 跳出 1 - ***\include\log_native.inc :: GetLogger

            char buffer[PLATFORM_MAX_PATH];
            frames.GetFilePath(buffer, sizeof(buffer));
            frames.Close();

            // clip File path to file name
            int sepIndex = FindCharInString(buffer, '\\', true);// 除去首部多余的路径
            if( sepIndex == -1 )                                // 如果是 Linux 则查找 '/'
                sepIndex = FindCharInString(buffer, '/', true);

            BuildPath(Path_SM, _logFilePath, sizeof(_logFilePath), "logs/%s.log", buffer[sepIndex]);
        }
        else
        {
            BuildPath(Path_SM, _logFilePath, sizeof(_logFilePath), "logs/%s.log", logFileName);
        }

        return view_as<Logger>( 0xF1F88 );
    }

    // LogLevel_Trace
    public void Trace(const char[] format, any ...)
    {
        if( ! _LocationAccess() || ! _LevelAccess(LogLevel_Trace) )
            return ;

        VFormat(_userMessage, sizeof(_userMessage), format, 3);

        _OutputLogMessage(LogLevel_Trace, _logTag, _logFilePath, _userMessage);
    }

    // LogLevel_Debug
    public void Debug(const char[] format, any ...)
    {
        if( ! _LocationAccess() || ! _LevelAccess(LogLevel_Debug) )
            return ;

        VFormat(_userMessage, sizeof(_userMessage), format, 3);

        _OutputLogMessage(LogLevel_Debug, _logTag, _logFilePath, _userMessage);
    }

    // LogLevel_Info
    public void Info(const char[] format, any ...)
    {
        if( ! _LocationAccess() || ! _LevelAccess(LogLevel_Info) )
            return ;

        VFormat(_userMessage, sizeof(_userMessage), format, 3);

        _OutputLogMessage(LogLevel_Info, _logTag, _logFilePath, _userMessage);
    }

    // LogLevel_Warn
    public void Warn(const char[] format, any ...)
    {
        if( ! _LocationAccess() || ! _LevelAccess(LogLevel_Warn) )
            return ;

        VFormat(_userMessage, sizeof(_userMessage), format, 3);

        _OutputLogMessage(LogLevel_Warn, _logTag, _logFilePath, _userMessage);
    }

    // LogLevel_Error
    public void Error(const char[] format, any ...)
    {
        if( ! _LocationAccess() || ! _LevelAccess(LogLevel_Error) )
            return ;

        VFormat(_userMessage, sizeof(_userMessage), format, 3);

        _OutputLogMessage(LogLevel_Error, _logTag, _logFilePath, _userMessage);
    }

    // LogLevel_Fatal
    public void Fatal(const char[] format, any ...)
    {
        if( ! _LocationAccess() || ! _LevelAccess(LogLevel_Fatal) )
            return ;

        VFormat(_userMessage, sizeof(_userMessage), format, 3);

        _OutputLogMessage(LogLevel_Fatal, _logTag, _logFilePath, _userMessage);
    }
}

native bool _LevelAccess(int level);

native bool _LocationAccess();

native void _OutputLogMessage(int level, const char[] logTag, const char[] logFileName, const char[] userMessage);
