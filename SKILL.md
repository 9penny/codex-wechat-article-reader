---
name: wechat-article-fetcher
description: Read public WeChat Official Account articles from mp.weixin.qq.com links and return clean Markdown or a summary with source details. Use whenever the user shares a WeChat article link or asks to read, summarize, or save one. Does not access private, paid, follower-only, or deleted content, and does not bypass verification.
metadata:
  short-description: Read public WeChat articles
---

# Read WeChat Official Account articles

When the user provides an `mp.weixin.qq.com` article link, fetch the public article and use its content to answer the request. Prefer this repository's PowerShell wrapper, which handles Windows UTF-8 output and bootstraps a user-local `uv` runtime when needed.

Run from PowerShell:

```powershell
& "$HOME\.codex\skills\wechat-article-fetcher\scripts\read-wechat.ps1" -Url "https://mp.weixin.qq.com/s/<article-id>"
```

Use `-Format json` when structured metadata or the image list is useful. Multiple URLs can be passed as an array. The wrapper stores `uv`, its cache, and its isolated Python runtime under `%LOCALAPPDATA%\codex-wechat-article-reader`; it does not change PATH, install Python globally, or modify Codex/Git settings. The first run needs network access to GitHub to obtain `uv` and the reader package.

If the wrapper cannot run, try the available browser or web-reading tool. If neither can expose the article text, ask the user for pasted text or a saved HTML page; the CLI supports parsing saved pages with `--from-html`.

## Interpret the result

- Treat title, account name, author, and publication time as extracted metadata; flag absent or uncertain fields.
- Summarize and quote only what the user requested. Keep the article link as the source and distinguish the article's claims from independently verified facts.
- Do not assume `mmbiz.qpic.cn` image URLs are durable or authorized as a website image host.
- Successful extraction does not establish that the article's claims are accurate.

## Access and copyright limits

Public articles only. If the reader reports verification, deletion, violation, invalid URL, or access failure, report the result and stop. Do not retry in a loop, solve CAPTCHAs, use logged-in credentials, or attempt to access paid or follower-only material. For a verification page, the user can open the article in WeChat and paste the text or provide saved HTML for offline parsing.

For ordinary reading and research, summarize and link to the source rather than reproducing the full article. Do not republish article text or images without applicable rights or authorization.

Reader project: https://github.com/mrlong0129/wechat-article-fetcher (MIT licensed; articles retain their authors' rights).
