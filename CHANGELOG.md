# Changelog

## v0.1.0

首个公开试玩版本。

- 支持右手 `Joy-Con (R)` 控制 Codex Desktop。
- 支持 `ZR` 长按触发 `Control + M` 语音听写。
- 支持 `X/B/Y/A` 上下左右、`R` 回车、`+` 删除与长按连续删除。
- 支持 `R3` 尝试切换 Plan mode。
- 支持 `Home` 触发控制器恢复扫描。
- 增加 raw HID 路由，补齐 macOS `GameController` 未暴露的 Joy-Con 右肩键、R3 和 Home。
- 菜单栏显示连接/电量状态，提供辅助功能设置、蓝牙设置和退出入口。
- 断连、恢复扫描和退出时释放 held keys，避免 `Control + M` 或连续删除卡住。
