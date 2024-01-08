## Crank 🔧

Flutter engine development tool.

### Installation

1. Clone this repository
2. Add `crank/bin` to your `PATH`

### Examples

Build the Flutter engine:

```sh
crank build --clean --fetch
```

Run tests:

```sh
crank test
```

Run a Flutter app using the locally built engine:

```sh
crank run
```

Use the `--builder` option (`-b`) to choose your build configuration:

```sh
crank build --builder host_release
crank test --builder host_release
crank run --builder host_release
```

### Custom builders

Need a different builder configuration? Want an alias for a builder? Create
the file `~/.config/crank/config.json` to configure custom builders:

```json
{
  "builds": [
    {
      "name": "my_custom_builder",
      "gn": ["--no-lto"],
      "ninja": {
        "config": "host_release",
      }
    }
  ]
}
```

Use the name as the `--builder` option:

```sh
crank build --builder my_custom_builder
```

See [`//flutter/ci/builders/`](https://github.com/flutter/engine/tree/main/ci/builders)
for JSON builder examples.

### Copyright

Copyright held by Google LLC, however this is not an official Google product.
