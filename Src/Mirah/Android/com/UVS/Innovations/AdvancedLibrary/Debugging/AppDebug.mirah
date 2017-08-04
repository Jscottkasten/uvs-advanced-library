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

package com.UVS.Innovations.AdvancedLibrary.Debugging

#
# Android stuff.
#
import android.util.Log

#
# Std library support.
#
import java.lang.String
import java.lang.StringBuilder

import java.util.concurrent.locks.ReentrantLock




#####
#
# Class to assist with debugging.
#
class AppDebug < Debug
  DEFAULT_TAG  = "UVS AdvLibApp"
  @@tag        = DEFAULT_TAG

  #
  # Class methods.
  #
  def self.d (msg:String):void
    Log.d(@@tag, msg) if Debug.d msg
  end

  def self.d (msg_:StringBuilder):void
    msg = msg_.toString()
    Log.d(@@tag, msg) if Debug.d msg
  end

  def self.e (msg:String):void
    Log.e(@@tag, msg) if Debug.e msg
  end

  def self.e (msg_:StringBuilder):void
    msg = msg_.toString()
    Log.e(@@tag, msg) if Debug.e msg
  end

  def self.i (msg:String):void
    Log.i(@@tag, msg) if Debug.i msg
  end

  def self.i (msg_:StringBuilder):void
    msg = msg_.toString()
    Log.i(@@tag, msg) if Debug.i msg
  end

  def self.w (msg:String):void
    Log.w(@@tag, msg) if Debug.w msg
  end

  def self.w (msg_:StringBuilder):void
    msg = msg_.toString()
    Log.w(@@tag, msg) if Debug.w msg
  end

  def self.v (msg:String):void
    Log.v(@@tag, msg) if Debug.v msg
  end

  def self.v (msg_:StringBuilder):void
    msg = msg_.toString()
    Log.v(@@tag, msg) if Debug.v msg
  end

end # Class
