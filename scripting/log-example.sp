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
    Log log = Log();

    FindConVar("sm_log_level").SetInt(LogLevel_ALL);
    FindConVar("sm_log_location").SetInt(LogLocation_ALL);
    FindConVar("sm_log_parts").SetInt(LogParts_ALL);

    int startTime, endTime;
    startTime = GetSysTickCount();

    log.Trace("%s  %s  %s",   "Log Trace", "hello", " Trace");
    log.Debug("%s  %s  %s",   "Log Debug", "hello", " Debug");
    log.Info("%s  %s  %s",    "Log Info",  "hello", " Info");
    log.Warn("%s  %s  %s",    "Log Warn",  "hello", " Warn");
    log.Error("%s  %s  %s",   "Log Error", "hello", " Error");
    log.Fatal("%s  %s  %s",   "Log Fatal", "hello", " Fatal");

    endTime = GetSysTickCount();
    PrintToServer("%d - %d = %d", endTime, startTime, endTime-startTime);
}


/**
 * Out Put
 * ========= Test Log  ==========
 * 2024/02/26 - 00:05:57 <67> [TRACE](log-example.sp::test5::52) - Log Trace  hello   Trace
 * 2024/02/26 - 00:05:57   [0] Log.Trace
 * 2024/02/26 - 00:05:57   [1] Line 52, d:\sp\sm-logdebug\scripting\log-example.sp::test5
 * 2024/02/26 - 00:05:57   [2] Line 38, d:\sp\sm-logdebug\scripting\log-example.sp::test4
 * 2024/02/26 - 00:05:57   [3] Line 33, d:\sp\sm-logdebug\scripting\log-example.sp::test3
 * 2024/02/26 - 00:05:57   [4] Line 28, d:\sp\sm-logdebug\scripting\log-example.sp::test2
 * 2024/02/26 - 00:05:57   [5] Line 23, d:\sp\sm-logdebug\scripting\log-example.sp::test1
 * 2024/02/26 - 00:05:57   [6] Line 16, d:\sp\sm-logdebug\scripting\log-example.sp::CMD_TestLog
 * L 02/26/2024 - 00:05:57: <67> [TRACE](log-example.sp::test5::52) - Log Trace  hello   Trace
 * L 02/26/2024 - 00:05:57:   [0] Log.Trace
 * L 02/26/2024 - 00:05:57:   [1] Line 52, d:\sp\sm-logdebug\scripting\log-example.sp::test5
 * L 02/26/2024 - 00:05:57:   [2] Line 38, d:\sp\sm-logdebug\scripting\log-example.sp::test4
 * L 02/26/2024 - 00:05:57:   [3] Line 33, d:\sp\sm-logdebug\scripting\log-example.sp::test3
 * L 02/26/2024 - 00:05:57:   [4] Line 28, d:\sp\sm-logdebug\scripting\log-example.sp::test2
 * L 02/26/2024 - 00:05:57:   [5] Line 23, d:\sp\sm-logdebug\scripting\log-example.sp::test1
 * L 02/26/2024 - 00:05:57:   [6] Line 16, d:\sp\sm-logdebug\scripting\log-example.sp::CMD_TestLog
 * 2024/02/26 - 00:05:57 <67> [DEBUG](log-example.sp::test5::53) - Log Debug  hello   Debug
 * L 02/26/2024 - 00:05:57: <67> [DEBUG](log-example.sp::test5::53) - Log Debug  hello   Debug
 * 2024/02/26 - 00:05:57 <67> [INFO](log-example.sp::test5::54) - Log Info  hello   Info
 * L 02/26/2024 - 00:05:57: <67> [INFO](log-example.sp::test5::54) - Log Info  hello   Info
 * 2024/02/26 - 00:05:57 <67> [WARN](log-example.sp::test5::55) - Log Warn  hello   Warn
 * L 02/26/2024 - 00:05:57: <67> [WARN](log-example.sp::test5::55) - Log Warn  hello   Warn
 * 2024/02/26 - 00:05:57 <67> [ERROR](log-example.sp::test5::56) - Log Error  hello   Error
 * L 02/26/2024 - 00:05:57: <67> [ERROR](log-example.sp::test5::56) - Log Error  hello   Error
 * 2024/02/26 - 00:05:57 <67> [FATAL](log-example.sp::test5::57) - Log Fatal  hello   Fatal
 * 2024/02/26 - 00:05:57   [0] Log.Fatal
 * 2024/02/26 - 00:05:57   [1] Line 57, d:\sp\sm-logdebug\scripting\log-example.sp::test5
 * 2024/02/26 - 00:05:57   [2] Line 38, d:\sp\sm-logdebug\scripting\log-example.sp::test4
 * 2024/02/26 - 00:05:57   [3] Line 33, d:\sp\sm-logdebug\scripting\log-example.sp::test3
 * 2024/02/26 - 00:05:57   [4] Line 28, d:\sp\sm-logdebug\scripting\log-example.sp::test2
 * 2024/02/26 - 00:05:57   [5] Line 23, d:\sp\sm-logdebug\scripting\log-example.sp::test1
 * 2024/02/26 - 00:05:57   [6] Line 16, d:\sp\sm-logdebug\scripting\log-example.sp::CMD_TestLog
 * L 02/26/2024 - 00:05:57: <67> [FATAL](log-example.sp::test5::57) - Log Fatal  hello   Fatal
 * L 02/26/2024 - 00:05:57:   [0] Log.Fatal
 * L 02/26/2024 - 00:05:57:   [1] Line 57, d:\sp\sm-logdebug\scripting\log-example.sp::test5
 * L 02/26/2024 - 00:05:57:   [2] Line 38, d:\sp\sm-logdebug\scripting\log-example.sp::test4
 * L 02/26/2024 - 00:05:57:   [3] Line 33, d:\sp\sm-logdebug\scripting\log-example.sp::test3
 * L 02/26/2024 - 00:05:57:   [4] Line 28, d:\sp\sm-logdebug\scripting\log-example.sp::test2
 * L 02/26/2024 - 00:05:57:   [5] Line 23, d:\sp\sm-logdebug\scripting\log-example.sp::test1
 * L 02/26/2024 - 00:05:57:   [6] Line 16, d:\sp\sm-logdebug\scripting\log-example.sp::CMD_TestLog
 * 39000919 - 39000919 = 0
 */
