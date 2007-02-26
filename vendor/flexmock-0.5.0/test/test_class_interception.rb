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

class Bark
  def listen
    :woof
  end
  def Bark.identify
    :barking
  end
end

class Meow
  def listen
    :meow
  end
end

class Dog
  def bark
    Bark.new
  end
  def bark_id
    Bark.identify
  end
end

class TestClassInterception < Test::Unit::TestCase
  include FlexMock::TestCase

  def test_original_functionality
    dog = Dog.new
    assert_equal :woof, dog.bark.listen
  end

  def test_interception
    interceptor = intercept(Bark).in(Dog).with(Meow)
    assert_kind_of FlexMock::ClassProxy, Dog::Bark
    assert_equal Meow, Dog::Bark.proxied_class
    dog = Dog.new
    assert_equal :meow, dog.bark.listen
  ensure
    interceptor.restore if interceptor
  end

  # Since interception leaves a proxy class behind, we want to make
  # sure interception works twice on the same object.  So we repeat
  # this test in full.  We don't know which tests will _actually_ run
  # first, but it doesn't matter as long as it is done twice.
  def test_interception_repeated
    test_interception
  end

  def test_interception_with_strings
    interceptor = intercept("Bark").in("Dog").with("Meow")
    assert_equal :meow, Dog.new.bark.listen
  ensure
    interceptor.restore if interceptor
  end

  def test_interception_with_symbols
    interceptor = intercept(:Bark).in(:Dog).with(:Meow)
    assert_equal :meow, Dog.new.bark.listen
  ensure
    interceptor.restore if interceptor
  end

  def test_interception_with_mixed_identifiers
    interceptor = intercept(:Bark).in("Dog").with(Meow)
    assert_equal :meow, Dog.new.bark.listen
  ensure
    interceptor.restore if interceptor
  end

  def test_interception_proxy_forward_other_methods
    d = Dog.new
    assert_equal :barking, d.bark_id

    interceptor = intercept(:Bark).in("Dog").with(Meow)
    interceptor.restore

    d = Dog.new
    assert_equal :barking, d.bark_id
  end

  def test_interceptions_fails_with_bad_class_names
    ex = assert_raises(FlexMock::BadInterceptionError) {
      intercept("BADNAME").in("Dog").with("Meow")
    }
    assert_match(/intercepted/, ex.message)
    assert_match(/BADNAME/, ex.message)

    ex = assert_raises(FlexMock::BadInterceptionError) {
      intercept(Bark).in("BADNAME").with("Meow")
    }
    assert_match(/target/, ex.message)
    assert_match(/BADNAME/, ex.message)

    ex = assert_raises(FlexMock::BadInterceptionError) {
      intercept(Bark).in("Dog").with("BADNAME")
    }
    assert_match(/replacement/, ex.message)
    assert_match(/BADNAME/, ex.message)
  end

end

class TestClassInterceptionExample < Test::Unit::TestCase
  include FlexMock::TestCase
  
  def setup
    @dog = Dog.new
    @mock = flexmock('bark')
    intercept(Bark).in(Dog).with(@mock)
  end
    
  def test_interception
    @mock.should_receive(:new).with_no_args.once.and_return(:purr)
    assert_equal :purr, @dog.bark
  end
end

class TestMockFactory < Test::Unit::TestCase
  def test_mock_returns_factory
    m = FlexMock.new("m")
    f = m.mock_factory
    assert_equal m, f.new
  end
end
