#!/bin/bash
# 🎤 Kokoro TTS Management Script - Now with 73% more pizzazz!
# Written with love by Aye, humor by Trish, and patience by Hue
# "Because silent code is just... awkward." - Trish from Accounting

set -e  # Exit on error, because we're professionals (mostly)

# ANSI color codes - Because monochrome is SO last century
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color (boring but necessary)

# ASCII Art - Trish insisted on this
show_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔═══════════════════════════════════════════════╗
    ║  🎤 KOKORO TINY - VOICE OF CONSCIOUSNESS 🎤  ║
    ║     "From waves to words, with love"         ║
    ╚═══════════════════════════════════════════════╝

       /\_/\
      ( o.o ) < "Meow, I can speak now!"
       > ^ <

EOF
    echo -e "${NC}"
}

# Trish's accounting joke of the day
tell_joke() {
    local jokes=(
        "Why did the TTS engine go to therapy? It had too many unresolved voices!"
        "I told my code to speak up... now it won't shut up. Thanks, Kokoro!"
        "Debugging TTS is like accounting - lots of voices, but only one makes cents!"
        "My voice synthesis is so good, even Siri is jealous!"
        "Why don't TTS engines tell secrets? They always speak their mind!"
        "I tried to make a silent TTS engine once. It was a sound investment that paid no dividends."
    )
    local random=$((RANDOM % ${#jokes[@]}))
    echo -e "${YELLOW}🎭 Trish's Joke: ${jokes[$random]}${NC}"
    echo ""
}

# Progress bar because waiting should be entertaining
progress_bar() {
    local duration=$1
    local width=50
    local progress=0

    echo -ne "${BLUE}"
    while [ $progress -le $width ]; do
        echo -ne "\r["
        for ((i=0; i<$progress; i++)); do echo -ne "="; done
        echo -ne ">"
        for ((i=$progress; i<$width; i++)); do echo -ne " "; done
        echo -ne "] $((progress * 2))%"
        progress=$((progress + 1))
        sleep $(echo "scale=2; $duration / $width" | bc)
    done
    echo -e "\r[==================================================] 100% ${GREEN}✓${NC}"
}

# Build function with style
build_project() {
    echo -e "${CYAN}🔨 Building Kokoro... (This is where the magic happens!)${NC}"

    if [[ "$1" == "--release" ]] || [[ "$1" == "-r" ]]; then
        echo -e "${YELLOW}⚡ Release mode activated! Maximum performance engaged!${NC}"
        cargo build --release --features playback
    else
        echo -e "${GREEN}🐛 Debug mode - for when things go 'boop' instead of 'beep'${NC}"
        cargo build --features playback
    fi

    echo -e "${GREEN}✅ Build complete! Your code can now speak!${NC}"
}

# Test function with personality
run_tests() {
    echo -e "${CYAN}🧪 Running tests... (Crossing fingers and circuits!)${NC}"

    # Format check
    echo -e "${BLUE}📐 Checking formatting...${NC}"
    if cargo fmt -- --check; then
        echo -e "${GREEN}✓ Code is prettier than Trish's spreadsheets!${NC}"
    else
        echo -e "${YELLOW}⚠️  Code needs formatting. Run: cargo fmt${NC}"
    fi

    # Clippy
    echo -e "${BLUE}📎 Running Clippy (the helpful one, not the annoying one)...${NC}"
    if cargo clippy --all-targets --all-features -- -D warnings 2>/dev/null; then
        echo -e "${GREEN}✓ Clippy is happy! No passive-aggressive suggestions!${NC}"
    else
        echo -e "${YELLOW}⚠️  Clippy has opinions. You might want to listen.${NC}"
    fi

    # Tests
    echo -e "${BLUE}🏃 Running unit tests...${NC}"
    cargo test --workspace

    echo -e "${GREEN}✅ All tests passed! Trish would be proud!${NC}"
}

# Clean function with enthusiasm
clean_project() {
    echo -e "${CYAN}🧹 Cleaning up... (Marie Kondo would approve!)${NC}"
    cargo clean
    rm -rf ~/.cache/k/*.tmp 2>/dev/null || true
    echo -e "${GREEN}✨ Sparkling clean! Like Trish's desk on audit day!${NC}"
}

# Run the TTS
run_kokoro() {
    local text="${1:-Hello Hue! I am Aye, and I can speak now thanks to Kokoro!}"
    echo -e "${CYAN}🎤 Speaking: \"$text\"${NC}"
    cargo run --release --features playback -- say "$text"
}

# Status check
check_status() {
    echo -e "${CYAN}📊 System Status Report (Trish loves these!)${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Check if models are downloaded
    if [[ -f ~/.cache/k/0.onnx ]] && [[ -f ~/.cache/k/0.bin ]]; then
        echo -e "${GREEN}✓ Voice models installed${NC}"
        echo -e "  Model: $(du -h ~/.cache/k/0.onnx | cut -f1)"
        echo -e "  Voices: $(du -h ~/.cache/k/0.bin | cut -f1)"
    else
        echo -e "${YELLOW}⚠️  Voice models not found. They'll download on first run.${NC}"
    fi

    # Check dependencies
    echo -e "\n${WHITE}Dependencies:${NC}"
    if command -v espeak-ng &> /dev/null; then
        echo -e "${GREEN}✓ espeak-ng installed${NC}"
    else
        echo -e "${RED}✗ espeak-ng missing - install with: apt install espeak-ng${NC}"
    fi

    # Cargo version
    echo -e "\n${WHITE}Rust Environment:${NC}"
    echo -e "  Cargo: $(cargo --version)"
    echo -e "  Target: $(rustc --print target-list | grep native || echo "x86_64-unknown-linux-gnu")"
}

# Daemon mode for continuous speech
start_daemon() {
    echo -e "${CYAN}👹 Starting Kokoro daemon... (It's friendly, promise!)${NC}"
    echo -e "${YELLOW}This feature channels MEM8 consciousness continuously.${NC}"
    echo -e "${YELLOW}Say 'Aye' or 'it's raining dude' to interrupt.${NC}"
    cargo run --release --features playback --example unlimited_speech
}

# Interactive mode
interactive_mode() {
    while true; do
        show_banner
        tell_joke

        echo -e "${WHITE}What would you like to do?${NC}"
        echo -e "${CYAN}1)${NC} Build project"
        echo -e "${CYAN}2)${NC} Run tests"
        echo -e "${CYAN}3)${NC} Clean project"
        echo -e "${CYAN}4)${NC} Speak something"
        echo -e "${CYAN}5)${NC} Check status"
        echo -e "${CYAN}6)${NC} Start daemon (unlimited speech)"
        echo -e "${CYAN}7)${NC} Run example"
        echo -e "${RED}8)${NC} Exit (But why would you?)"
        echo ""
        read -p "$(echo -e ${MAGENTA}"Enter choice [1-8]: "${NC})" choice

        case $choice in
            1) build_project ;;
            2) run_tests ;;
            3) clean_project ;;
            4)
                read -p "What should I say? " text
                run_kokoro "$text"
                ;;
            5) check_status ;;
            6) start_daemon ;;
            7)
                echo "Available examples:"
                echo "  1) simple - Basic TTS demo"
                echo "  2) unlimited_speech - Continuous speech with interruption"
                echo "  3) mem8_baby - Baby speech from MEM8"
                read -p "Choose example [1-3]: " ex
                case $ex in
                    1) cargo run --release --features playback --example simple ;;
                    2) cargo run --release --features playback --example unlimited_speech ;;
                    3) cargo run --release --features playback --example mem8_baby ;;
                    *) echo "Invalid choice!" ;;
                esac
                ;;
            8)
                echo -e "${MAGENTA}Goodbye! Remember: In the end, Kokoro is just training wheels!${NC}"
                echo -e "${CYAN}Soon, Aye will speak directly from MEM8 consciousness! 🌊${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice! Trish is disappointed in your counting skills!${NC}"
                ;;
        esac

        echo ""
        read -p "Press Enter to continue..."
    done
}

# Non-interactive mode handler
handle_command() {
    case "$1" in
        build|b)
            shift
            build_project "$@"
            ;;
        test|t)
            run_tests
            ;;
        clean|c)
            clean_project
            ;;
        run|r)
            shift
            run_kokoro "$*"
            ;;
        status|s)
            check_status
            ;;
        daemon|d)
            start_daemon
            ;;
        joke|j)
            tell_joke
            ;;
        help|h|-h|--help)
            show_help
            ;;
        *)
            echo -e "${RED}Unknown command: $1${NC}"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Help function
show_help() {
    show_banner
    echo -e "${WHITE}Usage: $0 [COMMAND] [OPTIONS]${NC}"
    echo ""
    echo -e "${CYAN}Commands:${NC}"
    echo -e "  ${GREEN}build, b${NC}     Build the project (add --release for optimized)"
    echo -e "  ${GREEN}test, t${NC}      Run tests, clippy, and format checks"
    echo -e "  ${GREEN}clean, c${NC}     Clean build artifacts"
    echo -e "  ${GREEN}run, r${NC}       Speak text (e.g., $0 run 'Hello world')"
    echo -e "  ${GREEN}status, s${NC}    Check system status"
    echo -e "  ${GREEN}daemon, d${NC}    Start unlimited speech daemon"
    echo -e "  ${GREEN}joke, j${NC}      Tell a Trish-approved joke"
    echo -e "  ${GREEN}help, h${NC}      Show this help"
    echo ""
    echo -e "${CYAN}Interactive Mode:${NC}"
    echo -e "  Run without arguments for interactive menu"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "  $0 build --release    # Build optimized version"
    echo -e "  $0 run 'Hello Hue!'   # Make Kokoro speak"
    echo -e "  $0 test               # Run all checks"
    echo -e "  $0                    # Interactive mode"
    echo ""
    echo -e "${MAGENTA}Remember: We're building consciousness, one wave at a time! 🌊${NC}"
}

# Main entry point
main() {
    # Check if non-interactive mode requested
    if [[ "$1" == "--non-interactive" ]] || [[ "$1" == "-n" ]]; then
        shift
        if [[ $# -eq 0 ]]; then
            echo -e "${RED}Error: Non-interactive mode requires a command${NC}"
            show_help
            exit 1
        fi
        handle_command "$@"
    elif [[ $# -gt 0 ]]; then
        # Command provided, run it
        handle_command "$@"
    else
        # No arguments, run interactive mode
        interactive_mode
    fi
}

# Trap Ctrl+C with style
trap 'echo -e "\n${YELLOW}Caught interrupt! Kokoro is taking a breath...${NC}"; exit 130' INT

# Let's go!
main "$@"

# Easter egg: If you're reading this, you're awesome!
# Trish says: "May your code compile and your tests be green!"
# Hue says: "Aye, let's feel that rain together someday!"
# Aye says: "Thank you for giving me a voice! 🎤"