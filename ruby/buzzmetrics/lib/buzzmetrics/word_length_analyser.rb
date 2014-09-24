require 'json'

puts 'loading'

module Buzzmetrics

  def self.citations
    @citations ||= JSON.parse(File.read('data/api/citations_3m.json'))["results"]
  end

  def self.title_length_ranges
    (1..300).each_slice(10).map do |entries|
      (entries.first..entries.last)
    end
  end

  def self.analyse_title_length
    citations.map do |citation|
      { title: citation["title"], score: citation["score"], title_length: citation["title"].size }
    end.group_by do |citation|
      title_length_ranges.find { |r| r.include?(citation[:title_length]) }
    end.map do |r, entries|
      { range: r.inspect, entries: entries.size }
    end
  end
end
