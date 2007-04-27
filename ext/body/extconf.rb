$preload=nil
require 'mkmf'
with_cflags("-W -Wall -std=c99") {
	create_makefile("body")
}
