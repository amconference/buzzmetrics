module Buzzmetrics
  require 'csv'
  def question_mark input_csv, output_path
    records = CSV.parse input_csv, headers: true
    CSV.open(output_path, "wb") do |csv|
      csv << %w[ doi question_marks ]
      records.each do |record|
        has_question = record['title'].include?('?') ? 1 : 0
        csv << [ record['doi'], has_question ]
      end
    end
  end
end
