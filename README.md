## Crank

Flutter engine development tool.

### Installation

1. Clone this repository
2. Add `crank/bin` to your `PATH`

### Examples

Build the engine:

```sh
crank build --clean --fetch
```

Run tests whose names contain `foo`:

```sh
crank test -f *foo*
```

Run a Flutter app using the locally built engine:

```sh
crank run
```

### Copyright

Copyright held by Google LLC, however this is not an official Google product.