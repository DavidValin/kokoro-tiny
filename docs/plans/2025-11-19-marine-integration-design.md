# Marine Salience Integration Design
**Date:** 2025-11-19
**Branch:** semper-fi
**Version:** 0.3.0
**Status:** Design Approved ✅

## Executive Summary

Integrate Marine salience from IndexTTS-Rust into kokoro-tiny as an optional-but-default feature, providing:
1. **Quality Validation** - Automatic authenticity scoring for all TTS output
2. **Emotion-Aware Synthesis** - Intelligent style selection based on desired emotion
3. **Voice/Style Ranking** - Discover which combinations sound most natural

**Design Philosophy:** Hybrid integration (optional feature, enabled by default) that adds powerful capabilities without breaking existing API.

## Motivation

kokoro-tiny currently has:
- 50+ voices with 510 style variations each
- Style selection based purely on token count
- No quality validation mechanism

**The Opportunity:** Marine salience provides:
- O(1) per-sample authenticity detection
- 8D interpretable emotion vectors
- Distinction between robotic/natural/damaged speech

**The Result:** Upgrade from "pick style #237 because you have 237 tokens" to "pick the style that sounds confident and authentic."

## Architecture

### Design Choice: Hybrid Integration (Option 3)

**Rationale:** Best balance of power and flexibility
- Follows kokoro-tiny's existing feature flag pattern
- Enabled by default (most users benefit)
- Can be disabled for ultra-minimal builds
- No breaking changes to existing API

### Feature Flag Structure

```toml
[features]
default = ["playback", "ducking", "marine"]
marine = ["marine_salience"]

[dependencies]
# New dependency
marine_salience = { version = "0.1.0", optional = true }
```

### Project Structure

```
kokoro-tiny/
├── src/
│   ├── lib.rs              # Core TTS (add marine hooks)
│   ├── main.rs             # CLI (add emotion commands)
│   └── quality.rs          # NEW - Marine integration layer
├── examples/
│   ├── test_emotional_tts.rs          # NEW - Emotion demo
│   ├── validate_voices.rs             # NEW - Voice ranking
│   └── style_quality_benchmark.rs     # NEW - Deep analysis
├── docs/
│   ├── plans/
│   │   └── 2025-11-19-marine-integration-design.md  # This file
│   └── MARINE_GUIDE.md     # NEW - User guide
└── Cargo.toml              # Add marine feature
```

## Component Design

### 1. Quality Module (`src/quality.rs`)

**Purpose:** Marine integration layer providing emotion targets, quality reports, and style selection.

#### EmotionTarget Enum
```rust
pub enum EmotionTarget {
    Confident,   // Low jitter, good energy
    Calm,        // Low jitter, moderate energy
    Energetic,   // High energy, moderate jitter
    Nervous,     // Higher jitter, lower energy
    Neutral,     // Balanced parameters
    Custom(MarineProsodyVector),  // Advanced users
}
```

**Design rationale:** Simple, user-friendly API abstracts Marine's technical details.

#### QualityReport Struct
```rust
pub struct QualityReport {
    pub authenticity_score: f32,     // 0.0-1.0
    pub pitch_stability: f32,        // Period jitter mean
    pub is_robotic: bool,            // jp < 0.005
    pub has_artifacts: bool,         // jp > 0.3
    pub assessment: String,          // Human-readable
    pub prosody: MarineProsodyVector, // Full details
}
```

**Design rationale:** Multiple levels of detail - simple score for quick checks, full vector for advanced analysis.

#### StyleSelector
```rust
pub struct StyleSelector {
    style_cache: HashMap<(String, usize), f32>,
}

impl StyleSelector {
    pub fn select_for_emotion(
        &mut self,
        voice: &str,
        target: &EmotionTarget,
        token_count: usize,
    ) -> usize;
}
```

**Algorithm:**
1. Filter styles appropriate for token_count (±50 range)
2. Score each against target emotion using Marine vectors
3. Return best match
4. Cache results for performance

**Design rationale:** Lazy evaluation + caching minimizes overhead while providing intelligent selection.

### 2. TtsEngine Integration

**Backwards Compatible API (unchanged):**
```rust
pub fn synthesize(
    &mut self,
    text: &str,
    voice: Option<&str>,
    speed: Option<f32>,
) -> Result<Vec<f32>, String>
```

