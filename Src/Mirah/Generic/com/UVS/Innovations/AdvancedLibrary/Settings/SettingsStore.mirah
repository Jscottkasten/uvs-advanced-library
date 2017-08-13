###################################################################################
# Copyright (C) 2015, 2016, 2017 by UVS Innovations Corporation.                  #
# All rights reserved.                                                            #
#                                                                                 #
# Redistribution and use in source and binary forms, with or without              #
# modification, are permitted provided that the following conditions are met:     #
#                                                                                 #
# 1. Redistributions of source code must retain the above copyright notice, this  #
#    list of conditions and the following disclaimer.                             #
# 2. Redistributions in binary form must reproduce the above copyright notice,    #
#    this list of conditions and the following disclaimer in the documentation    #
#    and/or other materials provided with the distribution.                       #
#                                                                                 #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND #
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED   #
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE          #
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR #
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES  #
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;    #
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND     #
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT      #
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS   #
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                    #
#                                                                                 #
###################################################################################

package com.UVS.Innovations.AdvancedLibrary.Settings

#
# Std library support.
#
import java.lang.Boolean
import java.lang.Float
import java.lang.Integer
import java.lang.Long
import java.lang.String
import java.util.Map

import java.util.concurrent.locks.ReentrantLock

#
# Advanced library support.
#
import com.UVS.Innovations.AdvancedLibrary.InputValidation.ParameterDefaults
import com.UVS.Innovations.AdvancedLibrary.InputValidation.ParameterLengthException
import com.UVS.Innovations.AdvancedLibrary.InputValidation.ParameterRangeException




#####
#
# Class for maintaining and accessing
# our individual application settings.
#
class SettingsStore < ParameterDefaults
  attr_reader read_only:boolean

  #
  # Boiler plate for the ParameterDefaults
  # base from which we are derived.
  #

  def self.defaults:Map
    return SettingsStore.defaults
  end

  #protected
  def disperse_parms:Map
    @parms     = super
    @singleton = SettingsStoreSingleton.get_reference @parms

    # NOTE: We pass the singleton's copy up the call stack.
    @parms     = @singleton.settings

    return @parms
  end

  def initialize
    super
  end

  def initialize (parms:Map)
    super parms
  end

  #
  # Allows us to protect this accessor of
  # the singleton separately from other
  # accessors, I.E. may not have the context
  # from which to actually save data in
  # that thread.
  #

  #protected
  def read_only= (state:boolean):void
    @read_only = state
  end

  def is_loaded:boolean
    return @singleton.is_loaded
  end

  #protected
  def is_loaded= (state:boolean):void
    @singleton.is_loaded = state
  end

  #protected
  def lock:void
    @singleton.lock
  end

  #protected
  def unlock:void
    @singleton.unlock
  end

  #
  # General data element access methods.
  #

  def get (key:String):String
    @singleton.lock
    return String(@parms[key])
  ensure
    @singleton.unlock
  end

  def set (key:String, value:String):void
    @singleton.lock
    raise SettingsStoreReadOnlyException if @read_only
    @parms[key] = value
  ensure
    @singleton.unlock
  end

  def get_boolean (key:String):boolean
    return (Boolean.parseBoolean String(@parms[key]))
  end

  def get_float (key:String):float
    return (Float.parseFloat String(@parms[key]))
  end

  def get_int (key:String):int
    return (Integer.parseInt String(@parms[key]))
  end

  def get_long (key:String):long
    return (Long.parseLong String(@parms[key]))
  end

  def get_string (key:String):String
    return String(@parms[key])
  end

  def set (key:String, value_:boolean):void
    self.set key, Boolean.new(value_).toString
  end

  def set (key:String, value_:float):void
    self.set key, Float.new(value_).toString
  end

  def set (key:String, value_:float, min:float, max:float):void
    raise ParameterRangeException, "#{self.tag}.#{key}" unless (value_ >= min) and (value_ <= max)
    self.set key, Float.new(value_).toString
  end

  def set (key:String, value_:int):void
    self.set key, Integer.new(value_).toString
  end

  def set (key:String, value_:int, min:int, max:int):void
    raise ParameterRangeException, "#{self.tag}.#{key}" unless (value_ >= min) and (value_ <= max)
    self.set key, Integer.new(value_).toString
  end

  def set (key:String, value_:long):void
    self.set key, Long.new(value_).toString
  end

  def set (key:String, value_:long, min:long, max:long):void
    raise ParameterRangeException, "#{self.tag}.#{key}" unless (value_ >= min) and (value_ <= max)
    self.set key, Long.new(value_).toString
  end

  def set (key:String, value:String, max_len:int):void
    raise ParameterLengthException, "#{self.tag}.#{key}" unless value and (value.length() <= max_len)
    self.set key, value
  end

  def set (key:String, value:String, min_len:int, max_len:int):void
    raise ParameterLengthException, "#{self.tag}.#{key}" unless value and (value.length() <= max_len) and (value.length() >= min_len)
    self.set key, value
  end

end # class
