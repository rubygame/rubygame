#--
#
#  Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#  Copyright (C) 2004-2009  John Croisant
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2.1 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#++


%w{

  main
  shared

  audio
  clock
  constants
  color
  event
  events
  event_handler
  gl
  joystick
  named_resource
  queue
  rect
  surface

  gfx

  image

  screen
  sprite

  ttf

  mixer

}.each do |f|

  require( File.join( File.dirname(__FILE__), "rubygame", f ) )

end
