require 'webrick/httputils'
require 'curl'


module Vimeo
  module Advanced

    class Upload < Vimeo::Advanced::Base

      def get_upload_ticket(auth_token)
        sig_options = {
          :auth_token => auth_token,
          :method => "vimeo.videos.upload.getTicket"
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

			def confirm_upload(auth_token, ticket_id, json_manifest)
        sig_options = {
          :auth_token => auth_token,
					:ticket_id => ticket_id,
          :method => "vimeo.videos.upload.confirm"
        }
				api_sig = generate_api_sig(sig_options)
				puts "/api/rest/v2/?#{query(sig_options, api_sig).to_params}"
				self.class.post "/api/rest/v2/", :body => query(sig_options.merge(:json_manifest => json_manifest), api_sig)
      end

      ###
      # Upload +file+ to vimeo with +ticket_id+ and +auth_token+
      def upload file, ticket_id, end_point, auth_token
        params = {
          :auth_token => auth_token,
          :ticket_id  => ticket_id
        }
        params[:api_sig] = generate_api_sig params

        c = Curl::Easy.new(end_point)
        c.multipart_form_post = true
        c.http_post(
          *(params.map { |k,v| Curl::PostField.content(k.to_s, v) } +
          [Curl::PostField.file('file_data', file)])
        )
				{:files => [{:md5 => c.body_str}]}.to_json
      end

      def signature_for_file_upload(ticket_id, auth_token)
        sig_options = {
          :ticket_id => ticket_id,
          :auth_token => auth_token
        }
        generate_api_sig sig_options
      end
    end

  end # Advanced
end # Vimeo
