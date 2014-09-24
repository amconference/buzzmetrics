module Buzzmetrics
  require 'csv'
  def colons input_csv, output_path
    records = CSV.parse input_csv, headers: true
    CSV.open(output_path, "wb") do |csv|
      csv << %w[ doi colons ]
      records.each do |record|
        has_colon = record['title'].include?(':') ? 1 : 0
        csv << [ record['doi'], has_colon ]
      end
    end
  end
end
