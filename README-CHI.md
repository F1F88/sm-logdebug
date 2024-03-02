# Logger | [English](./README.md)

基于 Sourcemod 的简易 Log 框架

### Feature

- 支持自定义日志信息输出的级别。

  > Trace, Debug, Info, Waring, Error, Fatal
  >
  > 当 `sm_log_level` 对应的 bit 位是 1 时才会输出。
  >
  > 若 `sm_log_level` == 0 ，则不会输出任何信息。

- 支持输出堆栈信息

  > 当日志级别为 Trace，Fatal 时，会在输出用户信息后额外输出堆栈调用信息（类似 LogStackTrace ）。

- 支持自定义日志输出的位置。

  > 当 `sm_log_location` == 0 ，不会发生任何事情。
  >
  > 当 `sm_log_location` 对应的 bit 位是 1 时，才会输出到对应位置。

- 支持自定义日志信息组成部分。

  > 当 `sm_log_parts` == 0 ，只输出用户日志。
  >
  > 当 `sm_log_parts` 对应的 bit 位是 1 时，才会在消息头前面附加其他信息。

- 支持自定义拥有什么权限的管理员可以接收到日志。

  > 当 `sm_log_admin_flags` == 0 时，所有 client 都能接收到日志。（不推荐，会与 LogLocation_Client*** 重复）
  >
  > 当 `sm_log_admin_flags` != 0 时，会根据管理员权限判断是否能够接收到日志。


- 支持添加消息头

  > 通过指定 logTag 可以在 parts 和用户日志的中间添加消息头。用于标识，如 [SM]

- 支持自定义日志信息组成部分-时间的格式

  > 时间格式取决于 `sm_datetime_format`

- 支持自定义日志文件名称

  > 默认会根据调用者文件名不同而写入不同的日志
  >
  > 文件存放在 "./game/addons/sourcemod/logs/{File}.log"

### Methodmap & Native

- Methodmap 使用起来更方便，功能更完善，占用性能略高，但影响不大。推荐使用
- Native 需要引入插件，功能不够完善，占用性能低。建议在对性能要求较高时才使用

###### 相同点

- 使用方法相同：切换时只需修改引入的 include
- API 相同：都提供了 1 个工厂方法和 6 个日志输出级别
- 输出格式相同：仅取决于 convar - parts 的值

###### 不同点

- methodmap 的使用仅需要在插件中引入 include - log_methodmap.inc
- methodmap 版额外支持每个插件使用自己专属的 convar 控制日志输出
- methodmap 版的版本号取决于引入的 log_methodmap.inc 的版本
- methodmap 版在同时输出到多个 location 时做了优化，使输出结果看起来更加美观
- methodmap 版的工厂方法中，convarTag 和 failOnCustomConVarExists 用于生成专属的日志控制 convar
- methodmap 版会创建 4 个全局 convar + 引入插件个数 * 6 个专属 convar
- methodmap 版使用了全局变量进行缓存，避免了重复创建 char array
- native 的使用不仅需要引入 include - log_native.inc，还需要添加 log.smx 插件
- native 版只能使用全局 convar 控制日志输出
- native 版的版本号取决于 log.sp 的版本
- native 版没有对同时输出到多个 location 的情况进行优化，性能更高，但输出的消息可能不便于查看
- native 版的工厂方法中，convarTag 和 failOnCustomConVarExists 是保留参数，无实际作用
- native 版只会创建 4 个全局 convar
- native 版在每次调用函数时，在栈空间内根据需要创建 char array

|         版本对比         |  log_native.inc  | log_methodmap.inc |                             说明                             |
| :----------------------: | :--------------: | :---------------: | :----------------------------------------------------------: |
| 全局 convar 控制日志输出 |        Y         |         Y         | sm_log_level<br>sm_log_location<br>sm_log_parts<br>sm_log_admin_flags |
| 专属 convar 控制日志输出 |        N         |         Y         |       sm\_{tag}\_global\_contral<br>sm\_{tag}\_\*\*\*        |
|    全局 convar 版本号    |        Y         |         N         |                       sm\_log\_version                       |
|    专属 convar 版本号    |        N         |         Y         |                   sm\_{tag}\_log\_version                    |
|   多 Location 格式优化   |        N         |         Y         |         优化后日志看起来更美观<br>但性能相对要慢一点         |
|     Chat 去日期优化      |        Y         |         Y         | 聊天框日志去除日期 part<br>避免日志过长<br>part - tick count 不受影响 |
|        引入难易度        | 头文件 + log.smx |  只需导入头文件   |                                                              |
|         运行耗时         |     相对较少     |     相对更多      |                                                              |
|         内存占用         |     相对较少     |     相对更多      |                                                              |

### 安装使用

##### methodmap

- 在你的插件中导入 `log_methodmap.inc` 头文件即可；
- 在你的插件中使用 `log_methodmap.inc` 提供的 API 编写插件。
- 将你的插件编译后的 smx 文件上传到  `./addons/sourcemod/plugins/`；
- 重启服务器或使用 `sm plugins load {pluginsName}` 来载入插件。

##### native

- 在你的插件里导入 `log_native.inc` 头文件；
- 在你的插件中使用 `log_native.inc` 提供的 API 编写插件。
- 将你的插件编译后的 smx 文件上传到  `./addons/sourcemod/plugins/`；
- 还需要将 `log.smx` 上传到 `./addons/sourcemod/plugins/`；
- 重启服务器或使用 `sm plugins load log` 来载入依赖插件；
- 重启服务器或使用 `sm plugins load {pluginsName}` 来载入插件。


### API 使用

- 参考 `log-***-example.sp`
