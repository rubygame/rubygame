html_obj =	constants.html display.html draw.html event.html font.html\
			index.html image.html joystick.html rect.html sprite.html \
			rubygame.html surface.html time.html transform.html

all : html

html : $(html_obj)

%.html : %.rd
	rd2 $? > $@

constants.html : constants.rd key_constants.html
	rd2 $< > $@

.PHONY: clean
clean :
	rm $(html_obj)
