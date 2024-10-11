//! MicroW8
//!
//! Memory map
//!
//! 00000-00040: user memory
//! 00040-00044: time since module start in ms
//! 00044-0004c: gamepad state
//! 0004c-00050: number of frames since module start
//! 00050-00070: sound data (synced to sound thread)
//! 00070-00078: reserved
//! 00078-12c78: frame buffer
//! 12c78-12c7c: sound registers/work area base address (for sndGes function)
//! 12c7c-13000: reserved
//! 13000-13400: palette
//! 13400-13c00: font
//! 13c00-14000: reserved
//! 14000-40000: user memory

pub const TIME_MS: *i32 = @ptrFromInt(0x40); // 00040-00044: time since module start in ms
pub const GAMEPAD: *[8]bool = @ptrFromInt(0x44); // 00044-0004c: gamepad state
pub const FRAME: *i32 = @ptrFromInt(0x4c); // 0004c-00050: number of frames since module start
pub const FRAMEBUFFER: *[320 * 240]u8 = @ptrFromInt(0x78); // 00078-12c78: frame buffer
pub const PALETTE: *[256]u32 = @ptrFromInt(0x13000); // 13000-13400: palette
pub const FONT: *[256][8]u8 = @ptrFromInt(0x13400); // 13400-13c00: font

// Math
//
// These all do what you'd expect them to. All angles are in radians.
//

/// Returns the arcsine of x.
pub extern fn asin(x: f32) f32;

/// Returns the arccosine of x.
pub extern fn acos(x: f32) f32;

/// Returns the arctangent of x.
pub extern fn atan(x: f32) f32;

/// Returns the angle between the point (x, y) and the positive x-axis.
pub extern fn atan2(y: f32, x: f32) f32;

/// Returns the sine of angle.
pub extern fn sinf(angle: f32) f32;

/// Returns the tangent of angle.
pub extern fn tanf(angle: f32) f32;

/// Returns the cosine of angle.
pub extern fn cosf(angle: f32) f32;

/// Returns e^x.
pub extern fn expf(x: f32) f32;

/// Returns the natural logarithmus of x. Ie. e^log(x) == x.
pub extern fn logf(x: f32) f32;

/// Returns x^y.
pub extern fn pow(x: f32, y: f32) f32;

/// Returns x modulo y, ie. x - floor(x / y) * y.
///
/// This means the sign of the result of fmodf is the same as y.
///
pub extern fn fmodf(x: f32, y: f32) f32;

// Random
//
// MicroW8 provides a pretty good PRNG, namely xorshift64*.
// It is initialized to a constant seed at each startup,
// so if you want to vary the random sequence
// you'll need to provide a seed yourself.
//

/// Returns a (pseudo-)random 32bit integer.
pub extern fn random() i32;

/// Returns a (pseudo-)random float equally distributed in [0,1).
pub extern fn randomf() f32;

/// Seeds the PRNG with the given seed.
///
/// The seed function is reasonably strong so that you can use
///
///  randomSeed(index);
///  random()
///
/// as a cheap random-access PRNG (aka noise function).
///
pub extern fn randomSeed(seed: i32) void;

// Graphics
//
// The palette can be changed by writing 32bit rgba colors to addresses 0x13000-0x13400.
//
// The drawing functions are sub-pixel accurate where applicable (line, circle).
// Pixel centers lie halfway between integer coordinates.
// Ie. the top-left pixel covers the area 0,0 - 1,1,
// with 0.5,0.5 being the pixel center.
//

/// Clears the screen to the given color index.
///
/// Also sets the text cursor to 0, 0 and disables graphical text mode.
///
pub extern fn cls(color: i32) void;

/// Sets the pixel at x, y to the given color index.
pub extern fn setPixel(x: i32, y: i32, color: i32) void;

/// Returns the color index at x, y.
///
/// Returns 0 if the given coordinates are outside the screen.
///
pub extern fn getPixel(x: i32, y: i32) i32;

/// Fills the horizontal line [left, right), y with the given color index.
pub extern fn hline(left: i32, right: i32, y: i32, color: i32) void;

/// Fills the rectangle x,y - x+w,y+h with the given color index.
///
/// (Sets all pixels where the pixel center lies inside the rectangle.)
///
pub extern fn rectangle(x: f32, y: f32, w: f32, h: f32, color: i32) void;

/// Fills the circle at cx, cy and with radius with the given color index.
///
/// (Sets all pixels where the pixel center lies inside the circle.)
///
pub extern fn circle(cx: f32, cy: f32, radius: f32, color: i32) void;

/// Draws a one pixel outline on the inside of the given rectangle.
///
/// (Draws the outermost pixels that are still inside the rectangle area.)
///
pub extern fn rectangleOutline(x: f32, y: f32, w: f32, h: f32, color: i32) void;

/// Draws a one pixel outline on the inside of the given circle.
///
/// (Draws the outermost pixels that are still inside the circle area.)
///
pub extern fn circleOutline(cx: f32, cy: f32, radius: f32, color: i32) void;

