# Hermes Agent on Render.com

Deploy [Hermes Agent](https://hermes-agent.nousresearch.com) on Render's free tier for 24/7 Telegram bot operation. No credit card needed.

## Architecture

```
Telegram → POST /webhook → Render (Docker) → Hermes Gateway → LLM → responds
                                    ↑
               UptimeRobot pings /health every 5 min (keeps it awake)
```

## Quick Start (one-time setup)

### 1. Sign up for Render

1. Go to https://dashboard.render.com/register
2. Sign up with Email, GitHub, GitLab, Bitbucket, or Google
3. No credit card required, Hobby plan is $0/month

### 2. Create a Web Service

1. In Render dashboard, click **New +** → **Web Service**
2. Connect this GitHub repo (https://github.com/PradyolSarvasiddi/hermes-render)
3. Settings:
   - **Name**: `hermes-agent`
   - **Branch**: `main`
   - **Environment**: `Docker`
   - **Instance Type**: **Free** ($0/month)
   - **Health Check Path**: (leave blank — Hermes doesn't have one by default)

### 3. Set Environment Variables

In Render dashboard → your service → **Environment** tab → **Add Secret File** or **Add Environment Variable**:

| Variable | Value | How to get it |
|----------|-------|---------------|
| `TELEGRAM_BOT_TOKEN` | your bot token | From [@BotFather](https://t.me/botfather) on Telegram |
| `TELEGRAM_WEBHOOK_URL` | `https://hermes-agent.onrender.com/webhook` | Your Render service URL + `/webhook` |
| `TELEGRAM_WEBHOOK_PORT` | `10000` | Render free tier default port |
| `TELEGRAM_WEBHOOK_SECRET` | a random string | Generate: `python3 -c "import secrets; print(secrets.token_urlsafe(32))"` |
| `OPENCODE_ZEN_API_KEY` | your API key | From your LLM provider |

### 4. Deploy

Click **Create Web Service**. Render builds and deploys (3–5 min).

### 5. Sign up for UptimeRobot (keep it awake)

1. Go to https://uptimerobot.com/signup — sign up with email (no CC)
2. Click **Add New Monitor**
3. Monitor Type: **HTTP(s)**
4. Friendly Name: `Hermes Keepalive`
5. URL: `https://hermes-agent.onrender.com/health`
6. Monitoring Interval: **5 minutes**
7. Click **Create Monitor**

### 6. Test

Send a message to your bot on Telegram. It should respond immediately.

### 7. Stop local gateway (if running)

```bash
hermes gateway stop
launchctl disable gui/$(id -u)/ai.hermes.gateway
```

Then close your laptop — Hermes keeps running on Render.

## Troubleshooting

- **Bot not responding**: Check Render logs (dashboard → your service → Logs). The gateway should print webhook registration details at startup.
- **Webhook not registering**: Ensure `TELEGRAM_WEBHOOK_URL` ends with `/webhook` and `TELEGRAM_WEBHOOK_PORT` matches `$PORT` on Render.
- **Service sleeping**: UptimeRobot pings every 5 min keep it alive. If it sleeps anyway, cold start is ~60 seconds.
