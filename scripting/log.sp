#pragma newdecls required
#pragma semicolon 1

#include <log_native>
#include <clients_methodmap>

#define PLUGIN_NAME                         "log"
#define PLUGIN_AUTHOR                       "F1F88"
#define PLUGIN_DESCRIPTION                  "A simple sm logging framework"
#define PLUGIN_VERSION	                    "1.0.0"
#define PLUGIN_URL                          "https://github.com/F1F88/sm-logdebug"

public Plugin myinfo =
{
    name        = PLUGIN_NAME,
    author      = PLUGIN_AUTHOR,
    description = PLUGIN_DESCRIPTION,
    version     = PLUGIN_VERSION,
    url         = PLUGIN_URL
};

// #define LOG_PREFIX                          "[Log]"

#define LOG_LEVEL_NAME_TRACE                "TRACE"
#define LOG_LEVEL_NAME_DEBUG                "DEBUG"
#define LOG_LEVEL_NAME_INFO                 "INFO"
#define LOG_LEVEL_NAME_WARN                 "WARN"
#define LOG_LEVEL_NAME_ERROR                "ERROR"
#define LOG_LEVEL_NAME_FATAL                "FATAL"

// 定义 ConVar 信息, 方便后期修改
#define LOG_CONVAR_LEVEL_DEFAULT            "60"
#define LOG_CONVAR_LEVEL_NAME               "sm_log_level"
#define LOG_CONVAR_LEVEL_DESC               "Add up values to enable debug logging to those level\n\
  0  = off\n\
  1  = trace\n\
  2  = debug\n\
  4  = info\n\
  8  = warn\n\
  16 = error\n\
  32 = fatal\n\
  63 = all\n"
#define LOG_CONVAR_LEVEL_MIN                0.0
#define LOG_CONVAR_LEVEL_MAX                255.0

#define LOG_CONVAR_LOCATION_DEFAULT         "37"
#define LOG_CONVAR_LOCATION_NAME            "sm_log_location"
#define LOG_CONVAR_LOCATION_DESC            "Add up values to enable debug logging to those locations\n\
  0  = off\n\
  1  = server console\n\
  2  = all clients' consoles\n\
  4  = consoles of admins\n\
  8  = all clients' chat\n\
  16 = chat of admins\n\
  32 = written to the 'logs/{pluginName}.log' file\n\
  63 = all\n"
#define LOG_CONVAR_LOCATION_MIN             0.0
#define LOG_CONVAR_LOCATION_MAX             255.0

#define LOG_CONVAR_PARTS_DEFAULT            "13"
#define LOG_CONVAR_PARTS_NAME               "sm_log_parts"
#define LOG_CONVAR_PARTS_DESC               "Add up values to set up additional information included in the logs\n\
  0  = only user message\n\
  1  = time\n\
  2  = tick count\n\
  4  = log level\n\
  8  = stack caller location in the following syntax sourcefile::function:line\n\
  15 = all"
#define LOG_CONVAR_PARTS_MIN                0.0
#define LOG_CONVAR_PARTS_MAX                255.0

#define LOG_CONVAR_VERSION_DEFAULT          PLUGIN_VERSION
#define LOG_CONVAR_VERSION_NAME             "sm_log_version"
#define LOG_CONVAR_VERSION_DESC             PLUGIN_DESCRIPTION

// 可以适当调整这些值
#define LOG_MAX_CONVAR_NAME                 16

#define LOG_MAX_USER_MESSAGE                2048
// #define LOG_MAX_ALL_MESSAGE                 2048
#define LOG_MAX_TIME                        64
#define LOG_MAX_TICK_COUNT                  12
#define LOG_MAX_LEVEL_NAME                  8
#define LOG_MAX_FILE_NAME                   128
#define LOG_MAX_FUNC_NAME                   128
#define LOG_MAX_CALLER_BRIEF                LOG_MAX_FILE_NAME + LOG_MAX_FUNC_NAME

