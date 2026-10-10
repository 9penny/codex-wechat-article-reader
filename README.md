# Codex WeChat Article Reader

A Windows-friendly Codex skill for reading public WeChat Official Account articles. It wraps [`wechat-article-fetcher`](https://github.com/mrlong0129/wechat-article-fetcher) with PowerShell so the command works without a preinstalled Python or `uv` setup and prints Chinese correctly in Windows consoles.

## Install the skill

Copy `SKILL.md` and `scripts/read-wechat.ps1` into:

```text
%USERPROFILE%\.codex\skills\wechat-article-fetcher\
```

Then send Codex a public `https://mp.weixin.qq.com/s/...` article link. The skill will run the PowerShell wrapper.

To invoke it directly:

```powershell
& "$HOME\.codex\skills\wechat-article-fetcher\scripts\read-wechat.ps1" -Url "https://mp.weixin.qq.com/s/<article-id>"
& "$HOME\.codex\skills\wechat-article-fetcher\scripts\read-wechat.ps1" -Url "https://mp.weixin.qq.com/s/<article-id>" -Format json
```

The first run downloads the official `uv` Windows binary into `%LOCALAPPDATA%\codex-wechat-article-reader`, then uses it to run the reader with an isolated Python 3.12 runtime. It does not add anything to PATH or modify global Python/Codex/Git settings. Network access to GitHub is required on first use.

## Scope

- Public articles only. It does not access logged-in, paid, follower-only, deleted, or blocked content.
- Verification pages are reported; CAPTCHAs are not solved or bypassed.
- Article text and images remain subject to their authors' rights. Summarize and link for ordinary research; obtain rights before republishing.

The upstream reader is MIT licensed. Its license does not grant rights to republish articles fetched with it.
