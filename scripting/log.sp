#pragma newdecls required
#pragma semicolon 1

#include <log_native>

#define PLUGIN_NAME                         "logger"
#define PLUGIN_AUTHOR                       "F1F88"
#define PLUGIN_DESCRIPTION                  "A simple sm logging framework"
#define PLUGIN_VERSION	                    "1.1.0"
#define PLUGIN_URL                          "https://github.com/F1F88/sm-logdebug"

public Plugin myinfo =
{
    name        = PLUGIN_NAME,
    author      = PLUGIN_AUTHOR,
    description = PLUGIN_DESCRIPTION,
    version     = PLUGIN_VERSION,
    url         = PLUGIN_URL
};

// 定义 ConVar 信息, 方便后期修改
#define LOG_CONVAR_LEVEL_DEFAULT            "62"
#define LOG_CONVAR_LEVEL_NAME               "sm_log_level"
#define LOG_CONVAR_LEVEL_DESC               "Add up values to enable debug logging to those level\n  0  = off\n  1  = trace\n  2  = debug\n  4  = info\n  8  = warn\n  16 = error\n  32 = fatal\n  63 = all\n"

#define LOG_CONVAR_LOCATION_DEFAULT         "37"
#define LOG_CONVAR_LOCATION_NAME            "sm_log_location"
#define LOG_CONVAR_LOCATION_DESC            "Add up values to enable debug logging to those locations\n  0  = off\n  1  = server console\n  2  = all clients' consoles\n  4  = consoles of admins\n  8  = all clients' chat\n  16 = chat of admins\n  32 = written to the 'logs/{pluginName}.log' file\n  63 = all\n"

#define LOG_CONVAR_PARTS_DEFAULT            "13"
#define LOG_CONVAR_PARTS_NAME               "sm_log_parts"
#define LOG_CONVAR_PARTS_DESC               "Add up values to set up additional information included in the logs\n  0  = only user message\n  1  = time\n  2  = tick count\n  4  = log level\n  8  = stack caller location in the following syntax sourcefile\n  16 = stack caller location in the following syntax sourcefile::function\n  32 = stack caller location in the following syntax sourcefile::function:line\n  39 = all"

#define LOG_CONVAR_ADMIN_FLAGS_DEFAULT      "2"
#define LOG_CONVAR_ADMIN_FLAGS_NAME         "sm_log_admin_flags"
#define LOG_CONVAR_ADMIN_FLAGS_DESC         "One or more admin flagbits which define whether a user is an \"admin\". If you pass multiple flags, users will need ALL flags."

#define LOG_CONVAR_VERSION_DEFAULT          PLUGIN_VERSION
#define LOG_CONVAR_VERSION_NAME             "sm_log_version"
#define LOG_CONVAR_VERSION_DESC             PLUGIN_DESCRIPTION

// 缓存 convar 值, 这样比调用 convar.typeValue 效率更高
static int g_cvarLevel;
static int g_cvarLocation;
static int g_cvarParts;
static int g_cvarAdminFlags;

// 方法共用
char g_logTag[LOG_MAX_LOG_TAG];
char g_logFilePath[LOG_MAX_FILE];
char g_userMessage[LOG_MAX_USER_MESSAGE];

char g_timeFmt[LOG_MAX_TIME_FORMAT];
char g_tickCount[LOG_MAX_TICK_COUNT];
char g_levelName[LOG_MAX_LEVEL_NAME];
char g_callerFile[LOG_MAX_FILE];
char g_callerFunc[LOG_MAX_FUNCTION];
char g_callerInfo[LOG_MAX_CALLER_BRIEF];

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
    convar = CreateConVar(LOG_CONVAR_LEVEL_NAME, LOG_CONVAR_LEVEL_DEFAULT, LOG_CONVAR_LEVEL_DESC, _);
    convar.AddChangeHook(OnConVarChange);
    g_cvarLevel = convar.IntValue;

    // Log Location
    convar = CreateConVar(LOG_CONVAR_LOCATION_NAME, LOG_CONVAR_LOCATION_DEFAULT, LOG_CONVAR_LOCATION_DESC, _);
    convar.AddChangeHook(OnConVarChange);
    g_cvarLocation = convar.IntValue;

    // Log Message Parts
    convar = CreateConVar(LOG_CONVAR_PARTS_NAME, LOG_CONVAR_PARTS_DEFAULT, LOG_CONVAR_PARTS_DESC, _);
    convar.AddChangeHook(OnConVarChange);
    g_cvarParts = convar.IntValue;

    // Log admin flags
    convar = CreateConVar(LOG_CONVAR_ADMIN_FLAGS_NAME, LOG_CONVAR_ADMIN_FLAGS_DEFAULT, LOG_CONVAR_ADMIN_FLAGS_DESC, _);
    convar.AddChangeHook(OnConVarChange);
    g_cvarAdminFlags = convar.IntValue;

    // Log Version
    CreateConVar(LOG_CONVAR_VERSION_NAME, LOG_CONVAR_VERSION_DEFAULT, LOG_CONVAR_VERSION_DESC, FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_PLUGIN|FCVAR_SPONLY);

    AutoExecConfig(true, PLUGIN_NAME);
}