**New Emotion-Aware API (marine feature only):**
```rust
#[cfg(feature = "marine")]
pub fn synthesize_with_emotion(
    &mut self,
    text: &str,
    voice: Option<&str>,
    emotion: EmotionTarget,
    speed: Option<f32>,
) -> Result<(Vec<f32>, QualityReport), String>
```

**New Validation API (marine feature only):**
```rust
#[cfg(feature = "marine")]
pub fn validate_quality(
    &self,
    audio: &[f32],
) -> Result<QualityReport, String>
```

**Design rationale:** Existing code continues to work. New capabilities are additive, not destructive.

### 3. CLI Enhancements

**New Commands (marine feature):**

```bash
# Emotion-aware synthesis
kokoro-speak emotion --emotion confident "I've got this!"

# Quality validation
kokoro-speak validate output.wav

# Voice ranking
kokoro-speak rank-voices "Test phrase"
```

**Design rationale:** CLI demonstrates full capabilities while remaining backwards compatible.

## Example Programs

### 1. test_emotional_tts.rs - The Showpiece
Generates same text with 5 different emotions, saves WAV files, prints quality reports.

**Purpose:** Let users HEAR the difference emotions make.

### 2. validate_voices.rs - Voice Discovery
Tests all available voices, ranks by naturalness score.

**Purpose:** Help users discover which voices sound most authentic.

### 3. style_quality_benchmark.rs - Deep Dive
Tests all 510 styles for a voice, identifies top 20 most natural.

**Purpose:** Scientific analysis for users who want optimal quality.

## Data Flow

### Emotion-Aware Synthesis Flow
```
User Request ("confident" emotion)
    ↓
EmotionTarget::Confident
    ↓
StyleSelector (finds best style matching "confident" characteristics)
    ↓
TtsEngine.synthesize_with_style() [existing code]
    ↓
Generated Audio
    ↓
Marine Validation (quality scoring)
    ↓
(Audio, QualityReport) returned to user
```

### Quality Validation Flow
```
Audio samples (Vec<f32>)
    ↓
MarineProcessor (O(1) per-sample jitter detection)
    ↓
SaliencePackets collected
    ↓
Aggregate statistics (mean jp, ja, h_score, s_score)
    ↓
Classification:
    - jp < 0.005 → "Too robotic"
    - 0.005 ≤ jp ≤ 0.3 → "Natural ✅"
    - jp > 0.3 → "Has artifacts"
    ↓
QualityReport generated
```

## Marine Salience Integration Details

### Configuration
```rust
// For kokoro-tiny's 24kHz sample rate
let config = MarineConfig::speech_default(24000);
let processor = MarineProcessor::new(config);
```

### Jitter Thresholds
- **Robotic:** jp < 0.005 (too perfect)
- **Natural:** 0.005 ≤ jp ≤ 0.3 (human-like)
- **Damaged:** jp > 0.3 (artifacts)

### 8D Prosody Vector
```rust
MarineProsodyVector {
    jp_mean: f32,      // Period jitter (pitch stability)
    jp_std: f32,       // Jitter variance
    ja_mean: f32,      // Amplitude jitter (volume stability)
    ja_std: f32,       // Volume variance
    h_mean: f32,       // Harmonic alignment (0-1)
    s_mean: f32,       // Overall salience (0-1)
    peak_density: f32, // Speech rate (peaks/second)
    energy_mean: f32,  // Average loudness
}
```

### Emotion → Prosody Mapping

| Emotion | jp_mean | energy | Characteristics |
|---------|---------|--------|-----------------|
| Confident | Low (0.02) | High (0.80) | Stable pitch, strong presence |
| Calm | Low (0.03) | Medium (0.60) | Stable, soothing |
| Energetic | Medium (0.08) | High (0.85) | Dynamic, enthusiastic |
| Nervous | High (0.15) | Low (0.50) | Uncertain, hesitant |
| Neutral | Medium (0.05) | Medium (0.65) | Balanced baseline |

## Performance Considerations

### Overhead Analysis

**Marine Processing:**
- O(1) per sample
- ~50ms for 29-second audio (from story_time example: 695,040 samples)
- Negligible compared to synthesis time

**Style Selection:**
- First call: Tests relevant styles (~10-20 styles in token range)
- Subsequent calls: Cached results (O(1) HashMap lookup)
- One-time cost amortized across usage

**Memory:**
- marine_salience: Tiny (no_std compatible)
- Style cache: ~50KB max (510 styles × 50 voices × 2 bytes)

