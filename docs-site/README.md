# JounceOne Documentation Site

Modern, responsive documentation site for the JounceOne web framework.

## 🌐 Live Site

**https://jounce-docs.fly.dev**

## 📁 Structure

```
docs-site/
├── index.html              # Landing page
├── css/
│   ├── style.css          # Main stylesheet
│   └── docs.css           # Documentation-specific styles
├── js/
│   └── main.js            # Interactive features
├── pages/
│   ├── getting-started.html  # Getting Started guide
│   ├── docs.html            # Full documentation
│   └── packages.html        # Package manager docs
├── Dockerfile             # Container configuration
├── nginx.conf             # Web server config
└── fly.toml               # Fly.io deployment config
```

## 🚀 Deployment

Deploy to Fly.io:
```bash
flyctl deploy --app jounce-docs
```

## 💰 Cost

- **$jnc/month** (Free tier)
- Auto-stop/start machines
- 2jncMB image size
