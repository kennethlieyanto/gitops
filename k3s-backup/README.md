# k3s-backup

Pulls K3s SQLite backup from `kennethl-asuslaptop` via rsync over SSH.

## Install: NixOS (home-manager)

Add to your `home.nix`:

```nix
{ config, ... }:

let
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
in {
  systemd.user.services.k3s-sqlite-pull = {
    Unit.Description = "Pull K3s SQLite backup from homeserver";
    Service = {
      Type = "oneshot";
      ExecStart = create_symlink "${config.home.homeDirectory}/Projects/personal/homeserver/k3s-backup/pull-sqlite";
    };
  };

  systemd.user.timers.k3s-sqlite-pull = {
    Unit.Description = "K3s SQLite pull backup at 20:00";
    Timer = {
      OnCalendar = "*-*-* 20:00:00";
      RandomizedDelaySec = "2min";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
```

Then rebuild and enable the timer:

```bash
sudo nixos-rebuild switch --flake .#<host>
systemctl --user enable --now k3s-sqlite-pull.timer
```

## Install: Non-NixOS

Symlink the script somewhere on `$PATH`:

```bash
ln -sf $(pwd)/k3s-backup/pull-sqlite ~/.local/bin/
```

Create the service and timer units in `~/.config/systemd/user/`:

**~/.config/systemd/user/k3s-sqlite-pull.service**
```ini
[Unit]
Description=Pull K3s SQLite backup from homeserver

[Service]
Type=oneshot
ExecStart=%h/.local/bin/pull-sqlite
StandardOutput=journal
StandardError=journal
SyslogIdentifier=k3s-sqlite-pull
```

**~/.config/systemd/user/k3s-sqlite-pull.timer**
```ini
[Unit]
Description=K3s SQLite pull backup at 20:00 (or next boot if missed)

[Timer]
OnCalendar=*-*-* 20:00:00
RandomizedDelaySec=2min
Persistent=true

[Install]
WantedBy=timers.target
```

Then reload and enable:

```bash
systemctl --user daemon-reload
systemctl --user enable --now k3s-sqlite-pull.timer
```

## Test

```bash
systemctl --user start k3s-sqlite-pull.service
journalctl --user -u k3s-sqlite-pull.service -f
```

Check `/mnt/backup/k3s-backup/sqlite-backend/` for the tarball.
