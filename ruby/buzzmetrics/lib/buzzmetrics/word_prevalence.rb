module Buzzmetrics
  require 'csv'
  def read_word_frequency
    frequency_file = File.expand_path('../../../../../data/en-wordfreq.txt', __FILE__)
    frequency_list = IO.readlines(frequency_file).map do |row| 
      word, count = row.split
      [word, count.to_i]
    end
    Hash[frequency_list]
  end

  def is_initialism word
    word == word.upcase && word.delete('.').length > 1
  end

  def score_for_frequency freq
    # There is no rhyme or reason to these figures
    return  0 if freq.nil? # dictionary miss
    return -1 if freq >= 500_000
    return  1 if freq >= 100_000
    return  2 if freq >=  50_000
    return  3 if freq >=  25_000
    return  4 if freq >=   5_000
    return  0 if freq ==       1 # there is a lot of noise in the wordlist, seemingly from typos
    return  5
  end

  def sanitize word
    return word if is_initialism(word)
    word.downcase.gsub(/[,:\.!\?]+$/, '') # strip trailing punctuation
  end

  # very common words count negatively. Rarer words count more the rarer they are.
  # The final score is a rough metric for "rareness of words used"
  def score_title title, freq_list
    title
      .split
      .map{|word| is_initialism(word) ? 4 : score_for_frequency(freq_list[sanitize word])}
      .inject(:+)
  end
  def has_initialism input_csv, output_path
    freq_list = read_word_frequency
    records = CSV.parse input_csv, headers: true
    CSV.open(output_path, "wb") do |csv|
      csv << %w[ doi has_initialism ]
      records.each do |record|
        bool = record['title'].split.any?{|word| is_initialism word }
        csv << [ record['doi'], bool ? 1 : 0 ]
      end
    end
  end
  def word_prevalence input_csv, output_path
    freq_list = read_word_frequency
    records = CSV.parse input_csv, headers: true
    CSV.open(output_path, "wb") do |csv|
      csv << %w[ doi word_prevalence_score ]
      records.each do |record|
        csv << [ record['doi'], score_title(record['title'], freq_list) ]
      end
    end
  end
end
