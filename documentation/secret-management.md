# Secret Management

Secrets are stored in SOPS-encrypted YAML files committed to the repo. Encryption uses [age](https://github.com/FiloSottile/age) keys — the encrypted files are safe to commit, the private key must never be committed.

`SOPS_AGE_KEY_FILE` is set automatically via the root `mise.toml` to `~/.age/homelab.txt`, so SOPS commands work without any extra configuration as long as you have the private key in that location.

## Encrypting a secrets file

Create a `.sops.yaml` at the relevant directory level to tell SOPS which age key to use:

```yaml
creation_rules:
  - path_regex: .*secrets.*
    age: age1xxxxxxx # your public key from ~/.age/homelab.txt
```

Create and encrypt a new secrets file:

```sh
sops secrets.yaml
# opens your editor, fill in plain YAML, saves encrypted
```

## Editing secrets

```sh
sops secrets.yaml
# decrypts, opens editor, re-encrypts on save
```

## Reading a specific value

```sh
sops --extract '["my_secret"]' -d secrets.yaml
```

## Using secrets in scripts

```sh
# decrypt to stdout
sops -d secrets.yaml

# export as env vars
export $(sops -d secrets.env)
```

## Using secrets in Ansible

```sh
sops -d secrets.yaml | ansible-playbook playbook.yaml -e @/dev/stdin
```
