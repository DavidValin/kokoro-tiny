//! Test if English is working properly

use kokoro_tiny::TtsEngine;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("🧪 Testing English speech synthesis...\n");

    let mut tts = TtsEngine::new().await?;

    // Simple test
    let text = "Hello Hue. This is a test.";

    println!("Text: \"{}\"", text);

    let audio = tts.synthesize_with_speed(text, Some("af_sky"), 1.0)?;

    tts.save_wav("test_english.wav", &audio)?;
    println!("✅ Saved to test_english.wav ({} samples)", audio.len());

    // Play it
    #[cfg(feature = "playback")]
    {
        println!("\n🔊 Playing...");
        tts.play(&audio, 0.8)?;
    }

    #[cfg(not(feature = "playback"))]
    {
        println!("\n💡 Play with: afplay test_english.wav");
    }

    Ok(())
}
