require 'test_helper'
require 'vimeo/advanced/upload'

module Vimeo
  module Advanced
    class UploadTest < ::Test::Unit::TestCase
      class Vimeo::Advanced::Upload
        class HTTP < Struct.new(:host, :port)
          class Post
            def initialize uri
              @uri = uri
              @params = {}
            end

            def []= k,v
              @params[k] = v
            end
          end
        end
      end

      def test_upload
        ul = Vimeo::Advanced::Upload.new('a', 'b')

        def ul.get_upload_ticket *args
          'foo'
        end

        def ul.NET
          FakeHTTP
        end

        ul.upload(__FILE__, 'test', 'testing')
      end
    end
  end
end
