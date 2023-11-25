# sm-logdebug
 Sourcemod logging library for plugins.

Adapted from [original version](https://forums.alliedmods.net/showthread.php?t=258855) by Dr. McKay.

---

This version adds second convar with the suffix "_parts", used for controlling which additional information is included in the messages.

For example:
- Time
- Tick count

It can also print caller source information from stack and is compatible with modern SourceMod.
