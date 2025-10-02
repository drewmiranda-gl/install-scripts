# Intro

What you need to know for a successful Graylog [Server] upgrade.

# Preparation

1. Review Graylog [Compatibility Matrix](https://go2docs.graylog.org/current/downloading_and_installing_graylog/compatibility_matrix.htm) to verify your dependencies meet the required Minimum/Maximum allowed versions.
1. Read Reelase notes, including any breaking changes
1. Assess your risk tolerance and if you need to make backups of MongoDB
    - NOTE: Graylog upgrades CANNOT be rolled back.
1. If you are using Data Node as your search backend, **upgrade Graylog first**, then Data Node, ensuring both are on the same release version.

# Upgrade Process

Upgrade to the next applicable Major/Minor version. Rise, Repeat until on latest version (or desired version).

# References/Resources

- Graylog [Compatibility Matrix](https://go2docs.graylog.org/current/downloading_and_installing_graylog/compatibility_matrix.htm)
- [Upgrade Path](https://go2docs.graylog.org/current/upgrading_graylog/upgrade_path.htm)
- [Upgrade Graylog](https://go2docs.graylog.org/current/upgrading_graylog/upgrading_graylog.html)