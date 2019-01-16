require 'set'
class LowerCaseEnumerator
  def initialize(banned_words)
    @symbol_table = Set.new
    banned_words.each { |word| @symbol_table.add word }
    @token = 'a'
  end

  def get_token
    increment_token
    increment_token while @symbol_table.include? @token
    @token
  end

  def increment_token
    if @token[-1] != 'z'
      @token[-1] = (@token[-1].ord + 1).chr
    else
      # All chars are z or a one further back can be
      if @token.chars.all? { |c| c == 'z' }
        @token = 'a' * (@token.size + 1)
      else
        # Go back recursively
        @original_size = @token.size
        increment_helper
      end
    end
  end

  attr_reader :token

  def table
    @symbol_table
  end

  def increment_helper
    if @token[-1] != 'z'
      @token[-1] = (@token[-1].ord + 1).chr
      last = 'a' * (@original_size - @token.size)
      @token << last
    else
      @token = @token[0...-1]
      increment_helper
    end
  end
end
