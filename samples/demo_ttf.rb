#!/usr/bin/env ruby

# This program is PUBLIC DOMAIN.
# It is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

require "rubygame"
include Rubygame
Rubygame.init()

def test_noaa_nobg(font,screen,y)
	puts "No antialiasing, no background..."
	text = font.render("No AA, no BG",false,[200,200,200])
	text.blit(screen,[0,y])
end

def test_noaa_bg(font,screen,y)
	puts "No antialiasing, background..."
	text = font.render("No AA, BG",false,[200,200,200],[0,0,255])
	text.blit(screen,[0,y])
end

def test_aa_nobg(font,screen,y)
	puts "Antialiasing, no background..."
	text = font.render("AA, no BG",true,[200,200,200])
	text.blit(screen,[0,y])
end

def test_aa_bg(font,screen,y)
	puts "Antialiasing, background..."
	text = font.render("AA, BG",true,[200,200,200],[0,0,255])
	text.blit(screen,[0,y])
end

def test_bold_noaa(font,screen,y)
	puts "Bold, no antialiasing..."
	font.bold = true
	text = font.render("Bold, no AA",false,[200,200,200])
	text.blit(screen,[0,y])
	font.bold = false
end

def test_bold_aa(font,screen,y)
	puts "Bold, antialiasing..."
	font.bold = true
	text = font.render("Bold, AA",true,[200,200,200])
	text.blit(screen,[0,y])
	font.bold = false
end

def test_italic_noaa(font,screen,y)
	puts "Italic, no antialiasing..."
	font.italic = true
	text = font.render("Italic, no AA",false,[200,200,200])
	text.blit(screen,[0,y])
	font.italic = false
end

def test_italic_aa(font,screen,y)
	puts "Italic, antialiasing..."
	font.italic = true
	text = font.render("Italic, AA",true,[200,200,200])
	text.blit(screen,[0,y])
	font.italic = false
end

def test_underline_noaa(font,screen,y)
	puts "Underline, no antialiasing..."
	font.underline = true
	text = font.render("Underline, no AA",false,[200,200,200])
	text.blit(screen,[0,y])
	font.underline = false
end

def test_underline_aa(font,screen,y)
	puts "Underline, antialiasing..."
	font.underline = true
	text = font.render("Underline, AA",true,[200,200,200])
	text.blit(screen,[0,y])
	font.underline = false
end

def test_bi_noaa(font,screen,y)
	puts "Bold, Italic, no antialiasing..."
	font.bold = true
	font.italic = true
	text = font.render("B, I, no AA",false,[200,200,200])
	text.blit(screen,[0,y])
	font.bold = false
	font.italic = false
end

def test_bu_noaa(font,screen,y)
	puts "Bold, Underline, no antialiasing..."
	font.bold = true
	font.underline = true
	text = font.render("B, U, no AA",false,[200,200,200])
	text.blit(screen,[0,y])
	font.bold = false
	font.underline = false
end

def test_iu_noaa(font,screen,y)
	puts "Italic, Underline, no antialiasing..."
	font.italic = true
	font.underline = true
	text = font.render("I, U, no AA",false,[200,200,200])
	text.blit(screen,[0,y])
	font.italic = false
	font.underline = false
end

def test_bi_aa(font,screen,y)
	puts "Bold, Italic, antialiasing..."
	font.bold = true
	font.italic = true
	text = font.render("B, I, AA",true,[200,200,200])
	text.blit(screen,[0,y])
	font.bold = false
	font.italic = false
end

def test_bu_aa(font,screen,y)
	puts "Bold, Underline, antialiasing..."
	font.bold = true
	font.underline = true
	text = font.render("B, U, AA",true,[200,200,200])
	text.blit(screen,[0,y])
	font.bold = false
	font.underline = false
end

def test_iu_aa(font,screen,y)
	puts "Italic, Underline, antialiasing..."
	font.italic = true
	font.underline = true
	text = font.render("I, U, AA",true,[200,200,200])
	text.blit(screen,[0,y])
	font.italic = false
	font.underline = false
end

def main
  screen = Screen.open([300,300])
  queue = EventQueue.new()
  queue.ignore = SDL_EVENTS - [QuitEvent, KeyDownEvent]


  unless VERSIONS[:sdl_ttf]
    raise "TTF is not usable. Bailing out."
  end
  TTF.setup()
  font = TTF.new("FreeSans.ttf",30)

  skip = font.line_skip()

  screen.fill([30,70,30])
  y = -skip
  test_noaa_nobg(font,screen,y+=skip)
  test_noaa_bg(font,screen,y+=skip)
  test_aa_nobg(font,screen,y+=skip)
  test_aa_bg(font,screen,y+=skip)
  screen.update()

  queue.wait()

  screen.fill([30,70,30])
  y = -skip
  test_bold_noaa(font,screen,y+=skip)
  test_bold_aa(font,screen,y+=skip)
  test_italic_noaa(font,screen,y+=skip)
  test_italic_aa(font,screen,y+=skip)
  test_underline_noaa(font,screen,y+=skip)
  test_underline_aa(font,screen,y+=skip)
  screen.update()

  queue.wait()

  screen.fill([30,70,30])
  y = -skip
  test_bi_noaa(font,screen,y+=skip)
  test_bi_aa(font,screen,y+=skip)
  test_bu_noaa(font,screen,y+=skip)
  test_bu_aa(font,screen,y+=skip)
  test_iu_noaa(font,screen,y+=skip)
  test_iu_aa(font,screen,y+=skip)
  screen.update()

  queue.wait()
end

main()

Rubygame.quit