void OnConVarChange(ConVar convar, char[] old_value, char[] new_value)
{
    if( convar == null )
        return ;

    char convarName[32];
    convar.GetName(convarName, sizeof(convarName));

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
    else if( StrEqual(convarName, LOG_CONVAR_ADMIN_FLAGS_NAME) )
    {
        g_cvarAdminFlags = convar.IntValue;
    }
}

// ================================= Native ==================================
void InitNatives()
{
    CreateNative("_LevelAccess",            Native_LevelAccess);
    CreateNative("_LocationAccess",         Native_LocationAccess);
    CreateNative("_OutputLogMessage",       Native_OutputLogMessage);
}


// native bool _LevelAccess(int level);
any Native_LevelAccess(Handle plugin, int numParams)
{
    int level = GetNativeCell(1);
    return (level & g_cvarLevel) != 0;
}

// native bool _LocationAccess();
any Native_LocationAccess(Handle plugin, int numParams)
{
    return g_cvarLocation != LogLocation_OFF;
}

// native void _OutputLogMessage(int level, const char[] logTag, const char[] logFileName, const char[] userMessage);
void Native_OutputLogMessage(Handle plugin, int numParams)
{
    int level = GetNativeCell(1);

    GetNativeString(2, g_logTag, sizeof(g_logTag));
    GetNativeString(3, g_logFilePath, sizeof(g_logFilePath));
    GetNativeString(4, g_userMessage, sizeof(g_userMessage));

    OutputMessageToLocation(level, g_logTag, g_logFilePath, g_userMessage);

    if( (level & LogLevel_Trace) || (level & LogLevel_Fatal) )
        OutputStackCallerToLocation(g_logTag, g_logFilePath);
}


