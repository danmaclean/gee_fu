# This little guy is needed unless you want to define a helper for every single one of your controllers
MissingSourceFile::REGEXPS << [/^cannot load such file -- (.+)$/i, 1]

# TZInfo needs to be patched.  In particular, you'll need to re-implement the datetime_new! method:
require 'tzinfo'

module TZInfo
  
  # Methods to support different versions of Ruby.
  module RubyCoreSupport #:nodoc:
    # Ruby 1.8.6 introduced new! and deprecated new0.
    # Ruby 1.9.0 removed new0.
    # Ruby trunk revision 31668 removed the new! method.
    # Still support new0 for better performance on older versions of Ruby (new0 indicates
    # that the rational has already been reduced to its lowest terms).
    # Fallback to jd with conversion from ajd if new! and new0 are unavailable.
    if DateTime.respond_to? :new!
      def self.datetime_new!(ajd = 0, of = 0, sg = Date::ITALY)
        DateTime.new!(ajd, of, sg)
      end
    elsif DateTime.respond_to? :new0
      def self.datetime_new!(ajd = 0, of = 0, sg = Date::ITALY)
        DateTime.new0(ajd, of, sg)
      end
    else
      HALF_DAYS_IN_DAY = rational_new!(1, 2)

      def self.datetime_new!(ajd = 0, of = 0, sg = Date::ITALY)
        # Convert from an Astronomical Julian Day number to a civil Julian Day number.
        jd = ajd + of + HALF_DAYS_IN_DAY
        
        # Ruby trunk revision 31862 changed the behaviour of DateTime.jd so that it will no
        # longer accept a fractional civil Julian Day number if further arguments are specified.
        # Calculate the hours, minutes and seconds to pass to jd.
        
        jd_i = jd.to_i
        jd_i -= 1 if jd < 0
        hours = (jd - jd_i) * 24
        hours_i = hours.to_i
        minutes = (hours - hours_i) * 60
        minutes_i = minutes.to_i
        seconds = (minutes - minutes_i) * 60
        
        DateTime.jd(jd_i, hours_i, minutes_i, seconds, of, sg)
      end
    end
  end
end

# Finally, we have this innocuous looking patch.  Without it, queries like this: current_account.tickets.recent.count
# would instantiate AR objects all (!!) tickets in the account, not merely return a count of the recent ones.
# See https://rails.lighthouseapp.com/projects/8994/tickets/5410-multiple-database-queries-when-chaining-named-scopes-with-rails-238-and-ruby-192
# (The patch in that lighthouse bug was not, in fact, merged in).
module ActiveRecord
  module Associations
    class AssociationProxy   
      def respond_to_missing?(meth, incl_priv)
        false
      end
    end
  end
end
