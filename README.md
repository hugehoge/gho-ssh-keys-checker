GitHub organization SSH-keys checker
===

A CLI tool for the survey of the SSH-Key strength in your GitHub organization members.

## Requirements

- macOS 12.0+
- Swift 5.5.1+
- Your GitHub personal access token
  - https://github.com/settings/tokens
  - `read:org` scope required

## Usage

```sh
$ git clone git@github.com:hugehoge/gho-ssh-keys-checker.git
$ cd gho-ssh-keys-checker
$ swift run gho-ssh-keys-checker $YOUR_GITHUB_ORGANIZATION_NAME
Please enter your GitHub personal access token:

ECDSA 256bit     : 1 (0.3%)
ECDSA 521bit     : 1 (0.3%)
ECDSA-SK 256bit  : 5 (1.3%)
ED25519 256bit   : 112 (29.4%)
ED25519-SK 256bit: 4 (1.0%)
RSA 2048bit      : 61 (16.0%)
RSA 3072bit      : 35 (9.2%)
RSA 4048bit      : 1 (0.3%)
RSA 4096bit      : 161 (42.3%)

Total: 381 keys
```

### Options

```sh
USAGE: command <organization> [--suppress-summary] [--tsv]

ARGUMENTS:
  <organization>          Target GitHub orgnization name.

OPTIONS:
  --suppress-summary      Suppress summary results.
  --tsv                   Show TSV format results.
  -h, --help              Show help information.
```

## Related articles

- [株式会社ゆめみ所属メンバの SSH 鍵強度調査](https://qiita.com/hugehoge/items/e47ef0260cc129f255a6)