void OutputMessageToLocation(int level, const char[] logTag, const char[] logFilePath, const char[] userMessage)
{
    // Get Part - Time
    if( g_cvarParts & LogParts_Time )
    {
        GetPartTime(g_timeFmt, sizeof(g_timeFmt));
    }
    else
    {
        g_timeFmt[0] = '\0';
    }

    // Get Part - Tick Count
    if( g_cvarParts & LogParts_TickCount )
    {
        GetPartTickCount(g_tickCount, sizeof(g_tickCount));
    }
    else
    {
        g_tickCount[0] = '\0';
    }

    // Get Part - Level Name
    if( g_cvarParts & LogParts_Level )
    {
        GetPartLevelName(level, g_levelName, sizeof(g_levelName));
    }
    else
    {
        g_levelName[0] = '\0';
    }

    // Get Part - Stack Caller Brief
    PrintToServer(" === Stack Caller Brief | %d | %d | %d | %d", g_cvarParts, g_cvarParts & LogParts_StackCallerFile, g_cvarParts & LogParts_StackCallerFileAndFunc, g_cvarParts & LogParts_StackCallerFileAndFuncAndLine);
    if( g_cvarParts & LogParts_StackCallerFile )
    {
        int line;
        GetCallerInfo(g_callerFile, sizeof(g_callerFile), g_callerFunc, sizeof(g_callerFunc), line);
        FormatEx(g_callerInfo, sizeof(g_callerInfo), "(%s) ", g_callerFile);
    }
    else if( g_cvarParts & LogParts_StackCallerFileAndFunc )
    {
        int line;
        GetCallerInfo(g_callerFile, sizeof(g_callerFile), g_callerFunc, sizeof(g_callerFunc), line);
        FormatEx(g_callerInfo, sizeof(g_callerInfo), "(%s::%s) ", g_callerFile, g_callerFunc);
    }
    else if( g_cvarParts & LogParts_StackCallerFileAndFuncAndLine )
    {
        int line;
        GetCallerInfo(g_callerFile, sizeof(g_callerFile), g_callerFunc, sizeof(g_callerFunc), line);
        FormatEx(g_callerInfo, sizeof(g_callerInfo), "(%s::%s::%s) ", g_callerFile, g_callerFunc, line);
    }
    else
    {
        g_callerInfo[0] = '\0';
    }


    if( g_cvarLocation & LogLocation_ServerConsole )
    {
        PrintToServer("%s%s%s%s%s%s", g_timeFmt, g_tickCount, g_levelName, g_callerInfo, logTag, userMessage);
    }

    if( g_cvarLocation & LogLocation_ClientConsoleAll )
    {
        PrintToConsoleAll("%s%s%s%s%s%s", g_timeFmt, g_tickCount, g_levelName, g_callerInfo, logTag, userMessage);
    }

    if( g_cvarLocation & LogLocation_ClientChatAll )
    {
        PrintToChatAll("%s%s%s%s%s", g_tickCount, g_levelName, g_callerInfo, logTag, userMessage);
    }

    for(int client = 1; client <= MaxClients; ++client)
    {
        if( ! IsClientInGame(client) || ! CheckCommandAccess(client, NULL_STRING, g_cvarAdminFlags, true) )
            continue;

        if( g_cvarLocation & LogLocation_AdminConsoleAll )
        {
            PrintToConsole(client, "%s%s%s%s%s%s", g_timeFmt, g_tickCount, g_levelName, g_callerInfo, logTag, userMessage);
        }

        if( g_cvarLocation & LogLocation_AdminChatAll )
        {
            PrintToChat(client, "%s%s%s%s%s", g_tickCount, g_levelName, g_callerInfo, logTag, userMessage);
        }
    }

    if( g_cvarLocation & LogLocation_File )
    {
        LogToFileEx(logFilePath, "%s%s%s%s%s", g_tickCount, g_levelName, g_callerInfo, logTag, userMessage);
    }
}