**Conclusion:** Overhead is minimal and acceptable for the value provided.

### Optimization Strategy
1. Lazy evaluation (only test styles when needed)
2. Caching (style scores persist across calls)
3. Token-count filtering (test ±50 range, not all 510)

## Testing Strategy

### Unit Tests
- EmotionTarget → MarineProsodyVector conversion
- Quality classification (robotic/natural/damaged)
- Style selection algorithm
- Cache correctness

### Integration Tests
- Full synthesis + validation pipeline
- All emotion targets generate valid audio
- Quality reports are accurate
- CLI commands work correctly

### Quality Benchmarks
- Baseline: Current kokoro-tiny voices
- Target: ≥80% authenticity score for "Natural" classification
- Compare: Token-count selection vs emotion-aware selection

## Migration Path

### For Existing Users

**No changes required!** Existing code continues to work:
```rust
// This still works exactly as before
let audio = tts.synthesize(text, Some("af_sky"), Some(1.0))?;
```

**Opt-in to new features:**
```rust
// New emotion-aware API
let (audio, quality) = tts.synthesize_with_emotion(
    text,
    Some("af_sky"),
    EmotionTarget::Confident,
    Some(1.0),
)?;
```

**Disable if needed:**
```toml
# Cargo.toml
[dependencies]
kokoro-tiny = { version = "0.3.0", default-features = false, features = ["playback"] }
```

### Version Bump Rationale

**v0.2.0 → v0.3.0** (minor version bump)
- New features added
- No breaking changes to existing API
- Optional dependency (can be disabled)
- Semantic versioning: MINOR = backwards-compatible functionality

## Documentation

### User-Facing Docs

**MARINE_GUIDE.md** will cover:
1. What is Marine salience?
2. Quick start with emotion-aware synthesis
3. Understanding quality reports
4. Advanced: Custom prosody vectors
5. Best practices for voice/style selection
6. FAQ

### Code Documentation

- Comprehensive rustdoc comments
- Examples in every public function
- Module-level overview docs
- Link to MARINE_GUIDE.md from docs

## Success Criteria

✅ **Integration complete when:**
1. All tests pass (unit + integration)
2. Examples work and demonstrate capabilities
3. Documentation is complete
4. Clippy has no warnings
5. Benchmark shows acceptable performance (<100ms overhead)
6. Quality scores are meaningful (validated manually)

✅ **Feature is successful when:**
1. Users discover "best" voices without trial-and-error
2. Emotion-aware synthesis produces noticeably different output
3. Quality validation catches robotic/damaged audio
4. Performance overhead is imperceptible in practice

## Implementation Phases

### Phase 1: Core Integration (4 hours)
- Add marine_salience dependency
- Create src/quality.rs module
- Implement EmotionTarget, QualityReport, StyleSelector
- Integrate into TtsEngine

### Phase 2: Examples (2 hours)
- test_emotional_tts.rs
- validate_voices.rs
- style_quality_benchmark.rs

### Phase 3: CLI Enhancement (1 hour)
- Add emotion command
- Add validate command
- Add rank-voices command

### Phase 4: Documentation (1 hour)
- MARINE_GUIDE.md
- Rustdoc comments
- Update README.md

### Phase 5: Testing & Polish (2 hours)
- Write tests
- Run benchmarks
- Clippy cleanup
- Final validation

**Total Estimate: 10 hours**

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Marine scores don't correlate with perceived quality | High | Manual validation with multiple listeners |
| Performance overhead too high | Medium | Profiling + optimization, caching |
| Emotion mapping feels arbitrary | Medium | Document rationale, allow Custom() for users |
| Feature flag complexity | Low | Extensive testing of both paths |

## Future Enhancements (Not in v0.3.0)

- Train model to use Marine vectors directly (like IndexTTS goal)
- Real-time quality monitoring during synthesis
- Conversation affect tracking
- Auto-retry generation if quality too low
- Web UI for exploring voices/emotions

## References

- **Marine Salience:** `IndexTTS-Rust/crates/marine_salience/`
- **Phoenix Protocol:** `IndexTTS-Rust/src/quality/`
- **Context:** `PHOENIX_PROTOCOL_OPPORTUNITIES.md`
- **Vision:** `AUDIO_TRINITY_VISION.md`

---

**Design approved by:** Hue & Aye
**Target branch:** semper-fi
**Next step:** Worktree setup + implementation plan

🎖️ **Semper Fi - Marines Always Faithful!**
