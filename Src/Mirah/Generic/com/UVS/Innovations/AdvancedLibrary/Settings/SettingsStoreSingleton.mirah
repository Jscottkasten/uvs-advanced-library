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
import java.lang.String
import java.util.Map

import java.util.concurrent.locks.ReentrantLock




#####
#
# The application sould use the SettingsStore outer
# class as its interface.  This class is internal.
# It is a singleton that just holds the raw data
# with no access protection, nor access to storage.
# The outer class handles all that.  This class
# does ensure that no matter how many threads the
# application has, or how many references are
# made to the settings object, that there is one
# and only one shared instance.
#
class SettingsStoreSingleton
  @@singleton      = SettingsStoreSingleton(nil)
  @@singleton_lock = ReentrantLock.new

  attr_accessor settings:Map,
                is_loaded:boolean

  def initialize (defaults:Map)
    @settings  = {}
    @settings.putAll defaults
    @is_loaded = false
  end

  def self.get_reference (defaults:Map):SettingsStoreSingleton
    @@singleton_lock.lock
    @@singleton = SettingsStoreSingleton.new defaults
     
    return @@singleton
  ensure
    @@singleton_lock.unlock
  end

  def lock
    @@singleton_lock.lock
  end

  def unlock
    @@singleton_lock.unlock
  end

end # class
