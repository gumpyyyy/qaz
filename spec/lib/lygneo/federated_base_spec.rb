#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Lygneo::Federated::Base do
  describe '#subscribers' do
    it 'throws an error if the including module does not redefine it' do
      class Foo
        include Lygneo::Federated::Base 
      end

      f = Foo.new

      proc{ f.subscribers(1)}.should raise_error /override subscribers/
    end
  end
end
