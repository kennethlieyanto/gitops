## Backup

```sh
docker run --rm -v "fireflyiii_firefly_iii_db:/tmp" \
    -v "$HOME/backups/firefly:/backup" \
    ubuntu tar -czvf /backup/firefly_db.tar.gz /tmp
```

## Restore

```sh
docker run --rm -v "fireflyiii_firefly_iii_db:/recover" \
    -v "$HOME/backups/firefly:/backup" \
    ubuntu tar -xvf /backup/firefly_db.tar.gz -C /recover --strip 1
```
