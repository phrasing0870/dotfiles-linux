# secrets/

Encrypted secrets for this dotfiles repo, using [age](https://github.com/FiloSottile/age).

Only `*.age` files belong here. Never commit a plaintext secret — the
`.gitignore` in this directory blocks anything else by default.

## Public key (safe to share, used to encrypt)

```
age1uu4lnwlhjmx3ue958zj30w3wdzptut7p0fhmzr8s9zpgh9cp0cwqklg0ne
```

The matching private key is **not** in this repo. It lives at
`~/.config/age/keys.txt` on machines that need to decrypt these files —
back it up somewhere durable (password manager). Losing it makes
everything in this directory unrecoverable.

## Encrypt a new secret

```bash
echo "the-secret-value" > secrets/name.txt
age -r age1uu4lnwlhjmx3ue958zj30w3wdzptut7p0fhmzr8s9zpgh9cp0cwqklg0ne \
    -o secrets/name.txt.age \
    secrets/name.txt
shred -u secrets/name.txt
```

## Decrypt

```bash
age -d -i ~/.config/age/keys.txt secrets/name.txt.age
```
