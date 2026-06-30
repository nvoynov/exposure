# Monkey-patching the core Ruby Time class to inject fine-art context annotations
class ::Time
  # @return [String] poetic representation of chronological parameters in English
  # Example: "Early October morning" or "Late evening in the middle of autumn"
  def to_poetic_s
    # 1. Resolve the specific dynamic season and month phase spectrum
    season_phase = 
      case month
      when 12 then "early winter"
      when 1  then "the heart of winter"
      when 2  then "late winter"
      when 3  then "early spring"
      when 4  then "the awakening of spring"
      when 5  then "late spring"
      when 6  then "early summer"
      when 7  then "the peak of summer"
      when 8  then "late summer"
      when 9  then "early autumn"
      when 10 then "the depth of autumn"
      when 11 then "late autumn"
      else "throughout the year"
      end

    # 2. Resolve the ambient light quality context based on the 24-hour cycle window
    daylight_context = 
      case hour
      when 4..5   then "At the break of dawn"
      when 6..8   then "Early morning"
      when 9..11  then "Morning"
      when 12..14 then "In the middle of the day"
      when 15..17 then "Afternoon light"
      when 18..20 then "Late evening twilight"
      when 21..23 then "Nightfall"
      else "Deep in the night"
      end

    # 3. Formulate the clean contextual sentence balance mapping
    return "#{daylight_context} during #{season_phase}" \
      unless month.between?(3, 5) || month.between?(9, 11)

    # Clean execution flow for transitional seasons avoiding nested branches
    case hour
    when 6..8   then "Early #{strftime('%B')} morning"
    when 18..20 then "Late evening in the middle of #{strftime('%B')}"
    else "#{daylight_context} in #{season_phase}"
    end
  end
end