/// Draws a line from x1,y1 to x2,y2 in the given color index.
pub extern fn line(x1: f32, y1: f32, x2: f32, y2: f32, color: i32) void;

/// Copies the pixel data at spriteData onto the screen at x, y.
///
/// The size of the sprite is passed as width | (height << 16).
/// If the height is given as 0, the sprite is is treated as square (width x width).
///
/// The control parameter controls masking and flipping of the sprite:
///
///     bits 0-7: color mask index
///     bit 8: switch on masked blit (pixel with color mask index are treated as transparent)
///     bit 9: flip sprite x
///     bit 10: flip sprite y
///
pub extern fn blitSprite(spriteData: i32, size: i32, x: i32, y: i32, control: i32) void;

/// Copies the pixel data on the screen at x, y to spriteData.
///
/// Parameters are exactly the same as blitSprite.
///
pub extern fn grabSprite(spriteData: i32, size: i32, x: i32, y: i32, control: i32) void;

// Input
//
// MicroW8 provides input from a gamepad with one
// D-Pad and 4 buttons, or a keyboard emulation thereof.
//
// The buttons are numbered
//
// Button   Keyboard        Index
// Up       Arrow-Up        0
// Down     Arrow-Down      1
// Left     Arrow-Left      2
// Right    Arrow-Right     3
// A        Z               4
// B        X               5
// X        A               6
// Y        S               7
//
// In addition to using the API functions below, the gamepad state
// can also be read as a bitfield of pressed buttons at address 0x44.
// 0x48 holds the buttons that were pressed last frame.
//

pub const BUTTON_UP: i32 = 0;
pub const BUTTON_DOWN: i32 = 1;
pub const BUTTON_LEFT: i32 = 2;
pub const BUTTON_RIGHT: i32 = 3;
pub const BUTTON_A: i32 = 4;
pub const BUTTON_B: i32 = 5;
pub const BUTTON_X: i32 = 6;
pub const BUTTON_Y: i32 = 7;

/// Returns whether the buttons with the given index is pressed this frame.
pub extern fn isButtonPressed(btn: i32) bool;

/// Returns whether the given button is newly pressed this frame.
pub extern fn isButtonTriggered(btn: i32) bool;

/// Returns the time in seconds since the start of the cart.
///
/// The integer time in milliseconds can also be read at address 0x40.
///
pub extern fn time() f32;

// Text output
//
// The default font can be seen here.
//
// The font can be changed by writing 1bpp 8x8
// characters to addresses 0x13400-0x13c00.
//
// All text printing is done at the cursor position, which is
// advanced after printing each character. The cursor is not visible.
//
// Text printing can operate in two modes - normal and graphics.
// After startup and after cls() normal mode is active.
//

// Normal mode
//
// In normal mode, text printing is constrained to an 8x8 character grid.
// Setting the cursor position to 2,3 will start printing at pixel coordinates 16,24.
//
// When printing characters, the full 8x8 pixels are painted with the
// text and background colors according to the character graphics in the font.
//
// When moving/printing past the left or right border the cursor will
// automatically wrap to the previous/next line. When moving/printing past
// the upper/lower border, the screen will be scrolled down/up 8 pixels,
// filling the fresh line with the background color.
//

// Graphics mode
//
// In graphics mode, text can be printed to any pixel position,
// the cursor position is set in pixel coordinates.
//
// When printing characters only the foreground
// pixels are set, the background is "transparent".
//
// Moving/printing past any border does not cause any
// special operation, the cursor just goes off-screen.
//

// Text scale
//
// An integer text scale factor in the range 1x-16x can be set
// with control char 30. An attempt to set a scale outside
// that range will reset the scale to 1x.
//
// After startup and cls the scale is initialized to 1x.
//

/// Control chars
///
/// Characters 0-31 are control characters and don't print by default.
/// They take the next 0-2 following characters as parameters.
/// Avoid the reserved control chars, they are currently NOPs
/// but their behavior can change in later MicroW8 versions.
///
/// Code     Parameters      Operation
/// 0        -               Nop
/// 1        char            Print char (including control chars)
/// 2-3      -               Reserved
/// 4        -               Switch to normal mode, reset cursor to 0,0
/// 5        -               Switch to graphics mode
/// 6        -               Switch output to (debug) console
/// 7        -               Bell / trigger sound channel 0
/// 8        -               Move cursor left
/// 9        -               Move cursor right
/// 10       -               Move cursor down
/// 11       -               Move cursor up
/// 12       -               do cls(background_color)
/// 13       -               Move cursor to the left border
/// 14       color           Set the background color
/// 15       color           Set the text color
/// 16-23    -               Reserved
/// 24       -               Swap text/background colors
/// 25-29    -               Reserved
/// 30       scale           Set text scale (1-16)
/// 31       x, y            Set cursor position (*)
///
/// (*) In graphics mode, the x coordinate is doubled when using
/// control char 31 to be able to cover the whole screen with one byte.
///
pub fn control(chars: []const i32) void {
    for (chars) |num| {
        printChar(num);
    }
}

