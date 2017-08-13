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
# Application level stuff.
#
import android.app.Activity
import android.content.Context
import android.content.Intent

#
# Std library support.
# 
import java.lang.String
import java.util.ArrayList
import java.util.Map
import java.util.List

#
# Exception handler.
#
import java.lang.Error
import java.lang.Exception
import java.lang.StackTraceElement
import java.lang.System
import java.lang.Thread
import java.lang.Thread.UncaughtExceptionHandler




#####
#
# Class for intercepting unhandled exceptions.
#
class AppExceptionHandler
  implements UncaughtExceptionHandler

  # Generally, the main activity will set
  # all these up based on some application
  # specific defaults.
  attr_accessor pass_through:boolean,
                email_addr:String,
                email_subj:String,
                email_text:String

  def initialize (act:Activity)
    @old_handler  = UncaughtExceptionHandler(nil)
    @pass_through = false
    @ctx          = act.getApplicationContext
    @act          = act
  end

  def initialize (ctx:Context)
    @old_handler  = UncaughtExceptionHandler(nil)
    @pass_through = false
    @ctx          = ctx.getApplicationContext
  end

  def install:void
    @old_handler = Thread.getDefaultUncaughtExceptionHandler
    Thread.setDefaultUncaughtExceptionHandler self
  end

  def remove:void
    Thread.setDefaultUncaughtExceptionHandler @old_handler   if @old_handler
  end

  #
  # From the Thread::UncaughtExceptionHandler interface.
  #

  def uncaughtException (thd:Thread, exc:Throwable):void
    # Find the original error.
    cause = exc
    while cause.getCause
      cause = cause.getCause
    end

    # Format the stack dump into a message string array.
    msg = []

    msg.add "Caught an error:"
    msg.add "    " + cause.toString
#    msg.add cause.getMessage
    msg.add ""
    msg.add "Stack trace follows:"

    stack = cause.getStackTrace

    stack.each do |element:StackTraceElement|
      msg.add(
        "    "  + element.getFileName   +
        ":"     + element.getLineNumber +
        "  -  " + element.getMethodName +
        (element.isNativeMethod ? " (native code)" : "")
      )
    end

    # Dump messages to the debug stream too,
    # however, limit the output to the top
    # few lines.  Some traces are huge, and we
    # don't want to push out too much of the
    # runtime trace from the message queue.
    #
    # Our output gets intermingled with the
    # normal trace log for some reason, so
    # let's wait just a moment and see if that
    # helps flush the buffer.  There does not
    # seem to be an actual method to do so.
    begin
      Thread.sleep 500
    rescue Exception => exc
    end

    idx = 0
    Debug.e "--------------------"
    msg.each do |line:String|
      Debug.e line
      idx += 1
      break if idx > 29
    end

    # Launch our exception activity.
    hand_ui = Intent.new @ctx, AppExceptionHandlerActivity.class
    hand_ui.addFlags Intent.FLAG_ACTIVITY_NEW_TASK 
    hand_ui.addFlags Intent.FLAG_ACTIVITY_SINGLE_TOP
    hand_ui.addFlags Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
    hand_ui.addFlags Intent.FLAG_ACTIVITY_NO_HISTORY
    hand_ui.addFlags Intent.FLAG_FROM_BACKGROUND   unless @act
    hand_ui.putStringArrayListExtra AppExceptionHandlerActivity.EXCEPTION_KEY, ArrayList(msg)
    hand_ui.putExtra AppExceptionHandlerActivity.EMAIL_ADDR_KEY, @email_addr   if @email_addr
    hand_ui.putExtra AppExceptionHandlerActivity.EMAIL_SUBJ_KEY, @email_subj   if @email_subj
    hand_ui.putExtra AppExceptionHandlerActivity.EMAIL_TEXT_KEY, @email_text   if @email_text
    @ctx.startActivity hand_ui 

    # Pass through.
    if @pass_through and @old_handler
      @old_handler.uncaughtException thd, exc
    else
      # Removes the activity from the back stack.
      @act.finish if @act

      # Terminate the thread so the UI isn't hung.
      System.exit 2
    end
  end

end # class
