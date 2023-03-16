module MiddleEnglishDictionary
  def self.normalize_med_id(medid)
    medid.gsub(/MED0+/, "MED")
  end
end
