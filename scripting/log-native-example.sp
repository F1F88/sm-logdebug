#pragma newdecls required
#pragma semicolon 1

#include <log_native>


public void OnPluginStart()
{
    RegConsoleCmd("tlog", CMD_TestLog);
}

Action CMD_TestLog(int client, any args)
{
    PrintToServer("========= Test Log  ==========");

    test1();

    return Plugin_Handled;
}

void test1()
{
    test2();
}

void test2()
{
    test3();
}

void test3()
{
    test4();
}

void test4()
{
    test5();
}

void test5()
{
    Logger log = Logger.GetLogger(NULL_STRING, _, "[T-Log-Native] ");

    // FindConVar("sm_log_level").SetInt(LogLevel_ALL);
    // FindConVar("sm_log_location").SetInt(LogLocation_ALL);
    // FindConVar("sm_log_parts").SetInt(LogParts_ALL);

    int startTime, endTime;
    startTime = GetSysTickCount();

    log.Trace("%s  %s  %s",   "Log Trace", "hello", " Trace");
    log.Debug("%s  %s  %s",   "Log Debug", "hello", " Debug");
    log.Info("%s  %s  %s",    "Log Info",  "hello", " Info");
    // log.Warn("%s  %s  %s",    "Log Warn",  "hello", " Warn");
    // log.Error("%s  %s  %s",   "Log Error", "hello", " Error");
    // log.Fatal("%s  %s  %s",   "Log Fatal", "hello", " Fatal");

    endTime = GetSysTickCount();
    PrintToServer("%d - %d = %d", endTime, startTime, endTime-startTime);
}


/**
 * Out Put
 * ========= Test Log  ==========
 * 2024/03/02 - 06:31:23 <21949> <Trace> (log-native-example.sp::test5::52) - [T-Log-Native] Log Trace  hello   Trace
 * L 03/02/2024 - 06:31:23: <21949> <Trace> (log-native-example.sp::test5::52) - [T-Log-Native] Log Trace  hello   Trace
 * 2024/03/02 - 06:31:23 [T-Log-Native]   [0] Logger.Trace
 * L 03/02/2024 - 06:31:23: [T-Log-Native]   [0] Logger.Trace
 * 2024/03/02 - 06:31:23 [T-Log-Native]   [1] Line 52, d:\sp\log\scripting\log-native-example.sp::test5
 * L 03/02/2024 - 06:31:23: [T-Log-Native]   [1] Line 52, d:\sp\log\scripting\log-native-example.sp::test5
 * 2024/03/02 - 06:31:23 [T-Log-Native]   [2] Line 38, d:\sp\log\scripting\log-native-example.sp::test4
 * L 03/02/2024 - 06:31:23: [T-Log-Native]   [2] Line 38, d:\sp\log\scripting\log-native-example.sp::test4
 * 2024/03/02 - 06:31:23 [T-Log-Native]   [3] Line 33, d:\sp\log\scripting\log-native-example.sp::test3
 * L 03/02/2024 - 06:31:23: [T-Log-Native]   [3] Line 33, d:\sp\log\scripting\log-native-example.sp::test3
 * 2024/03/02 - 06:31:23 [T-Log-Native]   [4] Line 28, d:\sp\log\scripting\log-native-example.sp::test2
 * L 03/02/2024 - 06:31:23: [T-Log-Native]   [4] Line 28, d:\sp\log\scripting\log-native-example.sp::test2
 * 2024/03/02 - 06:31:23 [T-Log-Native]   [5] Line 23, d:\sp\log\scripting\log-native-example.sp::test1
 * L 03/02/2024 - 06:31:23: [T-Log-Native]   [5] Line 23, d:\sp\log\scripting\log-native-example.sp::test1
 * 2024/03/02 - 06:31:23 [T-Log-Native]   [6] Line 16, d:\sp\log\scripting\log-native-example.sp::CMD_TestLog
 * L 03/02/2024 - 06:31:23: [T-Log-Native]   [6] Line 16, d:\sp\log\scripting\log-native-example.sp::CMD_TestLog
 * 2024/03/02 - 06:31:23 <21949> <Debug> (log-native-example.sp::test5::53) - [T-Log-Native] Log Debug  hello   Debug
 * L 03/02/2024 - 06:31:23: <21949> <Debug> (log-native-example.sp::test5::53) - [T-Log-Native] Log Debug  hello   Debug
 * 2024/03/02 - 06:31:23 <21949> <Info> (log-native-example.sp::test5::54) - [T-Log-Native] Log Info  hello   Info
 * L 03/02/2024 - 06:31:23: <21949> <Info> (log-native-example.sp::test5::54) - [T-Log-Native] Log Info  hello   Info
 * 494126649 - 494126649 = 0
 *
 * sv_logecho 0
 *
 * ========= Test Log  ==========
 * 2024/03/02 - 06:33:10 <29085> <Trace> (log-native-example.sp::test5::52) - [T-Log-Native] Log Trace  hello   Trace
 * 2024/03/02 - 06:33:10 [T-Log-Native]   [0] Logger.Trace
 * 2024/03/02 - 06:33:10 [T-Log-Native]   [1] Line 52, d:\sp\log\scripting\log-native-example.sp::test5
 * 2024/03/02 - 06:33:10 [T-Log-Native]   [2] Line 38, d:\sp\log\scripting\log-native-example.sp::test4
 * 2024/03/02 - 06:33:10 [T-Log-Native]   [3] Line 33, d:\sp\log\scripting\log-native-example.sp::test3
 * 2024/03/02 - 06:33:10 [T-Log-Native]   [4] Line 28, d:\sp\log\scripting\log-native-example.sp::test2
 * 2024/03/02 - 06:33:10 [T-Log-Native]   [5] Line 23, d:\sp\log\scripting\log-native-example.sp::test1
 * 2024/03/02 - 06:33:10 [T-Log-Native]   [6] Line 16, d:\sp\log\scripting\log-native-example.sp::CMD_TestLog
 * 2024/03/02 - 06:33:10 <29085> <Debug> (log-native-example.sp::test5::53) - [T-Log-Native] Log Debug  hello   Debug
 * 2024/03/02 - 06:33:10 <29085> <Info> (log-native-example.sp::test5::54) - [T-Log-Native] Log Info  hello   Info
 * 494233689 - 494233689 = 0
 */
