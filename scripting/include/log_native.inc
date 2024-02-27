#if defined _log_methodmap_by_f1f88_included
 #endinput
#endif
#define _log_methodmap_by_f1f88_included

#pragma newdecls required
#pragma semicolon 1

/**
 * Adapted from:
 *      by Dr. McKay  : https://forums.alliedmods.net/showthread.php?t=258855
 *      by Alienmario : https://github.com/Alienmario/sm-logdebug
 */

enum
{
    LogLevel_OFF                        = 0,
    LogLevel_Trace                      = 1,
    LogLevel_Debug                      = 2,
    LogLevel_Info                       = 4,
    LogLevel_Warn                       = 8,
    LogLevel_Error                      = 16,
    LogLevel_Fatal                      = 32,
    LogLevel_ALL                        = 63
}

enum
{
    LogLocation_OFF                     = 0,    /**< Do nothing */
    LogLocation_ServerConsole           = 1,    /**< Message will be routed to server console */
    LogLocation_ClientConsoleAll        = 2,    /**< Message will be routed to all clients' consoles */
    LogLocation_AdminConsoleAll         = 4,    /**< Message will be routed to consoles of admins with a flag specified by plugin */
    LogLocation_ClientChatAll           = 8,    /**< Message will be routed to all clients' chat boxes (and consequently consoles) */
    LogLocation_AdminChatAll            = 16,   /**< Message will be routed to chat boxes of admins with a flag specified by plugin */
    LogLocation_File                    = 32,   /**< Message will be routed to plugin's debug log */
    LogLocation_ALL                     = 63
}

enum
{
    LogParts_OFF                        = 0,    /**< Message only */
    LogParts_Time                       = 1,    /**< Message will include current time */
    LogParts_TickCount                  = 2,    /**< Message will include current tick count */
    LogParts_Level                      = 4,    /**< Message will include log level */
    LogParts_StackCallerBrief           = 8,    /**< Message will include full location in the following syntax sourcefile::function:line */
    LogParts_ALL                        = 15
}

// Log Api
methodmap Log
{
    /**
     * 初始化 LogDebug, 建议在 OnPluginStart() 时调用。
     * 多个插件都调用时不会重复创建 ConVar, 但静态变量可能会存在多份。
     * 对象使用完毕后不需要 Close。
     *
     * @param prefix        日志信息的前缀, 默认为 "", 则没有前缀
     * @param timeFormat    日志信息的时间如何格式化, 默认为 "", 则使用 sm_datetime_format
     * @param logFileName   日志信息如果写入的文件名, 默认为 "", 则使用调用者的文件名
     */
    public native Log();

    // LOG_LEVEL_TRACE
    public native void Trace(const char[] format, any ...);

    // LOG_LEVEL_DEBUG
    public native void Debug(const char[] format, any ...);

    // LOG_LEVEL_INFO
    public native void Info(const char[] format, any ...);

    // LOG_LEVEL_WARN
    public native void Warn(const char[] format, any ...);

    // LOG_LEVEL_ERROR
    public native void Error(const char[] format, any ...);

    // LOG_LEVEL_FATAL
    public native void Fatal(const char[] format, any ...);

    public native void AssignOutput(bool trace, int level, int location, int parts, const char[] format, any ...);
}
