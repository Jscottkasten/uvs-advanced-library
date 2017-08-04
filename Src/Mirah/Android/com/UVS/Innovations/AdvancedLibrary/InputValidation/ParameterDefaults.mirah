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

package com.UVS.Innovations.AdvancedLibrary.InputValidation

#
# Date and time support.
#
import java.util.Calendar
import java.util.GregorianCalendar
import java.util.TimeZone

#
# Std library support.
#
import java.lang.Class
import java.lang.Integer
import java.lang.Long
import java.lang.Object
import java.lang.String
import java.util.ArrayList
import java.util.HashMap

#
# Exceptions.
#
import java.lang.Error
import java.lang.Exception




#####
#
# Class for simplified function parameters and
# default initializers handling.
#
class ParameterDefaults

  def self.defaults:HashMap
    # No defaults here, but needed for derived classes.
    # This is where the defaults array originates.
    return HashMap.new
  end

  protected def disperse_parms:HashMap
    # This is useful for debugging as all derived classes
    # are tagged with their actual names which can be
    # used in debug output.
    temp      = self.getClass().getName()
    @tag      = temp.substring(temp.lastIndexOf(".") + 1)

    # By default, we just pass the parameters up
    # the call stack to each layer of derived
    # classes.
    return @parms
  end

  # This is where we construct the array of
  # defaults, then override it with the input
  # parameters one by one.
  def initialize
    @parms = self.defaults
    self.disperse_parms
  end

  def initialize (parms:HashMap)
    filter    = self.defaults
    filter.keySet().each do |key|
      filter[key] = parms[key] if parms.containsKey(key)
    end
    @parms    = filter

    self.disperse_parms
  end

end # Class