// 缓存 convar 值, 这样比调用 convar.typeValue 效率更高
static int g_cvarLevel;
static int g_cvarLocation;
static int g_cvarParts;

// 方法共用
char g_logFileName[LOG_MAX_FILE_NAME];
char g_userMessage[LOG_MAX_USER_MESSAGE];
// char g_allMessage[LOG_MAX_ALL_MESSAGE];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    InitNatives();
    return APLRes_Success;
}

public void OnPluginStart()
{
    InitConVars();
}

// =================================== Init ====================================
void InitConVars()
{
    ConVar convar;

    // Log Level
    convar = CreateConVar(LOG_CONVAR_LEVEL_NAME, LOG_CONVAR_LEVEL_DEFAULT, LOG_CONVAR_LEVEL_DESC, _, true, LOG_CONVAR_LEVEL_MIN, true, LOG_CONVAR_LEVEL_MAX);
    convar.AddChangeHook(OnConVarChange);
    g_cvarLevel = convar.IntValue;

    // Log Location
    convar = CreateConVar(LOG_CONVAR_LOCATION_NAME, LOG_CONVAR_LOCATION_DEFAULT, LOG_CONVAR_LOCATION_DESC, _, true, LOG_CONVAR_LOCATION_MIN, true, LOG_CONVAR_LOCATION_MAX);
    convar.AddChangeHook(OnConVarChange);
    g_cvarLocation = convar.IntValue;

    // Log Message Parts
    convar = CreateConVar(LOG_CONVAR_PARTS_NAME, LOG_CONVAR_PARTS_DEFAULT, LOG_CONVAR_PARTS_DESC, _, true, LOG_CONVAR_PARTS_MIN, true, LOG_CONVAR_PARTS_MAX);
    convar.AddChangeHook(OnConVarChange);
    g_cvarParts = convar.IntValue;

    // Log Version
    CreateConVar(LOG_CONVAR_VERSION_NAME, LOG_CONVAR_VERSION_DEFAULT, LOG_CONVAR_VERSION_DESC, FCVAR_DONTRECORD);

    // AutoExecConfig(true, PLUGIN_NAME);
}

void OnConVarChange(ConVar convar, char[] old_value, char[] new_value)
{
    if( convar == null )
        return ;

    char convarName[LOG_MAX_CONVAR_NAME];
    convar.GetName(convarName, LOG_MAX_CONVAR_NAME);

    if( StrEqual(convarName, LOG_CONVAR_LEVEL_NAME) )
    {
        g_cvarLevel = convar.IntValue;
    }
    else if( StrEqual(convarName, LOG_CONVAR_LOCATION_NAME) )
    {
        g_cvarLocation = convar.IntValue;
    }
    else if( StrEqual(convarName, LOG_CONVAR_PARTS_NAME) )
    {
        g_cvarParts = convar.IntValue;
    }
}

// ================================= Native ==================================
void InitNatives()
{
    CreateNative("Log.Log",                     Native_LogConstructor);
    CreateNative("Log.Trace",                   Native_LogTrace);
    CreateNative("Log.Debug",                   Native_LogDebug);
    CreateNative("Log.Info",                    Native_LogInfo);
    CreateNative("Log.Warn",                    Native_LogWarn);
    CreateNative("Log.Error",                   Native_LogError);
    CreateNative("Log.Fatal",                   Native_LogFatal);
    CreateNative("Log.AssignOutput",            Native_AssignOutput);
}



// public native Log()
any Native_LogConstructor(Handle plugin, int numParams)
{
    return view_as<Log>( 0xf1f88 );
}

