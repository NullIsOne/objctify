#
# Copyright Devexperts (2019)
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

require 'claide'
require 'logger'
require 'objctify/version'

module Objctify

  $logger = Logger.new(STDOUT)
  $logger.level = Logger::DEBUG
  
  class Command < CLAide::Command
    require 'objctify/command/init'
    require 'objctify/command/this'

    self.abstract_command = true
    self.command = 'objctify'
    self.version = Objctify::VERSION
    self.description = 'A tool'
    self.plugin_prefixes = %w[claide objctify]
  end
end
