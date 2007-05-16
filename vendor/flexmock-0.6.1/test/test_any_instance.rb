#!/usr/bin/env ruby

#---
# Copyright 2006 by Jim Weirich (jweirich@one.net).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#+++

require 'test/unit'
require 'flexmock'

class TestStubbingOnNew < Test::Unit::TestCase
  include FlexMock::TestCase
  
  class Dog
    def bark
      :woof
    end
    def wag
      :tail
    end
  end

  class Cat
    attr_reader :name
    def initialize(name, &block)
      @name = name
      block.call(self) if block_given?
    end
  end
  
  class Connection
    def initialize(*args)
      yield(self) if block_given?
    end
    def send(args)
      post(args)
    end
    def post(args)
      :unstubbed
    end
  end

  def test_any_instance_allows_stubbing_of_existing_methods
    flexstub(Dog).any_instance do |obj|
      obj.should_receive(:bark).and_return(:whimper)
    end
    m = Dog.new
    assert_equal :whimper,  m.bark
  end
  
  def test_any_instance_stubs_still_have_existing_methods
    flexstub(Dog).any_instance do |obj|
      obj.should_receive(:bark).and_return(:whimper)
    end
    m = Dog.new
    assert_equal :tail,  m.wag
  end

  def test_any_instance_will_pass_args_to_new
    flexstub(Cat).any_instance do |obj|
      obj.should_receive(:meow).and_return(:scratch)
    end
    x = :not_called
    m = Cat.new("Fido") { x = :called }
    assert_equal :scratch,  m.meow
    assert_equal "Fido", m.name
    assert_equal :called, x
  end

  def test_any_instance_stub_verification_happens_on_teardown
    flexstub(Dog).any_instance do |obj|
      obj.should_receive(:bark).once.and_return(nil)
    end
    
    fido = Dog.new    
    ex = assert_raise(Test::Unit::AssertionFailedError) { flexmock_teardown }
    assert_match(/method 'bark\(.*\)' called incorrect number of times/, ex.message)
  end

  def test_any_instance_reports_error_on_non_classes
    ex = assert_raise(ArgumentError) { 
      flexstub(Dog.new).any_instance do |obj|
        obj.should_receive(:hi)
      end
    }
    assert_match(/Class/, ex.message)
    assert_match(/any_instance/, ex.message)
  end
  
  # Current behavior does not install stubs into the block passed to new. 
  # This is rather difficult to achieve, although it would be nice.  For the
  # moment, we assure that they are not stubbed, but I am willing to change 
  # this in the future.
  def test_blocks_on_new_do_not_have_stubs_installed
    flexstub(Connection).any_instance do |new_con|
      new_con.should_receive(:post).and_return {
        :stubbed
      }
    end
    block_run = false
    Connection.new do |c|
      assert_equal :unstubbed, c.send("hi")
      block_run = true
    end
    assert block_run
  end
end