// public native void Trace(const char[] format, any ...);
void Native_LogTrace(Handle plugin, int numParams)
{
    // Check level permission
    if( ! (g_cvarLevel & LogLevel_Trace) || g_cvarLocation == LogLocation_OFF )
        return ;

    // tut: https://wiki.alliedmods.net/Creating_Natives_(SourceMod_Scripting)#Format_Functions
    FormatNativeString(0, 2, 3, LOG_MAX_USER_MESSAGE, _, g_userMessage, _);

    GetCallerFileName(g_logFileName, LOG_MAX_FILE_NAME);

    OutputPretty(true, LogLevel_Trace, g_cvarLocation, g_cvarParts, g_logFileName, g_userMessage);
}

// public native void Debug(const char[] format, any ...);
void Native_LogDebug(Handle plugin, int numParams)
{
    if( ! (g_cvarLevel & LogLevel_Debug) || g_cvarLocation == LogLocation_OFF )
        return ;

    FormatNativeString(0, 2, 3, LOG_MAX_USER_MESSAGE, _, g_userMessage);

    GetCallerFileName(g_logFileName, LOG_MAX_FILE_NAME);

    OutputPretty(false, LogLevel_Debug, g_cvarLocation, g_cvarParts, g_logFileName, g_userMessage);
}

// public native void Info(const char[] format, any ...);
void Native_LogInfo(Handle plugin, int numParams)
{
    if( ! (g_cvarLevel & LogLevel_Info) || g_cvarLocation == LogLocation_OFF )
        return ;

    FormatNativeString(0, 2, 3, LOG_MAX_USER_MESSAGE, _, g_userMessage);

    GetCallerFileName(g_logFileName, LOG_MAX_FILE_NAME);

    OutputPretty(false, LogLevel_Info, g_cvarLocation, g_cvarParts, g_logFileName, g_userMessage);
}

// public native void Warn(const char[] format, any ...);
void Native_LogWarn(Handle plugin, int numParams)
{
    if( ! (g_cvarLevel & LogLevel_Warn) || g_cvarLocation == LogLocation_OFF )
        return ;

    FormatNativeString(0, 2, 3, LOG_MAX_USER_MESSAGE, _, g_userMessage);

    GetCallerFileName(g_logFileName, LOG_MAX_FILE_NAME);

    OutputPretty(false, LogLevel_Warn, g_cvarLocation, g_cvarParts, g_logFileName, g_userMessage);
}

// public native void Error(const char[] format, any ...);
void Native_LogError(Handle plugin, int numParams)
{
    if( ! (g_cvarLevel & LogLevel_Error) || g_cvarLocation == LogLocation_OFF )
        return ;

    FormatNativeString(0, 2, 3, LOG_MAX_USER_MESSAGE, _, g_userMessage);

    GetCallerFileName(g_logFileName, LOG_MAX_FILE_NAME);

    OutputPretty(false, LogLevel_Error, g_cvarLocation, g_cvarParts, g_logFileName, g_userMessage);
}

// public native void Fatal(const char[] format, any ...);
void Native_LogFatal(Handle plugin, int numParams)
{
    if( ! (g_cvarLevel & LogLevel_Fatal) || g_cvarLocation == LogLocation_OFF )
        return ;

    FormatNativeString(0, 2, 3, LOG_MAX_USER_MESSAGE, _, g_userMessage);

    GetCallerFileName(g_logFileName, LOG_MAX_FILE_NAME);

    OutputPretty(true, LogLevel_Fatal, g_cvarLocation, g_cvarParts, g_logFileName, g_userMessage);
}

// public native void AssignOutput(int level, int location, int parts, const char[] format, any ...);
void Native_AssignOutput(Handle plugin, int numParams)
{
    FormatNativeString(0, 6, 7, LOG_MAX_USER_MESSAGE, _, g_userMessage);

    bool trace = GetNativeCell(2);
    int level = GetNativeCell(3);
    int location = GetNativeCell(4);
    int parts = GetNativeCell(5);

    GetCallerFileName(g_logFileName, LOG_MAX_FILE_NAME);

    OutputPretty(trace, level, location, parts, g_logFileName, g_userMessage);
}

