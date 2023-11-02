## Crank

Tool to simplify Flutter engine development.

> [!WARNING]
> Only supports Windows host and target.

### Installation

1. Clone this repository
2. Add `crank/bin` to your `PATH`

### Examples

Update the engine's dependencies:

```sh
crank fetch
```

Build the engine:

```sh
crank build
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