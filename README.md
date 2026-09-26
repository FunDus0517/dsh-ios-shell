# DSH iOS 壳（DSHShell）

一个极简 iOS App：全屏 WebView 打开你电脑上的 DSH，省掉浏览器。地址可在 App 内修改并记住；
登录态持久化；局域网自签证书（192.168.x / *.ts.net）自动放行，公网域名仍走系统校验。

本仓库不含 `.xcodeproj`：工程由 `project.yml` 经 **XcodeGen** 生成，
因此可以在 **GitHub Actions 的 macOS runner** 上自动编译出 IPA —— Windows 上也能出包。

## 取 IPA

1. 把本仓库推到 GitHub（公开仓库不消耗 Actions 额度）
2. 打开 **Actions → build-ipa**，等它跑完（约 2–4 分钟）
3. 在该次运行的 **Artifacts** 里下载 `DSHShell-unsigned-ipa`，解压得到 `DSHShell.ipa`

## 装到 iPhone

未签名的 IPA 需要用你自己的 Apple ID 重签后才能安装（免费账号签名 **7 天**有效，到期重签）：

- **Sideloadly**（Windows 可用，推荐）：连上 iPhone，把 ipa 拖进去，填 Apple ID，Start
- **AltStore / SideStore**：在手机上装好 AltStore 后，用它的 "My Apps → +" 选 ipa

首次安装后要在 **设置 → 通用 → VPN与设备管理** 里信任你的开发者证书。

## App 里填什么地址

取决于你用哪条通道（都能填）：

| 场景 | 地址 | 说明 |
|---|---|---|
| 同一 WiFi | `http://192.168.1.9:19387` | 最快，直连电脑 |
| 在外面 | pocket 的公网地址（`https://xxx.trycloudflare.com`）+ 访问密码 | 由 dsh-pocket 提供 |
| DeepPilot 局域网 | `https://192.168.1.9:3098` | 自签证书，App 会自动放行 |

> 地址变了就在 App 底部工具栏点「地址」重填一次，它记在本地。
