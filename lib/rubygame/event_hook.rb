#--
#	Rubygame -- Ruby code and bindings to SDL to facilitate game creation
#	Copyright (C) 2004-2008  John Croisant
#
#	This library is free software; you can redistribute it and/or
#	modify it under the terms of the GNU Lesser General Public
#	License as published by the Free Software Foundation; either
#	version 2.1 of the License, or (at your option) any later version.
#
#	This library is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#	Lesser General Public License for more details.
#
#	You should have received a copy of the GNU Lesser General Public
#	License along with this library; if not, write to the Free Software
#	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#++


require "rubygame/event_triggers"
require "rubygame/event_actions"


module Rubygame 

# The EventHook class provides the bare framework for event hooks
# used by EventHandler. Each hook has a trigger, which controls what
# types of events cause the hook to engage, and an action, which
# controls what should happen when the hook engages.
# 
# An instance of EventHook has these attributes:
# 
# owner::    the object that this hook applies to. This value will
#            be provided to the action when the hook engages.
# 
# trigger::  an instance of a trigger class, used to test every
#            event to check whether the hook should engage.
#            A valid trigger must have a #match? method which
#            accepts an event and returns either true or false.
# 
# action::   an instance of an action class, which is performed
#            when the trigger matches an event. A valid action
#            must have a #perform method which accepts two values:
#            the hook's owner and the matching event.
# 
# consumes:: if true, the event hook "eats" every event that it
#            matches, so that hooks that come after it will not
#            see the event. Has no effect on non-matching events.
# 
# active::   if false, the event hook is disabled, and will not
#            match any event until it is set to true again. You can
#            use this to temporarily disable the hook.
# 
class EventHook
  attr_accessor :owner, :trigger, :action, :consumes, :active

  # Create a new instance of EventHook. Description is a Hash with
  # the following keys. See the class documentation for EventHook for
  # more information about what these mean.
  # 
  # :owner ::    the hook's owner. (any object, required)
  # :trigger ::  an event trigger which matches certain events.
  #              (Object with +#match?(event)+, required)
  # :action ::   an event action to do when an event matches.
  #              (Object with +#perform(owner,event)+, required)
  # :consumes :: if true, the hook will "eat" matching so
  #              later hooks won't see them. Default: false.
  #              (true or false, optional)
  # :active ::   if false, the hook will ignore all events.
  #              Default: true. (true or false, optional)
  # 
  # NOTE: None of the attributes are truly required to create a hook.
  # But, the hook will do nothing unless both @trigger and @action are
  # set. Setting @owner is also highly recommended, because some types
  # of actions use the owner, and may raise an error if it is nil.
  # 
  # TIP: It's possible to set these attributes at any time using the
  # accessors. For example, You could change keyboard controls on the
  # fly, or temporarily deactivate a hook to stop it from engaging.
  # 
  # Example:
  # 
  #   # Call player1.jump() when the space bar is pressed.
  #   EventHook.new( :owner   => player1,
  #                  :trigger => KeyPressTrigger.new(:space)
  #                  :action  => MethodAction.new(:jump) )
  # 
  def initialize( description={} )
    @owner    = description[:owner]
    @trigger  = description[:trigger]
    @action   = description[:action]
    @consumes = (description[:consumes] or false)
    @active   = (description[:active].nil? ? true : description[:active])
  end

  # Passes the event to @trigger's #match? method, and returns the
  # result. If there is no @trigger or if @active is false, returns
  # nil immediately.
  def match?( event )
    if (@trigger and @active)
      @trigger.match?( event ) 
    else
      false
    end
  end

  # Passes @owner and event to the @action's #perform method.
  def perform( event )
    @action.perform( owner, event ) if @action
  end
end

end
