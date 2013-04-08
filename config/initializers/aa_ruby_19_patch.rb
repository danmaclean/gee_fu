# encoding: utf-8
if Gem::Version.new(''+RUBY_VERSION) >= Gem::Version.new("1.9.0")
 
  # Force MySQL results to UTF-8.
  #
  # Source: http://gnuu.org/2009/11/06/ruby19-rails-mysql-utf8/
  # require 'mysql'
 
  # class Mysql::Result
  #   def encode(value, encoding = "utf-8")
  #     String === value ? value.force_encoding(encoding) : value
  #   end
 
  #   def each_utf8(&block)
  #     each_orig do |row|
  #       yield row.map {|col| encode(col) }
  #     end
  #   end
  #   alias each_orig each
  #   alias each each_utf8
 
  #   def each_hash_utf8(&block)
  #     each_hash_orig do |row|
  #       row.each {|k, v| row[k] = encode(v) }
  #       yield(row)
  #     end
  #   end
  #   alias each_hash_orig each_hash
  #   alias each_hash each_hash_utf8
  # end
 
  #
  # Source: https://rails.lighthouseapp.com/projects/8994/tickets/
  # 2188-i18n-fails-with-multibyte-strings-in-ruby-19-similar-to-2038
  # (fix_params.rb)
 
  module ActionController
    class Request
      private
      # Convert nested Hashs to HashWithIndifferentAccess and replace
      # file upload hashs with UploadedFile objects
      def normalize_parameters(value)
        case value
          when Hash
            if value.has_key?(:tempfile)
              upload = value[:tempfile]
              upload.extend(UploadedFile)
              upload.original_path = value[:filename]
              upload.content_type = value[:type]
             upload
           else
             h = {}
             value.each { |k, v| h[k] = normalize_parameters(v) }
               h.with_indifferent_access
             end
          when Array
            value.map { |e| normalize_parameters(e) }
          else
            value.force_encoding(Encoding::UTF_8) if value.respond_to?(:force_encoding)
            value
          end
        end
      end
    end
 
   #
   # Source: https://rails.lighthouseapp.com/projects/8994/tickets/
   # 2188-i18n-fails-with-multibyte-strings-in-ruby-19-similar-to-2038
   # (fix_renderable.rb)
   #
   module ActionView
     module Renderable #:nodoc:
       private
         def compile!(render_symbol, local_assigns)
           locals_code = local_assigns.keys.map { |key| "#{key} = local_assigns[:#{key}];" }.join
           source = <<-end_src
def #{render_symbol}(local_assigns)
old_output_buffer = output_buffer;#{locals_code};#{compiled_source}
ensure
self.output_buffer = old_output_buffer
end
end_src
           source.force_encoding(Encoding::UTF_8) if source.respond_to?(:force_encoding)
 
           begin
             ActionView::Base::CompiledTemplates.module_eval(source, filename, 0)
             rescue Errno::ENOENT => e
             raise e # Missing template file, re-raise for Base to rescue
           rescue Exception => e # errors from template code
             if logger = defined?(ActionController) && Base.logger
               logger.debug "ERROR: compiling #{render_symbol} RAISED #{e}"
               logger.debug "Function body: #{source}"
               logger.debug "Backtrace: #{e.backtrace.join("\n")}"
             end
           raise ActionView::TemplateError.new(self, {}, e)
         end
       end
    end
  end
end
