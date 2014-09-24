require 'json'
require 'csv'

module Buzzmetrics
  def self.citations
    JSON.parse(File.read('data/api/citations_3m.json'))["results"]
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
      { range: r.inspect, number_of_citations: entries.size }
    end
  end

  def self.analyse_title_length_csv
     csv_string = CSV.generate do |csv_out|
       csv_out << ["range", "number_of_entries"]
       analyse_title_length.each do |entry|
         csv_out << [ entry[:range], entry[:number_of_citations] ]
       end
     end
     csv_string
  end
end
