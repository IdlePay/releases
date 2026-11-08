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
- Add proxies to the same container: `docker exec -i idlepay idlepay proxy add --file - < proxies.txt`
- To share a VPN or extra IPs on the host, add `--network host`.