/// Switch to normal mode, reset cursor to 0,0
pub fn switchToNormalMode() void {
    control(&.{4});
}

/// Switch to graphics mode
pub fn switchToGraphicsMode() void {
    control(&.{5});
}

/// Switch output to (debug) console
pub fn switchOutputToDebugConsole() void {
    control(&.{6});
}

/// Bell / trigger sound channel 0
pub fn bell() void {
    control(&.{7});
}

/// Move cursor left
pub fn moveCursorLeft() void {
    control(&.{8});
}

/// Move cursor right
pub fn moveCursorRight() void {
    control(&.{9});
}

/// Move cursor down
pub fn moveCursorDown() void {
    control(&.{10});
}

/// Move cursor up
pub fn moveCursorUp() void {
    control(&.{11});
}

/// Move cursor to the left border
pub fn moveCursorLeftBorder() void {
    control(&.{13});
}

/// Swap text/background colors
pub fn swapTextBackgroundColors() void {
    control(&.{24});
}

/// Set text scale (1-16)
pub fn setTextScale(scale: i32) void {
    control(&.{ 30, scale });
}

// Debug output
//
// Control code 6 switches all text output
// (except codes 4 and 5 to switch output back to the screen) to the console.
//
// Where exactly this ends up (if at all) is an implementation detail of the runtimes.
// The native dev-runtime writes the debug output to stdout, the web runtime to the
// debug console using console.log. Both implementations buffer the output
// until they encounter a newline character (10) in the output stream.
//
// There may be future runtimes that ignore the debug output completely.
//
// In CurlyWas, a simple way to log some value might look like this:
//
//  printChar('\06V: ');    // switch to console out, print some prefix
//  printInt(some_value);
//  printChar('\n\4');      // newline and switch back to screen
//

/// Prints the character in the lower 8 bits of char.
///
/// If the upper 24 bits are non-zero, right-shifts
/// char by 8 bits and loops back to the beginning.
///
pub extern fn printChar(num: i32) void;

/// Prints the zero-terminated string at the given memory address.
pub extern fn printString(strPtr: [*]const u8) void;

/// Prints num as a signed decimal number.
pub extern fn printInt(num: i32) void;

/// Sets the text color.
pub extern fn setTextColor(color: i32) void;

/// Sets the background color.
pub extern fn setBackgroundColor(color: i32) void;

/// Sets the cursor position.
///
/// In normal mode x and y are multiplied by 8 to get the
/// pixel position, in graphics mode they are used as is.
///
pub extern fn setCursorPosition(x: i32, y: i32) void;

// Sound
//
// Low level operation
//
// MicroW8 actually runs two instances of your module.
// On the first instance, it calls upd and displays the
// framebuffer found in its memory. On the second instance,
// it calls snd instead with an incrementing sample index and
// expects that function to return sound samples for the left
// and right channel at 44100 Hz. If your module does not export
// a snd function, it calls the api function sndGes instead.
//
// As the only means of communication, 32 bytes starting at address
// 0x00050 are copied from main to sound memory after upd returns.
//
// By default, the sndGes function generates sound based on the 32 bytes
// at 0x00050. This means that in the default configuration those 32 bytes
// act as sound registers.
//
// See the sndGes function for the meaning of those registers.
//
//  export fn snd(sampleIndex: i32) f32;
//
// If the module exports a snd function, it is called 88200 times per
// second to provide PCM sample data for playback (44.1kHz stereo).
// The sampleIndex will start at 0 and increments by 1 for each call.
// On even indices the function is expected to return a sample value
// for the left channel, on odd indices for the right channel.

pub fn select(b: bool, x: f32, y: f32) f32 {
    return if (b) x else y;
}

/// Triggers a note (1-127) on the given channel (0-3).
///
/// Notes are semitones with 69 being A4 (same as MIDI).
/// A note value of 0 stops the sound playing on that channel.
/// A note value 128-255 will trigger note-128 and immediately
/// stop it (playing attack+release parts of envelope).
///
/// This function assumes the default setup,
/// with the sndGes registers located at 0x00050.
///
pub extern fn playNote(channel: i32, note: i32) void;

/// This implements a sound chip, generating
/// sound based on 32 bytes of sound registers.
///
/// The spec of this sound chip are:
///
///
///     - 4 channels with individual volume control (0-15)
///     - rect, saw, tri, noise wave forms selectable per channel
///     - each wave form supports some kind of pulse width modulation
///     - each channel has an optional automatic low pass filter,
///         or can be sent to one of two manually controllable filters
///     - each channel can select between a narrow and a wide stereo positioning.
///         The two stereo positions of each channel are fixed.
///     - optional ring modulation
///
///
/// This function requires 1024 bytes of working memory, the first 32 bytes
/// of which are interpreted as the sound registers. The base address of
/// its working memory can be configured by writing the address to 0x12c78.
///
/// It defaults to 0x00050.
///
pub extern fn sndGes(sampleIndex: i32) f32;
