# encoding: utf-8

## String

class String #:nodoc

  def permalink
    self.to_ascii.parameterize('-')
  end

  def permalink!
    replace(self.permalink)
  end

  alias :parameterize! :permalink!

end