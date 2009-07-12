require 'webrick/httputils'

module Vimeo
  module Advanced

    class Upload < Vimeo::Advanced::Base

      def get_upload_ticket(auth_token)
        sig_options = {
          :auth_token => auth_token,
          :method => "vimeo.videos.getUploadTicket"
        }

        make_request sig_options
      end

      def check_upload_status(ticket_id, auth_token)
        sig_options = {
          :ticket_id => ticket_id,
          :auth_token => auth_token,
          :method => "vimeo.videos.checkUploadStatus"
        }

        make_request sig_options
      end

      ###
      # Upload +file+ to vimeo with +ticket_id+ and +auth_token+
      def upload file, ticket_id, auth_token
        boundary = rand_string 20

        enctype = "multipart/form-data; boundary=#{boundary}"

        file_part = file_to_multipart(file)

        params = {
          :auth_token => auth_token,
          :ticket_id  => ticket_id
        }
        params[:api_sig] = generate_api_sig params

        data = (params.map { |k,v| param_to_multipart(k,v) } +
         [file_part]
        ).map { |part|
          "--#{boundary}\r\n#{part}"
        }.join + "--#{boundary}--\r\n"

        uri = URI.parse('http://vimeo.com/services/upload')

        http_ctx  = Net::HTTP.new(uri.host, uri.port)
        request   = Net::HTTP::Post.new(uri.request_uri)
        request['Content-Type'] = enctype
        request['Content-Length'] = data.size.to_s
        http_ctx.request(request, data)
      end

      private
      def mime_value_quote(str)
        str.to_s.gsub(/(["\r\\])/){|s| '\\' + s}
      end

      def param_to_multipart name, value
        "Content-Disposition: form-data; name=\"#{mime_value_quote(name)}\"" +
          "\r\n#{value}\r\n"
      end

      def file_to_multipart file
        file_name = File.basename(file)

        headers = nil

        File.open(file, 'rb') { |fh|

          mime_type = WEBrick::HTTPUtils.mime_type(
            file,
            WEBrick::HTTPUtils::DefaultMimeTypes
          )

          headers = [
            "Content-Disposition: form-data; name=\"" +
                  "#{mime_value_quote(file)}\"; " +
                  "filename=\"#{mime_value_quote(file_name)}\"",
            "Content-Transfer-Encoding: binary",
          ]

          headers << "Content-Type: #{mime_type}" if mime_type
          headers << nil
          headers << fh.read
        }
        headers.join("\r\n") + "\r\n"
      end

    end

  end # Advanced
end # Vimeo
