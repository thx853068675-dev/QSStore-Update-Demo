# 轻启更新接入 Demo

在轻启·安装器「管理 → 我上架的应用 → 配置 → 应用内更新」复制应用的正式版更新链接。在 Demo 粘贴后点「测试更新弹窗」，再点「去安装器更新」，即可验证轻启直达对应应用详情。

Demo 的「检查更新」读取本仓库的公开 GitHub Release。只有正式版发布满一小时、且安装版本编号更低时才出现真实更新提醒。「测试更新弹窗」是单独的联调入口。

其他应用可以保留自己的版本检查和弹窗，点击更新按钮时调用：

```ts
await context.openLink('qingqi-installer://app/商店应用ID?preview=0', {
  appLinkingOnly: false
})
```

Demo 使用 DevEco Studio 构建。Release 提供无签名 HAP，用于安装器侧载。