void OutputStackCallerToLocation(const char[] logTag, const char[] logFilePath)
{
    // Get Part - Time
    if( g_cvarParts & LogParts_Time )
    {
        GetPartTime(g_timeFmt, sizeof(g_timeFmt));
    }
    else
    {
        g_timeFmt[0] = '\0';
    }

    FrameIterator frames = new FrameIterator();

    // 先跳出当前栈
    while( frames.Next() )
    {
        frames.GetFunctionName(g_callerFunc, 2);

        if( ! g_callerFunc[0] )
        {
            frames.Next();
            // frames.Next();
            break;
        }
    }

    for(int idx=0; frames.Next(); ++idx)
    {
        frames.GetFilePath(g_callerFile, sizeof(g_callerFile));
        frames.GetFunctionName(g_callerFunc, sizeof(g_callerFunc));

        if( g_callerFile[0] && idx > 0 )
        {
            if( g_cvarLocation & LogLocation_ServerConsole )
            {
                PrintToServer("%s%s  [%d] Line %d, %s::%s", g_timeFmt, logTag, idx, frames.LineNumber, g_callerFile, g_callerFunc);
            }

            if( g_cvarLocation & LogLocation_ClientConsoleAll )
            {
                PrintToConsoleAll("%s%s  [%d] Line %d, %s::%s", g_timeFmt, logTag, idx, frames.LineNumber, g_callerFile, g_callerFunc);
            }

            if( g_cvarLocation & LogLocation_ClientChatAll )
            {
                PrintToChatAll("%s  [%d] Line %d, %s::%s", logTag, idx, frames.LineNumber, g_callerFile, g_callerFunc);
            }

            for(int client = 1; client <= MaxClients; ++client)
            {
                if( ! IsClientInGame(client) || ! CheckCommandAccess(client, NULL_STRING, g_cvarAdminFlags, true) )
                    continue;

                if( g_cvarLocation & LogLocation_AdminConsoleAll )
                {
                    PrintToConsole(client, "%s%s  [%d] Line %d, %s::%s", g_timeFmt, logTag, idx, frames.LineNumber, g_callerFile, g_callerFunc);
                }

                if( g_cvarLocation & LogLocation_AdminChatAll )
                {
                    PrintToChat(client, "%s  [%d] Line %d, %s::%s", logTag, idx, frames.LineNumber, g_callerFile, g_callerFunc);
                }
            }

            if( g_cvarLocation & LogLocation_File )
            {
                LogToFileEx(logFilePath, "%s  [%d] Line %d, %s::%s", logTag, idx, frames.LineNumber, g_callerFile, g_callerFunc);
            }
        }
        else if( g_callerFunc[0] )
        {
            if( g_cvarLocation & LogLocation_ServerConsole )
            {
                PrintToServer("%s%s  [%d] %s", g_timeFmt, logTag, idx, g_callerFunc);
            }

            if( g_cvarLocation & LogLocation_ClientConsoleAll )
            {
                PrintToConsoleAll("%s%s  [%d] %s", g_timeFmt, logTag, idx, g_callerFunc);
            }

            if( g_cvarLocation & LogLocation_ClientChatAll )
            {
                PrintToChatAll("%s  [%d] %s", logTag, idx, g_callerFunc);
            }

            for(int client = 1; client <= MaxClients; ++client)
            {
                if( ! IsClientInGame(client) || ! CheckCommandAccess(client, NULL_STRING, g_cvarAdminFlags, true) )
                    continue;

                if( g_cvarLocation & LogLocation_AdminConsoleAll )
                {
                    PrintToConsole(client, "%s%s  [%d] %s", g_timeFmt, logTag, idx, g_callerFunc);
                }

                if( g_cvarLocation & LogLocation_AdminChatAll )
                {
                    PrintToChat(client, "%s  [%d] %s", logTag, idx, g_callerFunc);
                }
            }

            if( g_cvarLocation & LogLocation_File )
            {
                LogToFileEx(logFilePath, "%s  [%d] %s", logTag, idx, g_callerFunc);
            }
        }
    }
    frames.Close();
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
        case LogLevel_Trace:    FormatEx(buffer, maxlength, "<%s> ", LOG_LEVEL_NAME_TRACE);
        case LogLevel_Debug:    FormatEx(buffer, maxlength, "<%s> ", LOG_LEVEL_NAME_DEBUG);
        case LogLevel_Info:     FormatEx(buffer, maxlength, "<%s> ", LOG_LEVEL_NAME_INFO);
        case LogLevel_Warn:     FormatEx(buffer, maxlength, "<%s> ", LOG_LEVEL_NAME_WARN);
        case LogLevel_Error:    FormatEx(buffer, maxlength, "<%s> ", LOG_LEVEL_NAME_ERROR);
        case LogLevel_Fatal:    FormatEx(buffer, maxlength, "<%s> ", LOG_LEVEL_NAME_FATAL);
        default :               buffer[0] = '\0';
    }
}

void GetCallerInfo(char[] callerFile, int maxlength, char[] callerFunction, int maxlength2, int &line)
{
    FrameIterator frames = new FrameIterator();
    static char buffer[PLATFORM_MAX_PATH];

    // 先跳出当前栈
    while( frames.Next() )
    {
        frames.GetFunctionName(buffer, 2);

        if( ! buffer[0] )
        {
            frames.Next();
            frames.Next();
            frames.Next();
            break;
        }
    }

    // Stack Caller File Name
    frames.GetFilePath(buffer, sizeof(buffer));

    // Stack Caller Function Name
    frames.GetFunctionName(callerFunction, maxlength2);

    // Stack Caller Function Line
    line = frames.LineNumber;
    frames.Close();

    // buffer[ strlen(buffer) - 3 ] = '\0';                    // 除去文件名后缀 .sp
    int sepIndex = FindCharInString(buffer, '\\', true);    // 除去首部多余的路径
    if( sepIndex == -1 )                                    // 如果是 Linux 则查找 '/'
        sepIndex = FindCharInString(buffer, '/', true);

    strcopy(callerFile, maxlength, buffer[sepIndex + 1]);
}