// ================================= Common ==================================
void GetPartTime(char[] buffer, int maxlength)
{
    FormatTime(buffer, maxlength, NULL_STRING);
    StrCat(buffer, maxlength, " ");
}

void GetPartTickCount(char[] buffer, int maxlength)
{
    FormatEx(buffer, maxlength, "<%d> ", GetGameTickCount());
}

void GetPartLevelName(int level, char[] buffer, int maxlength)
{
    switch( level )
    {
        case LogLevel_Trace:    FormatEx(buffer, maxlength, "[%s]", LOG_LEVEL_NAME_TRACE);
        case LogLevel_Debug:    FormatEx(buffer, maxlength, "[%s]", LOG_LEVEL_NAME_DEBUG);
        case LogLevel_Info:     FormatEx(buffer, maxlength, "[%s]", LOG_LEVEL_NAME_INFO);
        case LogLevel_Warn:     FormatEx(buffer, maxlength, "[%s]", LOG_LEVEL_NAME_WARN);
        case LogLevel_Error:    FormatEx(buffer, maxlength, "[%s]", LOG_LEVEL_NAME_ERROR);
        case LogLevel_Fatal:    FormatEx(buffer, maxlength, "[%s]", LOG_LEVEL_NAME_FATAL);
        default :               buffer[0] = '\0';
    }
}

void GetCallerBrief(char[] buffer, int maxlength)
{
    char callerFile[LOG_MAX_FILE_NAME];
    char callerFunc[LOG_MAX_FUNC_NAME];
    int line;

    GetCallerInfo(callerFile, LOG_MAX_FILE_NAME, callerFunc, LOG_MAX_FUNC_NAME, line);
    FormatEx(buffer, maxlength, "(%s::%s::%d) - ", callerFile, callerFunc, line);
}

void GetCallerInfo(char[] callerFile, int maxlength, char[] callerFunction, int maxlength2, int &line)
{
    FrameIterator frames = new FrameIterator();
    char buffer[PLATFORM_MAX_PATH];

    // 先跳出当前栈
    while( frames.Next() )
    {
        frames.GetFunctionName(buffer, 2);

        if( ! buffer[0] )
        {
            frames.Next();
            frames.Next();
            break;
        }
    }

    // Stack Caller File Name
    frames.GetFilePath(buffer, PLATFORM_MAX_PATH);
    // buffer[ strlen(buffer) - 3 ] = '\0';                    // 除去文件名后缀 .sp
    int sepIndex = FindCharInString(buffer, '\\', true);    // 除去首部多余的路径
    if( sepIndex == -1 )                                    // 如果是 Linux 则查找 '/'
        sepIndex = FindCharInString(buffer, '/', true);
    strcopy(callerFile, maxlength, buffer[sepIndex + 1]);

    // Stack Caller Function Name
    frames.GetFunctionName(callerFunction, maxlength2);

    // Stack Caller Function Line
    line = frames.LineNumber;
    frames.Close();

    FormatEx(buffer, PLATFORM_MAX_PATH, "(%s::%s::%d)", callerFile, callerFunction, line);
}

void GetCallerFileName(char[] callerFile, int maxlength)
{
    FrameIterator frames = new FrameIterator();
    char buffer[PLATFORM_MAX_PATH];

    // 先跳出当前栈
    while( frames.Next() )
    {
        frames.GetFunctionName(buffer, 2);

        if( ! buffer[0] )
        {
            frames.Next();
            frames.Next();
            break;
        }
    }

    // Stack Caller File
    frames.GetFilePath(buffer, PLATFORM_MAX_PATH);
    frames.Close();

    // buffer[ strlen(buffer) - 3 ] = '\0';                    // 除去文件名后缀 .sp
    int sepIndex = FindCharInString(buffer, '\\', true);    // 除去首部多余的路径
    if( sepIndex == -1 )                                    // 如果是 Linux 则查找 '/'
        sepIndex = FindCharInString(buffer, '/', true);
    strcopy(callerFile, maxlength, buffer[sepIndex + 1]);
}




