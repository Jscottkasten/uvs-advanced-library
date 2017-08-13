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
# Std library support.
#
import java.io.File
import java.io.FileOutputStream
import java.io.OutputStreamWriter

import java.lang.String
import java.lang.StringBuilder
import java.util.List

import java.util.concurrent.locks.ReentrantLock




#####
#
# Class to assist with debugging.
#
class Debug
  DEFAULT_MAX_MSG_QUEUE = 100

  LEVEL_ERROR     = 0
  LEVEL_WARNING   = 1
  LEVEL_INFO      = 2
  LEVEL_DEBUG     = 3
  LEVEL_VERBOSE   = 4

  @@max_msg_queue = DEFAULT_MAX_MSG_QUEUE # Number of crash lines to capture.
  @@debug_lock    = ReentrantLock.new
  @@msg_queue     = List(nil)
  @@is_enabled    = false
  @@debug_level   = LEVEL_WARNING

  #
  # Class methods.
  #
  def self.d (msg:String):boolean
    return self.add_to_ring_buffer msg, LEVEL_DEBUG
  end

  def self.d (msg_:StringBuilder):boolean
    msg = msg_.toString
    return self.add_to_ring_buffer msg, LEVEL_DEBUG
  end

  def self.e (msg:String):boolean
    return self.add_to_ring_buffer msg, LEVEL_ERROR
  end

  def self.e (msg_:StringBuilder):boolean
    msg = msg_.toString
    return self.add_to_ring_buffer msg, LEVEL_ERROR
  end

  def self.i (msg:String):boolean
    return self.add_to_ring_buffer msg, LEVEL_INFO
  end

  def self.i (msg_:StringBuilder):boolean
    msg = msg_.toString
    return self.add_to_ring_buffer msg, LEVEL_INFO
  end

  def self.w (msg:String):boolean
    return self.add_to_ring_buffer msg, LEVEL_WARNING
  end

  def self.w (msg_:StringBuilder):boolean
    msg = msg_.toString
    return self.add_to_ring_buffer msg, LEVEL_WARNING
  end

  def self.v (msg:String):boolean
    return self.add_to_ring_buffer msg, LEVEL_VERBOSE
  end

  def self.v (msg_:StringBuilder):boolean
    msg = msg_.toString
    return self.add_to_ring_buffer msg, LEVEL_VERBOSE
  end

  #private
  def self.add_to_ring_buffer (msg:String, level:int):boolean
    return false unless @@is_enabled
    return false unless level <= @@debug_level

    begin
      @@debug_lock.lock
      @@msg_queue = []        unless @@msg_queue
      @@msg_queue.remove  0     if   @@msg_queue.size >= @@max_msg_queue
      @@msg_queue.add msg
    ensure
      @@debug_lock.unlock
    end

    return true
  end

  def self.dump_to_string:String
    @@debug_lock.lock

    sb = StringBuilder.new 4096
    if @@msg_queue
      @@msg_queue.each do |line:String|
        sb.append line
        sb.append "\n"
      end
    end

    return sb.toString
  ensure
    @@debug_lock.unlock
  end

  def self.dump_to_array:List
    @@debug_lock.lock
    array = []
    array.addAll @@msg_queue if @@msg_queue
    return array
  ensure
    @@debug_lock.unlock
  end

  def self.dump_to_file (file:File):void
    fos = FileOutputStream.new(file)
    osw = OutputStreamWriter.new(fos, "UTF-8")
    msg = self.dump_to_array

    msg.each do |line:String|
      osw.write line
      osw.write "\n"
    end

    osw.close
  end

  def self.is_enabled:boolean
    return @@is_enabled
  end

  def self.enable:void
    @@is_enabled = true
  end

  def self.disable:void
    @@is_enabled = false
  end

  def self.clear:void
    @@debug_lock.lock
    @@msg_queue = List(nil)
  ensure
    @@debug_lock.unlock
  end

  def self.max_msg_queue:int
    return @@max_msg_queue
  end

  def self.max_msg_queue (size:int):void
    return unless size >= 1

    begin
     @@debug_lock.lock
     @@max_msg_queue = size

     if @@msg_queue
       @@msg_queue.remove 0   while @@msg_queue.size > size
     end
    ensure
      @@debug_lock.unlock
    end
  end

  def self.level= (level:int):void
    @@debug_level = level
  end

  def self.level:int
    @@debug_level
  end

end # class
