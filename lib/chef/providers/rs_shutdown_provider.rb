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

class Chef

  class Provider

    # Scriptable system reboot chef provider.
    class RsShutdown < Chef::Provider

      # Load current
      #
      # === Return
      # true:: Always return true
      def load_current_resource
        true
      end

      # Schedules a reboot.
      #
      # === Return
      # true:: Always return true
      def action_reboot
        RightScale::ShutdownRequestProxy.submit(:level => ::RightScale::ShutdownRequest::REBOOT, :immediately => @new_resource.immediately)
        exit 0 if @new_resource.immediately
        true
      end

      # Schedules a reboot.
      #
      # === Return
      # true:: Always return true
      def action_stop
        RightScale::ShutdownRequestProxy.submit(:level => ::RightScale::ShutdownRequest::STOP, :immediately => @new_resource.immediately)
        exit 0 if @new_resource.immediately
        true
      end

      # Schedules a reboot.
      #
      # === Return
      # true:: Always return true
      def action_terminate
        RightScale::ShutdownRequestProxy.submit(:level => ::RightScale::ShutdownRequest::TERMINATE, :immediately => @new_resource.immediately)
        exit 0 if @new_resource.immediately
        true
      end

    end

  end

end

# self-register
Chef::Platform.platforms[:default].merge!(:rs_shutdown => Chef::Provider::RsShutdown)
