#
# Copyright (c) 2011 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

module RightScale

  # Class encapsulating the actual value of a credential.
  class CredentialValue

    include Serializable

    # Namespace-unique identifier for this credential value
    attr_accessor :id

    # Last-modified timestamp for this credential value
    attr_accessor :modified_at

    # (String) MIME type of the value's envelope, e.g. an encoding or encryption format,
    # or nil if there is no envelope MIME type.
    attr_accessor :envelope_mime_type

    # The value (content) of this credential.
    attr_accessor :value

    # Initialize fields from given arguments
    def initialize(*args)
      @id                 = args[0] if args.size > 0
      @modified_at        = args[1] if args.size > 1
      @envelope_mime_type = args[2] if args.size > 2
      @value              = args[3] if args.size > 3
    end

    # Array of serialized fields given to constructor
    def serialized_members
      [ @id, @modified_at, @envelope_mime_type, @value ]
    end
  end
end