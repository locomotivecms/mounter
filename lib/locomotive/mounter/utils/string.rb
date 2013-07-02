# encoding: utf-8

## String

class String #:nodoc

  def permalink(underscore = false)
    permalink = self.to_ascii.parameterize
    underscore ? permalink.underscore : permalink
  end

  def permalink!(underscore = false)
    replace(self.permalink(underscore))
  end

  alias :parameterize! :permalink!

end