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
# Class for validating various types of input.
#
# Thows three types of exceptions:
#    ParameterLengthException
#    ParameterFormatException
#    ParameterRangeException
#
class ParameterValidator < ParameterDefaults

  VALIDATOR_MAX_OFFSET_FIELD_LENGTH = 32

  def self.defaults:HashMap
    array = ParameterDefaults.defaults

    # We don't really need to add anything
    # for this class, so just pass it on up.

    # Even if a derived class doesn't need
    # this, it is best to implement a stub
    # like this due to the way Java handles
    # class methods.

    return array
  end

  protected def disperse_parms:HashMap
    @parms = super

    # No local parameters to disperse.

    # Even if you don't want to disperse
    # local parameters, you should still
    # implement a stub like this in your
    # derived class for the simple reason
    # that your derived @parms is NOT the
    # same as this class's @parms.  I.E.
    # @parms is NOT inherited.  It is only
    # this design pattern the links all
    # the @parms to the same reference.

    return @parms
  end

  # Boiler plate.
  def initialize
    super
  end

  # Boiler plate.
  def initialize (parms:HashMap)
    super parms
  end

  #
  # Class specific methods.
  #
 
  def validate_boolean_array_field (key:String):boolean[]
    # No need to write back as the processing eliminates the possibility of junk stuffing.
    return (self.validate_boolean_array_field key, String(@parms[key]))
  end

  def validate_boolean_array_field (key:String, new_value:String):boolean[]
    size   = new_value.length()
    result = boolean[size]

    idx1 = 0
    while idx1 < size
      idx2 = idx1 + 1

      ss = new_value.substring(idx1, idx2)
      if    ss.equalsIgnoreCase("t")
        result[idx1] = true
      elsif ss.equalsIgnoreCase("f")
        result[idx1] = false
      else
        raise ParameterFormatException, "#{self.tag}.#{key}"
      end

      idx1 = idx2
    end

    return result
  end

  def validate_boolean_array_field (key:String, exact:int):boolean[]
    new_value = String(@parms[key])
    raise ParameterLengthException, "#{self.tag}.#{key}" unless new_value.length() == exact
    # No need to write back as the processing eliminates the possibility of junk stuffing.
    return (self.validate_boolean_array_field key, new_value)
  end

  def validate_boolean_array_field (key:String, exact:int, new_value:String):boolean[]
    raise ParameterLengthException, "#{self.tag}.#{key}" unless new_value.length() == exact
    return (self.validate_boolean_array_field key, new_value)
  end

  def validate_boolean_field (key:String):boolean
    # No need to write back here because the string comparison
    # effectively does a length check, thus averting junk
    # stuffing.
    return (self.validate_boolean_field key, String(@parms[key]))
  end

  def validate_boolean_field (key:String, new_value:String):boolean
    failed = false
    state  = false

    # Empty and non-existant values are treated as "false".
    if new_value and (new_value.length() > 0)
      if    new_value.equalsIgnoreCase("true")
        state  = true
      elsif new_value.equalsIgnoreCase("false")
      else
        failed = true
      end
    end

    raise ParameterFormatException, "#{self.tag}.#{key}" if failed
    return state
  end

  def validate_date_field (key:String):GregorianCalendar
    return (self.validate_date_field key, TimeZone.getTimeZone("UTC"))
  end

  def validate_date_field (key:String, new_value:String):GregorianCalendar
    return (self.validate_date_field key, new_value, TimeZone.getTimeZone("UTC"))
  end

  def validate_date_field (key:String, zone:TimeZone):GregorianCalendar
    result = self.validate_date_field key, String(@parms[key]), zone

    # Ensure we have a clean, well formated copy.
    @parms[key] = ParameterValidator.date_key result
    return result
  end

  def validate_date_field (key:String, new_value:String, zone:TimeZone):GregorianCalendar
    failed = true
    date   = GregorianCalendar.new(zone)
    date.set(1, 0, 1)

    if new_value and (new_value.length() > 0)
      begin
        idx1 = new_value.indexOf("/")
        if idx1 > 0
          idx2 = idx1 + 1
          idx3 = new_value.indexOf("/", idx2)
          idx4 = idx3 + 1
          if idx3 > idx2
            year   = Integer.new(new_value.substring(0, idx1)).intValue()
            month  = Integer.new(new_value.substring(idx2, idx3)).intValue()
            day    = Integer.new(new_value.substring(idx4)).intValue()
            date.set(year, month - 1, day)
            failed = false
          end
        end
      rescue Exception => exc
      rescue Error     => err
      end
    else
      failed = false
    end
    
    raise ParameterFormatException, "#{self.tag}.#{key}" if failed
    return date
  end

  def validate_date_offset_field (key:String):DateOffset
    # Too difficult to format and write back, so instead, just
    # make sure the length is reasonable.
    new_value = self.validate_max_field_length key, VALIDATOR_MAX_OFFSET_FIELD_LENGTH

    return (self.validate_date_offset_field key, new_value)
  end

  def validate_date_offset_field (key:String, new_value:String):DateOffset
    failed = false
    offset = 0
    field  = Calendar.DAY_OF_MONTH

    # Empty and non-existant values default to "0 Days".
    begin
      if new_value and (new_value.length() > 0)
        value = new_value.toUpperCase()
        if value.indexOf("START") == -1
          idx = value.indexOf(" ")
          if idx > 0
            offset = Integer.new(value.substring(0, idx)).intValue()
            failed = true if offset < 0

            if    value.indexOf("DAY")   != -1
              field   = Calendar.DAY_OF_MONTH
            elsif value.indexOf("WEEK")  != -1
              field   = Calendar.DAY_OF_MONTH
              offset *= 7
            elsif value.indexOf("MONTH") != -1
              field   = Calendar.MONTH
            elsif value.indexOf("YEAR")  != -1
              field   = Calendar.YEAR
            else
              failed = true
            end
          else
            failed = true
          end

          if value.indexOf("BEFORE") != -1
            offset *= -1
          end
        end
      end
    rescue Exception => exc
      failed = true
    rescue Error     => err
      failed = true
    end

    raise ParameterFormatException, "#{self.tag}.#{key}" if failed

    return DateOffset.new(field, offset)
  end

  def validate_exact_field_length (key:String, exact:int):String
    return (self.validate_exact_field_length key, exact, String(@parms[key]))
  end

  def validate_exact_field_length (key:String, exact:int, new_value:String):String
    raise ParameterLengthException, "#{self.tag}.#{key}" unless new_value and (new_value.length() == exact)
    return new_value
  end

  def validate_int_field (key:String):int
    value = self.validate_int_field key, String(@parms[key])

    # We write back to ensure the source was not stuffed
    # with junk.  For example, 1 MB of trailing spaces.
    @parms[key] = "#{value}"
    return value
  end

  def validate_int_field (key:String, min:int, max:int):int
    value = self.validate_int_field key, String(@parms[key])

    # Check the range.
    raise ParameterRangeException, "#{self.tag}.#{key}" if (value < min) or (value > max)

    # We write back to ensure the source was not stuffed
    # with junk.  For example, 1 MB of trailing spaces.
    @parms[key] = "#{value}"
    return value
  end

  def validate_int_field (key:String, new_value:String):int
    failed = false
    value  = 0

    begin
      if new_value
        value = Integer.parseInt(new_value)
      end
    rescue Exception => exc
      failed = true
    rescue Error     => err
      failed = true
    end

    raise ParameterFormatException, "#{self.tag}.#{key}" if failed
    return value
  end

  def validate_int_field (key:String, new_value:String, min:int, max:int):int
    value = self.validate_int_field key, new_value
    raise ParameterRangeException, "#{self.tag}.#{key}" if (value < min) or (value > max)
    return value
  end

  def validate_int_field (key:String, new_value:int, min:int, max:int):int
    raise ParameterRangeException, "#{self.tag}.#{key}" if (new_value < min) or (new_value > max)
    return new_value
  end

  def validate_long_field (key:String):long
    value = self.validate_long_field key, String(@parms[key])

    # We write back to ensure the source was not stuffed
    # with junk.  For example, 1 MB of trailing spaces.
    @parms[key] = "#{value}"
    return value
  end

  def validate_long_field (key:String, new_value:String):long
    failed = false
    value  = long(0)

    begin
      if new_value
        value = Long.parseLong(new_value)
      end
    rescue Exception => exc
      failed = true
    rescue Error     => err
      failed = true
    end

    raise ParameterFormatException, "#{self.tag}.#{key}" if failed
    return value
  end

  def validate_float_field (key:String):float
    value = self.validate_float_field key, String(@parms[key])

    # We write back to ensure the source was not stuffed
    # with junk.  For example, 1 MB of trailing spaces.
    @parms[key] = "#{value}"
    return value
  end

  def validate_float_field (key:String, min:float, max:float):float
    value = self.validate_float_field key, String(@parms[key])

    # Check the range.
    raise ParameterRangeException, "#{self.tag}.#{key}" if (value < min) or (value > max)

    # We write back to ensure the source was not stuffed
    # with junk.  For example, 1 MB of trailing spaces.
    @parms[key] = "#{value}"
    return value
  end

  def validate_float_field (key:String, new_value:String):float
    failed = false
    value  = 0

    begin
      if new_value
        value = Float.parseFloat(new_value)
      end
    rescue Exception => exc
      failed = true
    rescue Error     => err
      failed = true
    end

    raise ParameterFormatException, "#{self.tag}.#{key}" if failed
    return value
  end

  def validate_float_field (key:String, new_value:String, min:float, max:float):float
    value = self.validate_float_field key, new_value
    raise ParameterRangeException, "#{self.tag}.#{key}" if (value < min) or (value > max)
    return value
  end

  def validate_float_field (key:String, new_value:float, min:float, max:float):float
    raise ParameterRangeException, "#{self.tag}.#{key}" if (new_value < min) or (new_value > max)
    return new_value
  end

  def validate_max_field_length (key:String, max:int):String
    return (self.validate_max_field_length key, max, String(@parms[key]))
  end

  def validate_max_field_length (key:String, max:int, new_value:String):String
    raise ParameterLengthException, "#{self.tag}.#{key}" unless new_value and (new_value.length() <= max)
    return new_value
  end

  def validate_time_array_field (key:String):int[]
    result = self.validate_time_array_field key, String(@parms[key])

    # Recreate a sanitized version of the data.
    buffer = StringBuffer.new(result.length() * 6)
    idx    = 0
    while idx < result.length()
      buffer.append(ParameterValidator.time_to_string result[idx], result[idx + 1])

      idx += 2
      buffer.append(" ") if idx < result.length()
    end

    @parms[key] = buffer.toString()
    return result
  end

  def validate_time_array_field (key:String, new_value:String):int[]
    failed = false
    list   = ArrayList.new()

    # Treat missing or empty as an empty array.
    begin
      if new_value and (new_value.length() > 0)
        idx1 = 0
        idx2 = new_value.indexOf(":", idx1)
        idx3 = idx2 + 1
        idx4 = (idx2 > 0) ? (new_value.indexOf(" ", idx3)) : (-1)
        while idx2 > 0
          # Convert the fields.
          hour = Integer.new(new_value.substring(idx1, idx2))
          min  = Integer.new((idx4 > 0) ? new_value.substring(idx3, idx4) : new_value.substring(idx3))

          # Range check.
          ihr  = hour.intValue()
          imn  = min.intValue()
          if (ihr < 0) or (ihr > 23) or (imn < 0) or (imn > 59)
            failed = true
            break
          end

          # Collect it.
          list.add(hour)
          list.add(min)

          # Advance to the next.
          idx1 = idx4 + 1
          idx2 = (idx4 > 0) ? (new_value.indexOf(":", idx1)) : (-1)
          idx3 = idx2 + 1
          idx4 = (idx2 > 0) ? (new_value.indexOf(" ", idx3)) : (-1)
        end
      end
    rescue Exception => exc
      failed = true
    rescue Error     => err
      failed = true
    end

    raise ParameterFormatException, "#{self.tag}.#{key}" if failed

    # Build the result array.
    result = int[list.size()]
    idx    = 0
    while idx < list.size()
      val = Integer(list[idx])

      result[idx] = val.intValue()

      idx += 1
    end

    return result
  end

  def validate_time_array_field (key:String, exact:int):int[]
    result = self.validate_time_array_field key, String(@parms[key])

    raise ParameterLengthException, "#{self.tag}.#{key}" if (result.length() / 2) != exact

    # Recreate a sanitized version of the data.
    buffer = StringBuffer.new(exact * 6)
    idx    = 0
    while idx < result.length()
      buffer.append(ParameterValidator.time_to_string result[idx], result[idx + 1])

      idx += 2
      buffer.append(" ") if idx < result.length()
    end

    @parms[key] = buffer.toString()
    return result
  end

  def validate_time_array_field (key:String, exact:int, new_value:String):int[]
    result = self.validate_time_array_field key, new_value
    raise ParameterLengthException, "#{self.tag}.#{key}" if (result.length() / 2) != exact
    return result    
  end

  def validate_time_field (key:String):int[]
    value = (self.validate_time_field key, String(@parms[key]))

    # Write back to ensure what's there is clean.
    @parms[key] = ParameterValidator.time_to_string value
    return value
  end

  def validate_time_field (key:String, new_value:String):int[]
    failed = true
    hour   = 0
    min    = 0

    # Treat missing or empty as 0:00.
    begin 
      if new_value and (new_value.length() > 0)
        idx = new_value.indexOf(":")
        if idx > 0
          hour   = Integer.new(new_value.substring(0, idx)).intValue()
          min    = Integer.new(new_value.substring(idx + 1)).intValue()
          failed = false
        end
      end
    rescue Exception => exc
    rescue Error     => err
    end

    if failed or (hour < 0) or (hour > 23) or (min < 0) or (min > 59)
      #Debug.d "validate_time_field string=\"#{new_value}\", hour=#{hour}, min=#{min}, failed=#{failed}."
      raise ParameterRangeException, "#{self.tag}.#{key}"
    end

    result    = int[2]
    result[0] = hour
    result[1] = min

    return result
  end

  def validate_time_offset_field (key:String):int
    # Too difficult to format and write back, so instead, just
    # make sure the length is reasonable.
    new_value = self.validate_max_field_length key, VALIDATOR_MAX_OFFSET_FIELD_LENGTH
    return (self.validate_time_offset_field key, new_value)
  end

  def validate_time_offset_field (key:String, new_value:String):int
    failed = false
    offset = 0

    # Empty and non-existent fields are treated as "0".
    begin
      if new_value and (new_value.length() > 0)
        value = new_value.toUpperCase()
        if value.indexOf("START") == -1
          idx = value.indexOf(" ")
          if idx > 0
            num    = Integer.new(value.substring(0, idx)).intValue()
            failed = true if num < 0

            if    value.indexOf("MINUTE") != -1
              offset = num
            elsif value.indexOf("HOUR")   != -1
              offset = 60 * num
            else
              failed = true
            end
          else
            failed = true
          end

          if value.indexOf("BEFORE") != -1
            offset *= -1
          end
        end
      end
    rescue Exception => exc
      failed = true
    rescue Error     => err
      failed = true
    end

    raise ParameterFormatException, "#{self.tag}.#{key}" if failed
    return offset
  end

  def validate_time_zone_field (key:String):TimeZone
    result = self.validate_time_zone_field key, String(@parms[key])

    # Ensure we have a clean, well formated copy.
    @parms[key] = result.getID()
    return result
  end

  def validate_time_zone_field (key:String, new_value:String):TimeZone
    failed = true
    zone   = TimeZone(nil)

    if new_value and (new_value.length() > 0)
      begin
        zone   = TimeZone.getTimeZone(new_value)
        failed = false
      rescue Exception => exc
      rescue Error     => err
      end
    else
      zone   = TimeZone.getDefault()
      failed = false
    end
    
    raise ParameterFormatException, "#{self.tag}.#{key}" if failed
    return zone
  end

  #
  # Class methods.
  #

  # This type of key is used throughout the code.
  def self.date_key (gc:GregorianCalendar):String
    year  = gc.get(Calendar.YEAR)
    month = gc.get(Calendar.MONTH) + 1
    day   = gc.get(Calendar.DAY_OF_MONTH)
    return "#{year}/#{month}/#{day}"
  end

  def self.date_key (gc:GregorianCalendar, tz:TimeZone):String
    cpy = GregorianCalendar(gc.clone())
    cpy.getTimeInMillis()  # Force an internal update.
    cpy.setTimeZone(tz)

    return (ParameterValidator.date_key cpy)
  end

  def self.long_to_date (value:long):GregorianCalendar
    date   = GregorianCalendar.new(1, 0, 1)        # Faster than GC.new(), avoids
    date.setTimeZone(TimeZone.getTimeZone("UTC"))  # unnecessary getsystime() call.
    date.setTimeInMillis(value)                    # Wish there was a millis constructor.

    return date
  end

  def self.time_to_string (value:int[]):String
    return (((value[0] < 10) ? "0#{value[0]}:" : "#{value[0]}:") + ((value[1] < 10) ? "0#{value[1]}" : "#{value[1]}"))
  end

  def self.time_to_string (hour:int, min:int):String
    return (((hour < 10) ? "0#{hour}:" : "#{hour}:") + ((min < 10) ? "0#{min}" : "#{min}"))
  end

  def self.time_to_string (gc:GregorianCalendar):String
    hour = gc.get(Calendar.HOUR_OF_DAY)
    min  = gc.get(Calendar.MINUTE)

    return ParameterValidator.time_to_string hour, min
  end

  def self.zone_to_string (zone:TimeZone):String
    return zone.getID()
  end

  def self.zone_offset_to_string (zone:TimeZone):String
    offset    = zone.getRawOffset() / (60 * 1000)  # In Mins.
    minus     = (offset < 0)
    offset   *= -1 if minus
    hours     = offset / 60
    mins      = offset % 60
    time_str  = ParameterValidator.time_to_string hours, mins

    return ("GMT" + (minus ? "-" : "+") + time_str)
  end

end  # class
