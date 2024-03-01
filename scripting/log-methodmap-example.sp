#pragma newdecls required
#pragma semicolon 1

#include <log_methodmap>


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
    // Logger log = Logger.GetLogger("tlog");
    Logger log = Logger.GetLogger("tlog", _, "[T-Log] ", "TLog");

    FindConVar("sm_tlog_log_global_contral").SetBool(false);
    FindConVar("sm_tlog_log_level").SetInt(LogLocation_ALL);
    FindConVar("sm_tlog_log_location").SetInt(LogLocation_ALL);
    FindConVar("sm_tlog_log_parts").SetInt(LogParts_ALL);

    int startTime, endTime;
    startTime = GetSysTickCount();

    log.Trace("%s  %s  %s",   "Test Log Trace", "hello", " Trace");
    log.Debug("%s  %s  %s",   "Test Log Debug", "hello", " Debug");
    log.Info("%s  %s  %s",    "Test Log Info",  "hello", " Info");
    log.Warn("%s  %s  %s",    "Test Log Warn",  "hello", " Warn");
    log.Error("%s  %s  %s",   "Test Log Error", "hello", " Error");
    log.Fatal("%s  %s  %s",   "Test Log Fatal", "hello", " Fatal");

    endTime = GetSysTickCount();
    PrintToServer("%d - %d = %d", endTime, startTime, endTime-startTime);
}


/**
 * Out Put
 * ========= Test Log  ==========
 * 2024/03/01 - 20:01:01 <67> <Trace> (log-methodmap-example.sp::test5::54) [T-Log] Test Log Trace  hello   Trace
 * 2024/03/01 - 20:01:01 [T-Log]   [0] Logger.Trace
 * 2024/03/01 - 20:01:01 [T-Log]   [1] Line 54, d:\sp\log\scripting\log-methodmap-example.sp::test5
 * 2024/03/01 - 20:01:01 [T-Log]   [2] Line 38, d:\sp\log\scripting\log-methodmap-example.sp::test4
 * 2024/03/01 - 20:01:01 [T-Log]   [3] Line 33, d:\sp\log\scripting\log-methodmap-example.sp::test3
 * 2024/03/01 - 20:01:01 [T-Log]   [4] Line 28, d:\sp\log\scripting\log-methodmap-example.sp::test2
 * 2024/03/01 - 20:01:01 [T-Log]   [5] Line 23, d:\sp\log\scripting\log-methodmap-example.sp::test1
 * 2024/03/01 - 20:01:01 [T-Log]   [6] Line 16, d:\sp\log\scripting\log-methodmap-example.sp::CMD_TestLog
 * L 03/01/2024 - 20:01:01: <67> <Trace> (log-methodmap-example.sp::test5::54) [T-Log] Test Log Trace  hello   Trace
 * L 03/01/2024 - 20:01:01: [T-Log]   [0] Logger.Trace
 * L 03/01/2024 - 20:01:01: [T-Log]   [1] Line 54, d:\sp\log\scripting\log-methodmap-example.sp::test5
 * L 03/01/2024 - 20:01:01: [T-Log]   [2] Line 38, d:\sp\log\scripting\log-methodmap-example.sp::test4
 * L 03/01/2024 - 20:01:01: [T-Log]   [3] Line 33, d:\sp\log\scripting\log-methodmap-example.sp::test3
 * L 03/01/2024 - 20:01:01: [T-Log]   [4] Line 28, d:\sp\log\scripting\log-methodmap-example.sp::test2
 * L 03/01/2024 - 20:01:01: [T-Log]   [5] Line 23, d:\sp\log\scripting\log-methodmap-example.sp::test1
 * L 03/01/2024 - 20:01:01: [T-Log]   [6] Line 16, d:\sp\log\scripting\log-methodmap-example.sp::CMD_TestLog
 * 2024/03/01 - 20:01:01 <67> <Debug> (log-methodmap-example.sp::test5::55) [T-Log] Test Log Debug  hello   Debug
 * L 03/01/2024 - 20:01:01: <67> <Debug> (log-methodmap-example.sp::test5::55) [T-Log] Test Log Debug  hello   Debug
 * 2024/03/01 - 20:01:01 <67> <Info> (log-methodmap-example.sp::test5::56) [T-Log] Test Log Info  hello   Info
 * L 03/01/2024 - 20:01:01: <67> <Info> (log-methodmap-example.sp::test5::56) [T-Log] Test Log Info  hello   Info
 * 2024/03/01 - 20:01:01 <67> <Warn> (log-methodmap-example.sp::test5::57) [T-Log] Test Log Warn  hello   Warn
 * L 03/01/2024 - 20:01:01: <67> <Warn> (log-methodmap-example.sp::test5::57) [T-Log] Test Log Warn  hello   Warn
 * 2024/03/01 - 20:01:01 <67> <Error> (log-methodmap-example.sp::test5::58) [T-Log] Test Log Error  hello   Error
 * L 03/01/2024 - 20:01:01: <67> <Error> (log-methodmap-example.sp::test5::58) [T-Log] Test Log Error  hello   Error
 * 2024/03/01 - 20:01:01 <67> <Fatal> (log-methodmap-example.sp::test5::59) [T-Log] Test Log Fatal  hello   Fatal
 * 2024/03/01 - 20:01:01 [T-Log]   [0] Logger.Fatal
 * 2024/03/01 - 20:01:01 [T-Log]   [1] Line 59, d:\sp\log\scripting\log-methodmap-example.sp::test5
 * 2024/03/01 - 20:01:01 [T-Log]   [2] Line 38, d:\sp\log\scripting\log-methodmap-example.sp::test4
 * 2024/03/01 - 20:01:01 [T-Log]   [3] Line 33, d:\sp\log\scripting\log-methodmap-example.sp::test3
 * 2024/03/01 - 20:01:01 [T-Log]   [4] Line 28, d:\sp\log\scripting\log-methodmap-example.sp::test2
 * 2024/03/01 - 20:01:01 [T-Log]   [5] Line 23, d:\sp\log\scripting\log-methodmap-example.sp::test1
 * 2024/03/01 - 20:01:01 [T-Log]   [6] Line 16, d:\sp\log\scripting\log-methodmap-example.sp::CMD_TestLog
 * L 03/01/2024 - 20:01:01: <67> <Fatal> (log-methodmap-example.sp::test5::59) [T-Log] Test Log Fatal  hello   Fatal
 * L 03/01/2024 - 20:01:01: [T-Log]   [0] Logger.Fatal
 * L 03/01/2024 - 20:01:01: [T-Log]   [1] Line 59, d:\sp\log\scripting\log-methodmap-example.sp::test5
 * L 03/01/2024 - 20:01:01: [T-Log]   [2] Line 38, d:\sp\log\scripting\log-methodmap-example.sp::test4
 * L 03/01/2024 - 20:01:01: [T-Log]   [3] Line 33, d:\sp\log\scripting\log-methodmap-example.sp::test3
 * L 03/01/2024 - 20:01:01: [T-Log]   [4] Line 28, d:\sp\log\scripting\log-methodmap-example.sp::test2
 * L 03/01/2024 - 20:01:01: [T-Log]   [5] Line 23, d:\sp\log\scripting\log-methodmap-example.sp::test1
 * L 03/01/2024 - 20:01:01: [T-Log]   [6] Line 16, d:\sp\log\scripting\log-methodmap-example.sp::CMD_TestLog
 * 456396309 - 456396309 = 0
 */
