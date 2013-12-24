# encoding: utf-8

## String

class String #:nodoc

  def permalink(underscore = false)
    # if the slug includes one "_" at least, we consider that the "_" is used instead of "-".
    _permalink = if !self.index('_').nil?
      self.to_url(replace_whitespace_with: '_')
    else
      self.to_url
    end

    underscore ? _permalink.underscore : _permalink
  end

  def permalink!(underscore = false)
    replace(self.permalink(underscore))
  end

  alias :parameterize! :permalink!

end


# class String #:nodoc

#   def permalink(underscore = false)
#     permalink = self.to_ascii.parameterize
#     underscore ? permalink.underscore : permalink
#   end

#   def permalink!(underscore = false)
#     replace(self.permalink(underscore))
#   end

#   alias :parameterize! :permalink!

# end