// 缓解 sv_logecho 日志回显导致的 控制台信息混乱不方便阅读的问题
void OutputPretty(bool trace, int level, int location, int parts, const char[] logFileName="", const char[] userMessage)
{
    for(int i=1; i<=LogLocation_ALL; i <<= 1)
    {
        if( ! (location & i) )
            continue;

        OutputMessageToLocation(level, i, parts, logFileName, userMessage);

        if( trace )
            OutputStackCallerToLocation(i, parts, logFileName);
    }
}

void OutputMessageToLocation(int level, int location, int parts, const char[] logFileName="", const char[] userMessage)
{
    char timeFmt[LOG_MAX_TIME];
    char tickCount[LOG_MAX_TICK_COUNT];
    char levelName[LOG_MAX_LEVEL_NAME];
    char callerBrief[LOG_MAX_CALLER_BRIEF];

    // Get Part - Time
    if( parts & LogParts_Time )
    {
        GetPartTime(timeFmt, LOG_MAX_TIME);
    }

    // Get Part - Tick Count
    if( parts & LogParts_TickCount )
    {
        GetPartTickCount(tickCount, LOG_MAX_TICK_COUNT);
    }

    // Get Part - Level Name
    if( parts & LogParts_Level )
    {
        GetPartLevelName(level, levelName, LOG_MAX_LEVEL_NAME);
    }

    // Get Part - Stack Caller Brief
    if( parts & LogParts_StackCallerBrief )
    {
        GetCallerBrief(callerBrief, LOG_MAX_CALLER_BRIEF);
    }


    if( location & LogLocation_ServerConsole )
    {
        PrintToServer("%s%s%s%s%s", timeFmt, tickCount, levelName, callerBrief, userMessage);
    }

    if( location & LogLocation_ClientConsoleAll )
    {
        PrintToConsoleAll("%s%s%s%s%s", timeFmt, tickCount, levelName, callerBrief, userMessage);
    }

    if( location & LogLocation_ClientChatAll )
    {
        PrintToChatAll("%s%s%s%s%s", timeFmt, tickCount, levelName, callerBrief, userMessage);
    }

    for(int client = 1; client <= MaxClients; ++client)
    {
        if( ! IsClientInGame(client) || GetUserAdmin(client) == INVALID_ADMIN_ID )
            continue;

        if( location & LogLocation_AdminConsoleAll )
        {
            PrintToConsole(client, "%s%s%s%s%s", timeFmt, tickCount, levelName, callerBrief, userMessage);
        }

        if( location & LogLocation_AdminChatAll )
        {
            PrintToChat(client, "%s%s%s%s%s", timeFmt, tickCount, levelName, callerBrief, userMessage);
        }
    }

    if( location & LogLocation_File )
    {
        if( ! logFileName[0] )
        {
            char buffer[LOG_MAX_FILE_NAME];
            GetCallerFileName(buffer, LOG_MAX_FILE_NAME);

            LogToFileEx(buffer, "%s%s%s%s", tickCount, levelName, callerBrief, userMessage);
        }
        else
        {
            LogToFileEx(logFileName, "%s%s%s%s", tickCount, levelName, callerBrief, userMessage);
        }
    }
}

