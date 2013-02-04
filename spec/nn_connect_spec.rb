require 'spec_helper'

# NOTE!
#
# Any specs added to this file should be mirrored in the nn_bind_spec.rb file too
# so that coverage remains complete.
#

module NNCore
  describe "nn_connect" do

    context "given an initialized library and" do
      before(:each) { LibNanomsg.nn_init }
      after(:each) { LibNanomsg.nn_term }


      context "given a valid socket" do
        before(:each) do
          LibNanomsg.nn_init
          @socket = LibNanomsg.nn_socket(AF_SP, NN_PUB)
        end

        after(:each) do
          LibNanomsg.nn_close(@socket)
          LibNanomsg.nn_term
        end

        it "returns a non-zero endpoint number for a valid INPROC address" do
          rc = LibNanomsg.nn_connect(@socket, "inproc://some_address")
          rc.should > 0
        end

        it "returns a non-zero endpoint number for a valid IPC address" do
          rc = LibNanomsg.nn_connect(@socket, "ipc:///tmp/some_address")
          rc.should > 0
        end

        it "returns a non-zero endpoint number for a valid TCP address" do
          rc = LibNanomsg.nn_connect(@socket, "tcp://127.0.0.1:5555")
          rc.should > 0
        end

        it "returns -1 for an invalid INPROC address" do
          rc = LibNanomsg.nn_connect(@socket, "inproc:/missing_first_slash")
          rc.should == -1
          LibNanomsg.nn_errno.should == EINVAL
        end

        it "returns -1 for an invalid INPROC address (too long)" do
          rc = LibNanomsg.nn_connect(@socket, "inproc://#{'a' * (NN_INPROCB_NAMELEN_MAX + 1)}")
          rc.should == -1
          LibNanomsg.nn_errno.should == ENAMETOOLONG
        end

        it "returns -1 for an invalid IPC address" do
          rc = LibNanomsg.nn_connect(@socket, "ipc:/missing_slashes)")
          rc.should == -1
          LibNanomsg.nn_errno.should == EINVAL
        end

#        it "returns -1 for an invalid TCP address (missing port)" do
#          rc = LibNanomsg.nn_connect(@socket, "tcp://*:")
#          rc.should == -1
#          LibNanomsg.nn_errno.should == EINVAL
#        end
#
#        it "returns -1 for an invalid TCP address (non-numeric port)" do
#          rc = LibNanomsg.nn_connect(@socket, "tcp://192.168.0.1:port")
#          rc.should == -1
#          LibNanomsg.nn_errno.should == EINVAL
#        end
#
#        it "returns -1 for an invalid TCP address (port number is out of range)" do
#          rc = LibNanomsg.nn_connect(@socket, "tcp://192.168.0.1:65536")
#          rc.should == -1
#          LibNanomsg.nn_errno.should == EINVAL
#        end

        it "returns -1 for an unsupported transport protocol" do
          rc = LibNanomsg.nn_connect(@socket, "zmq://192.168.0.1:65536")
          rc.should == -1
          LibNanomsg.nn_errno.should == EPROTONOSUPPORT
        end

        it "returns -1 for specifying a non-existent device using TCP transport" do
          pending # currently fails
          rc = LibNanomsg.nn_connect(@socket, "tcp://doesntexist:5555")
          rc.should == -1
          LibNanomsg.nn_errno.should == ENODEV
        end

        it "returns 2 when connecting twice to an existing endpoint" do
          rc = LibNanomsg.nn_connect(@socket, "inproc://some_endpoint")
          rc = LibNanomsg.nn_connect(@socket, "inproc://some_endpoint")
          rc.should == 2
        end
        
      end

      context "given an invalid file descriptor" do
        
        it "returns -1 and sets nn_errno to EBADF" do
          rc = LibNanomsg.nn_connect(0, "inproc://some_endpoint")
          rc.should == -1
          LibNanomsg.nn_errno.should == EBADF
        end
        
      end

    end
  end
end
