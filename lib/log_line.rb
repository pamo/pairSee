require 'time'
class LogLine
  attr_reader :line

  def initialize line
    @line = line
  end

  def authored_by?(*people)
    return people.empty? ? false : people.all? { |person|
      /(^|\s+|\W)#{person}(\s+|$|\W)/i =~ line
    }
  end

  def contains_card? card_prefix
    line.match(card_prefix)
  end

  def contains_card_name? card_name
    git_regex = /#{card_name}[\]\s\[,:]/
    git_matcher = line.match(git_regex)
    !git_matcher.nil?
  end

  def card_name card_prefix
    regex = /(#{card_prefix}\d+)/
    matcher = line.match(regex)
    matcher.nil? ? nil : (line.match regex)[1]
  end

  def card_number card_prefix
    card_num = card_name(card_prefix)
    card_num ? card_num.gsub(card_prefix, "") : nil
  end

  def merge_commit?
    line.match("Merge remote-tracking branch") || line.match("Merge branch")
  end

  def date
    regex = /(\d{4}-\d{2}-\d{2})/
    matcher = line.match(regex)
    part_to_parse = matcher.nil? ? "" : (line.match regex)[1]
    Date.parse(part_to_parse)
  end

  def not_by_pair? devs
    devs.any? { |dev| authored_by?(dev) || merge_commit? }
  end

  def to_s
    line
  end
end