void OutputStackCallerToLocation(int location, int parts, const char[] logFileName="")
{
    char timeFmt[LOG_MAX_TIME];
    char callerFilePath[PLATFORM_MAX_PATH];
    char callerFunc[LOG_MAX_FUNC_NAME];
    FrameIterator frames = new FrameIterator();

    // Get Part - Time
    if( parts & LogParts_Time )
    {
        GetPartTime(timeFmt, LOG_MAX_TIME);
    }

    // 先跳出当前栈
    while( frames.Next() )
    {
        frames.GetFunctionName(callerFunc, 2);

        if( ! callerFunc[0] )
        {
            // frames.Next();
            // frames.Next();
            break;
        }
    }

    for(int idx=0; frames.Next(); ++idx)
    {
        frames.GetFilePath(callerFilePath, PLATFORM_MAX_PATH);
        frames.GetFunctionName(callerFunc, LOG_MAX_FUNC_NAME);

        if( callerFilePath[0] )
        {
            if( location & LogLocation_ServerConsole )
            {
                PrintToServer("%s  [%d] Line %d, %s::%s", timeFmt, idx, frames.LineNumber, callerFilePath, callerFunc);
            }

            if( location & LogLocation_ClientConsoleAll )
            {
                PrintToConsoleAll("%s  [%d] Line %d, %s::%s", timeFmt, idx, frames.LineNumber, callerFilePath, callerFunc);
            }

            if( location & LogLocation_ClientChatAll )
            {
                PrintToChatAll("%s  [%d] Line %d, %s::%s", timeFmt, idx, frames.LineNumber, callerFilePath, callerFunc);
            }

            for(int client = 1; client <= MaxClients; ++client)
            {
                if( ! IsClientInGame(client) || GetUserAdmin(client) == INVALID_ADMIN_ID )
                    continue;

                if( location & LogLocation_AdminConsoleAll )
                {
                    PrintToConsole(client, "%s  [%d] Line %d, %s::%s", timeFmt, idx, frames.LineNumber, callerFilePath, callerFunc);
                }

                if( location & LogLocation_AdminChatAll )
                {
                    PrintToChat(client, "%s  [%d] Line %d, %s::%s", timeFmt, idx, frames.LineNumber, callerFilePath, callerFunc);
                }
            }

            if( location & LogLocation_File )
            {
                if( ! logFileName[0] )
                {
                    char buffer[LOG_MAX_FILE_NAME];
                    GetCallerFileName(buffer, LOG_MAX_FILE_NAME);

                    LogToFileEx(buffer, "  [%d] Line %d, %s::%s", idx, frames.LineNumber, callerFilePath, callerFunc);
                }
                else
                {
                    LogToFileEx(logFileName, "  [%d] Line %d, %s::%s", idx, frames.LineNumber, callerFilePath, callerFunc);
                }
            }
        }
        else if( callerFunc[0] )
        {
            if( location & LogLocation_ServerConsole )
            {
                PrintToServer("%s  [%d] %s", timeFmt, idx, callerFunc);
            }

            if( location & LogLocation_ClientConsoleAll )
            {
                PrintToConsoleAll("%s  [%d] %s", timeFmt, idx, callerFunc);
            }

            if( location & LogLocation_ClientChatAll )
            {
                PrintToChatAll("%s  [%d] %s", timeFmt, idx, callerFunc);
            }

            for(int client = 1; client <= MaxClients; ++client)
            {
                if( ! IsClientInGame(client) || GetUserAdmin(client) == INVALID_ADMIN_ID )
                    continue;

                if( location & LogLocation_AdminConsoleAll )
                {
                    PrintToConsole(client, "%s  [%d] %s", timeFmt, idx, callerFunc);
                }

                if( location & LogLocation_AdminChatAll )
                {
                    PrintToChat(client, "%s  [%d] %s", timeFmt, idx, callerFunc);
                }
            }

            if( location & LogLocation_File )
            {
                if( ! logFileName[0] )
                {
                    char buffer[LOG_MAX_FILE_NAME];
                    GetCallerFileName(buffer, LOG_MAX_FILE_NAME);

                    LogToFileEx(buffer, "  [%d] %s", idx, callerFunc);
                }
                else
                {
                    LogToFileEx(logFileName, "  [%d] %s", idx, callerFunc);
                }
            }
        }
    }
    frames.Close();
}
