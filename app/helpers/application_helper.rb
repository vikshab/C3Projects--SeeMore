module ApplicationHelper
  def only_250_characters(some_long_text)
    if some_long_text.length > 250
      return some_long_text[0,425] + "..."
    else
      return some_long_text
    end
  end
end
