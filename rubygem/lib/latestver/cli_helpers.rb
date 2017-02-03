module Latestver
  class CliHelpers

    def self.output(options, data)
      data_out = data

      unless data_out.is_a? Exception

        if options[:select]
          s = options[:select].split('.')
          while s.length > 0 and not data_out.nil?
            data_out = data_out[s.shift]
          end
        end

        return nil unless data_out

      end

      case options[:output]
        when 'json'
          if data_out.is_a? String
            data_out = {
                value: data_out,
                error: '',
            }
          elsif data_out.is_a? Exception
            data_out = {
                error: data_out.message,
                value: '',
            }
          end
          JSON.pretty_generate(data_out)
        else
          if data_out.is_a? Exception
            "ERROR: #{data_out.message}"
          else
            data_out
          end
      end
    end

  end
end
