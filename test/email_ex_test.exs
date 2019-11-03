defmodule EmailExTest do
  use ExUnit.Case

  test "nil is false." do
    assert not EmailEx.valid?(nil)
  end

  test "empty string is nil." do
    assert not EmailEx.valid?("")
  end

  test "fail without @domain." do
    assert not EmailEx.valid?("test")
  end

  test "a simple email with domain not dotted." do
    assert EmailEx.valid?("a@a")
  end

  test "a simple email with domain." do
    assert EmailEx.valid?("a@a.com")
  end

  test "dotted local part." do
    assert EmailEx.valid?("a.b@a.com")
  end

  test "local part with different characters." do
    assert EmailEx.valid?("a#b!test@a.com")
  end

  test "quoted string in local part." do
    assert EmailEx.valid?("\"a\"@a.com")
  end

  test "quoted string with quoted pair in local part." do
    assert EmailEx.valid?("\"a\\n\"@a.com")
  end

  describe "nasty stuff" do
    test "with comments" do
      assert EmailEx.valid?("john.smith(comment)@example.com")
      assert EmailEx.valid?("(comment)john.smith@example.com")
      assert EmailEx.valid?("john.(comment)smith@example.com")
      assert EmailEx.valid?("john(comment).smith@example.com")
    end

    test "local_part" do
      assert EmailEx.valid?("example-indeed@strange-example.com")
      assert EmailEx.valid?("simple@example.com")
      assert EmailEx.valid?("very.common@example.com")
      assert EmailEx.valid?("disposable.style.email.with+symbol@example.com")
      assert EmailEx.valid?("other.email-with-hyphen@example.com")
      assert EmailEx.valid?("user.name+tag+sorting@example.com")
      assert EmailEx.valid?("user%example.com@example.org")
      assert EmailEx.valid?("fully-qualified-domain@example.com")
      assert EmailEx.valid?("\"John..Doe\"@example.com")
      assert EmailEx.valid?("!def!xyz%abc@example.com")
      assert EmailEx.valid?("$A12345@example.com")
      assert EmailEx.valid?("customer/department=shipping@example.com")
      assert EmailEx.valid?("\"Abc@def\"@example.com")
      assert EmailEx.valid?("_somename@example.com")

      # in rfc 5322
      assert EmailEx.valid?("Joe.//Blow@example.com")
      # assert EmailEx.valid? "Fred\ Bloggs@example.com"
      # assert EmailEx.valid? "\" \"@example.org"
    end

    test "domain" do
      # in rfc 5322
      # assert EmailEx.valid? "jsmith@[IPv6:2001:db8::1]"
      assert EmailEx.valid?("jsmith@[192.168.2.1]")
    end
  end
end
