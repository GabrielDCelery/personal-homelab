# Things that were set up manually

## Cloudflare API key

The Cloudflare API key was set up via `Profile` -> `API Tokens`. The various permissions can be seen here [Cloudflare API token permissions](https://developers.cloudflare.com/fundamentals/api/reference/permissions/)

Permissions I ended up adding:

| Permission                                                           | Why                                                      |
| -------------------------------------------------------------------- | -------------------------------------------------------- |
| Account - Cloudflare Tunnel - Edit                                   | To be able to create a cloudflare tunnel for the homelab |
| Account - DNS Settings - Edit                                        |                                                          |
| Account - Zero Trust - Edit                                          |                                                          |
| Account - Access Organizations, Identity Providers and Groups - Edit |                                                          |
| Account - Account Settings - Read                                    |                                                          |
| Account - Access: Apps and Policies - Edit                           |                                                          |
| Zone - DNS - Edit                                                    |                                                          |
