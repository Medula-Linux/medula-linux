# Medula Linux

**The core that adapts to every use.**

Medula Linux is a profile-driven Linux distribution based on Debian. During installation, users choose the profiles that fit their needs — Desktop, Pentesting, Server, or Development — and only the relevant tools get installed.

![Status](https://img.shields.io/badge/status-in%20development-yellow)
![License](https://img.shields.io/badge/license-MIT-blue)
![Base](https://img.shields.io/badge/base-Debian%2012-orange)

## Profiles

- **Desktop** — KDE Plasma, office suite, media tools, gaming support
- **Pentest** — Security and penetration testing tools
- **Server** — Headless server essentials (SSH, web server, containers)
- **Dev** — Development tools and languages

Profiles are not exclusive — select as many as you need during install.

## Status

Early development. Not ready for daily use yet.

## Building from source

This project uses `live-build` to generate the ISO. See `config/` for package lists per profile.

## License

MIT
