# uw8 :zap:

A small [Zig](https://ziglang.org/) ⚡ module, primarily meant for
my own experiments with [MicroW8](https://exoticorn.github.io/microw8/) 🎮

## Usage

You can have `zig build` retrieve the `uw8` module if you specify it as a dependency.

### Create a `build.zig.zon` that looks something like this:
```zig
.{
    .name = "uw8-cart",
    .version = "0.0.0",
    .paths = .{""},
    .dependencies = .{
        .uw8 = .{
            .url = "https://github.com/peterhellberg/uw8/archive/refs/tags/v0.0.1.tar.gz",
        },
    },
}
```

> [!NOTE]
> If you leave out the hash then `zig build` will tell you that it is missing the hash, and what it is.
> Another way to get the hash is to use `zig fetch`, this is probably how you _should_ do it :)

### Then you can add the module in your `build.zig` like this:
```zig
// Add the uw8 module to the executable
exe.root_module.addImport("uw8", b.dependency("uw8", .{}).module("uw8"));
```
