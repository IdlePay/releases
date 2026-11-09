# releases
IdlePay client binaries (GitHub Releases only)

## Docker

Multi-arch image (amd64, arm64, armv7) built from each release:

```bash
docker run -d --name idlepay --restart unless-stopped --hostname my-server \
  -e IDLEPAY_KEY=ipk_... -v idlepay:/etc/idlepay ghcr.io/idlepay/idlepay
```

- `IDLEPAY_KEY`: an enrollment key from Devices at https://app.idlepay.io. It's only used on first start; the device token is kept in the `/etc/idlepay` volume.
- `--hostname` is the device name shown in your dashboard.
- To share a VPN or extra IPs on the host, add `--network host`.

### Proxies

Mount a `proxies.txt` (one proxy per line, any common format) and choose whether this machine's own connection is shared too:

```bash
docker run -d --name idlepay --restart unless-stopped --hostname my-server \
  -e IDLEPAY_KEY=ipk_... -e IDLEPAY_DIRECT=off \
  -v idlepay:/etc/idlepay -v ${PWD}/proxies.txt:/proxies.txt:ro ghcr.io/idlepay/idlepay
```

- `/proxies.txt` is the whole list: it replaces the saved proxies on every start. Edit it and `docker restart idlepay` to apply.
- `IDLEPAY_DIRECT=off` shares only the proxies; `on` shares the host's connection too. Unset keeps the current setting (on for a new container).
- Without a mounted file, add proxies to a running container: `docker exec -i idlepay idlepay proxy add --file - < proxies.txt`
