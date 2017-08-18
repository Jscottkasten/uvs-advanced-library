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
# Android stuff.
#
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.preference.PreferenceManager;

#
# Std library support.
#
import java.lang.String;
import java.util.concurrent.locks.ReentrantLock;
import java.util.Map;

import java.io.File;



#####
#
# Class for maintaining and accessing
# our individual application settings.
#
class AppSettingsStore < SettingsStore

    DEFAULTS = {
                 "input_encoding"  => "UTF-8",
                 "output_encoding" => "UTF-8"
               }

  # Boiler plate.
  def self.defaults:Map
    array = SettingsStore.defaults

    # NOTE: In the derived class, even
    # if you don't have a default value
    # for something, enter the key and
    # mark it as "__EMPTY__" in this
    # array so the the store manager
    # has a complete list of keys to
    # work with.  IF YOU DON'T DO THIS
    # YOUR DATA WILL GET FILTERED OUT
    # BY THE ROOT DEFAULTS CLASS.  IT
    # DROPS DATA FOR WHICH IT DOESN'T
    # SEE A KNOWN KEY IN THE DEFAULTS
    # ARRAY AS A SECURITY MEASURE!!!
    array.putAll DEFAULTS

    return array
  end

  # Boiler plate.
  #protected
  def collect_defaults:Map
    array = super
    array.putAll DEFAULTS
    return array
  end    

  # Boiler plate.
  #protected
  def disperse_parms:Map
    @parms = super

    # Default to read only status.
    self.read_only = true

    return @parms
  end

  # Boiler plate.
  def initialize
    super
  end

  # Here, we do some extra setup after the
  # boiler plate super call.
  def initialize (ctx:Context, parms:Map)
    super parms

    @ctx   = ctx.getApplicationContext
    @prefs = PreferenceManager.getDefaultSharedPreferences @ctx

    self.read_only = false
    self.reload
  end

  # This method reads in the saved settings from
  # preferences storage one at a time.  If the setting
  # was absent, then the default is used and the
  # initialized value is saved back to the storage.
  # The final value is stored in the settings singleton
  # so all threads see the same data.
  #protected
  def reload:void
    self.lock
    return if self.is_loaded

    # Read each of the listed keys from the actual
    # permanent storage media.
    @parms.keySet.each do |key:String|
      @parms[key] = @prefs.getString key, ""
    end

    # Mark it as complete.
    self.is_loaded = true
  ensure
    self.unlock
  end

  #
  # General access methods.
  #

  # This adds backing store functionality.
  def set (key:String, value:String):void
    super key, value

    editor = @prefs.edit
    editor.putString key, value
    editor.commit
  end

  # This checks to be sure the store is ready.
  def get (key:String):String
    raise SettingsStoreNotLoadedException unless self.is_loaded

    return (super key)
  end

end # class
