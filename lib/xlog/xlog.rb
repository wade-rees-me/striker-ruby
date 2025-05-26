# frozen_string_literal: true

require 'socket'
require 'etc'

module Xlog
  SYSLOG_ADDRESS   = '192.168.0.27'
  SYSLOG_PORT      = 10514
  SYSLOG_MSG_MAX   = 1024
  SYSLOG_FACILITY  = 1 << 3  # USER facility

  SYSLOG_EMERG     = 0
  SYSLOG_ALERT     = 1
  SYSLOG_CRIT      = 2
  SYSLOG_ERR       = 3
  SYSLOG_WARNING   = 4
  SYSLOG_NOTICE    = 5
  SYSLOG_INFO      = 6
  SYSLOG_DEBUG     = 7

  @socket = nil
  @server_addr = nil
  @hostname = Socket.gethostname rescue 'blackjack'
  @pid = Process.pid

  module_function

  def init_syslog(remote_host = SYSLOG_ADDRESS, port = SYSLOG_PORT)
    begin
      @socket = UDPSocket.new
      @server_addr = [remote_host, port]
      true
    rescue => e
      warn "init_syslog failed: #{e}"
      false
    end
  end

  def close_syslog
    @socket&.close
    @socket = nil
  end

  def xlog(severity, msg)
    return unless @socket && @server_addr

    priority = SYSLOG_FACILITY + severity
    packet = "<#{priority}>#{STRIKER_WHO_AM_I}: [version=#{STRIKER_VERSION}] [PID=#{@pid}] | #{msg}"

    packet = packet[0...SYSLOG_MSG_MAX] if packet.size > SYSLOG_MSG_MAX
    begin
      @socket.send(packet, 0, *@server_addr)
    rescue => e
      warn "xlog send failed: #{e}"
    end
  end

  def log_info(format, *args)
    xlog(SYSLOG_INFO, format % args)
  end

  def log_error(format, *args)
    xlog(SYSLOG_ERR, format % args)
  end

  def log_fatal(format, *args)
    xlog(SYSLOG_CRIT, format % args)
  end
end
