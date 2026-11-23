# 轻启更新接入 Demo

启动 Demo，点击「测试更新弹窗 → 去安装器更新」。轻启·安装器会打开此 Demo 的商店详情（ID 407）。

其他应用自行实现版本检测和更新弹窗。上架者可在轻启·安装器「管理 → 我上架的应用 → 配置 → 应用内更新」复制自己的链接，再绑定到弹窗的更新按钮。

```ts
await context.openLink('qingqi-installer://app/407?preview=0', {
  appLinkingOnly: false
})
```

Demo 用于直接验证跳转。Release 提供无签名 HAP，用于安装器侧载。
