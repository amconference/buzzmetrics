module Buzzmetrics
  require 'csv'
  def question_mark csv
    records = CSV.parse csv, headers: true
    CSV.open("../../../../data/out/question_mark.csv", "wb") do |csv|
      csv << %w[ doi question_marks ]
      records.each do |record|
        has_question = record['title'].include?('?') ? 1 : 0
        csv << [ record['doi'], has_question ]
      end
    end
  end
end
