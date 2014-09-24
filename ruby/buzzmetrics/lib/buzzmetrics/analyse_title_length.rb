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

  def self.title_lengths_csv(input_csv, output_path)
    CSV.open(output_path, "wb") do |csv_out|
       csv_out << ["doi", "title", "score", "length"]
       CSV.parse(input_csv, headers: true).map do |citation|
         { title: citation["title"], score: citation["score"], title_length: citation["title"].size, doi: citation["doi"] }
      end.each do |entry|
         csv_out << [ entry[:doi], entry[:title], entry[:score], entry[:title_length] ]
       end
    end
  end

  def self.words_in_title(input_csv)
    CSV.parse(input_csv, headers: true).map do |citation|
      { title: citation["title"], words: citation["title"].split(/\W+/), doi: citation["doi"] }
    end
  end

  def self.average_word_length(input_csv, output_path)
    CSV.open(output_path, "wb") do |csv_out|
      csv_out << ["doi", "average_word_length"]
      words_in_title(input_csv).each do |entry|
        total_length = entry[:words].map { |w| w.size }.reduce(0, &:+)
        if entry[:words].size > 0
          csv_out << [entry[:doi], total_length / entry[:words].size]
        end
      end
    end
  end

  def self.median_word_length(input_csv, output_path)
    CSV.open(output_path, "wb") do |csv_out|
      csv_out << ["doi", "median_word_length"]
      words_in_title(input_csv).each do |entry|
        sorted_sizes = entry[:words].map { |w| w.size }.sort
        if sorted_sizes.size > 0
          middle = sorted_sizes.size/2
          median = sorted_sizes.size.even? ? ((sorted_sizes[middle] + sorted_sizes[middle-1]) / 2.0) : sorted_sizes[middle]
          csv_out << [entry[:doi], median]
        end
      end
    end
  end
end
