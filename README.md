```markdown
# kokoro-tiny

## Device Selection & Caching (playback feature)

- When the `playback` feature is enabled, `TtsEngine` will attempt to auto-select a suitable audio output device on first run.
- The selected device is cached at `~/.cache/k/audio_device.txt` so subsequent runs reuse the same output device.
- You can override the device at runtime with `TtsEngine::set_audio_device(Some("Device Name".to_string()))` and clear the saved preference with `set_audio_device(None)`.
- The engine uses a small heuristic (`AirPods`, `Built-in`, `Voice`, `Headphones`, etc.) to prefer system voice channels on macOS/Android when available.

## Synthesis API ergonomics

- `synthesize(&mut self, text: &str, voice: Option<&str>)` — simple, default-speed call.
- `synthesize_with_speed(&mut self, text: &str, voice: Option<&str>, speed: f32)` — specify user-facing speed.
- `synthesize_with(&mut self, text: &str, opts: SynthesizeOptions)` — builder-style options (voice, speed, gain).

Example using the builder:

```rust
let mut tts = kokoro_tiny::TtsEngine::new().await?;
let opts = kokoro_tiny::SynthesizeOptions::default().voice("af_sky").speed(1.1).gain(1.2);
let audio = tts.synthesize_with("Hello world", opts)?;
```

## Examples

See `examples/device_select.rs` for how to list devices and test playback across them.

```
# kokoro-tiny
