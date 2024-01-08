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

### Copyright

Copyright held by Google LLC, however this is not an official Google product.
