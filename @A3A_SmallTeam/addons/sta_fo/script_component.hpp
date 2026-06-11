#define COMPONENT sta_fo
#define COMPONENT_BEAUTIFIED STA FO
// TODO: restore CBA header and replace hardcoded paths with QPATHTOFOLDER macro (post-testing cleanup):
// #include "\x\cba\addons\main\script_macros.hpp"

// Stub Antistasi logging macro used in the verbatim artySupport override.
// CBA's real Error_4 routes to CBA_fnc_error; this falls back to RPT logging.
#define Error_4(MESSAGE,A,B,C,D) diag_log format [MESSAGE, A, B, C, D, ""]
