class ProcessStory
  include HTTParty

  def initialize(key, credentials, options={})
    if credentials.empty? == false
      auth_creds = {:username => credentials['email'], :password => credentials['password']}

      response = HTTParty.get("#{ENV['JIRA']}/rest/api/latest/search?jql=key%20%3D%20#{key}",
                              :basic_auth => auth_creds, :headers => {"Content-Type":"application/json"}
      )

      @json = JSON.parse response.body
    else
      @json=JSON.parse options[:issue].to_json
    end

    @key = key
    @summary = @json['issues'][0]['fields']['summary']
    @description = @json['issues'][0]['fields']['description']
    if @description.nil?
      @description = ""
    end
  end

  def to_golden_story
    {
        :key => @key,
        :summary => @summary,
        :narrative => self.narrative,
        :acceptance_criteria => self.acceptance_criteria,
        :risk_analysis => self.risk_analysis
    }.to_json
  end

  def narrative
    narrative = ""
    @description.each_line do | line|
      if (line.strip.start_with? "As a") || (line.strip.start_with? "I would") || (line.strip.start_with? "So that")
        narrative << line
      elsif (line.strip.start_with? "*As a") || (line.strip.start_with? "*I would") || (line.strip.start_with? "*So that")
        narrative << line.delete!('*')
      elsif (line.strip.start_with? "_As a") || (line.strip.start_with? "_I would") || (line.strip.start_with? "_So that")
        narrative << line.delete!('_')
      elsif (line.strip.start_with? "+As a") || (line.strip.start_with? "+I would") || (line.strip.start_with? "+So that")
        narrative << line.delete!('+')
      end
    end
    return narrative
  end

  def acceptance_criteria
    criteria=[]
    @description.each_line do | line|
      if (line.strip.start_with? "* I should")
        criteria << line.delete!('*')
      elsif (line.strip.start_with? "* *I should")
          criteria << line.delete!('*')
      elsif (line.strip.start_with? "* _I should")
        criteria << line.delete_prefix(' *').delete!('_')
      elsif (line.strip.start_with? "* +I should")
        criteria << line.delete_prefix(' *').delete!('+')
      end
    end
    return criteria
  end

  def color_severity(severity)
    if severity == "LOW"
      severity.prepend('<a class="yellow waves-effect waves-light btn-small">')
      severity.concat('</a>')
    elsif severity == "MEDIUM"
      severity.prepend('<a class="orange waves-effect waves-light btn-small">')
      severity.concat('</a>')
    elsif severity == "HIGH"
      severity.prepend('<a class="red waves-effect waves-light btn-small">')
      severity.concat('</a>')
    else

    end
  end

  def table_row_processor(row, pre,post,delimiter)
    temporary = row.split(delimiter)
    temporary.shift
    temporary.pop
    temporary.map { |x| color_severity(x)}
    temporary.map { |x| x.concat(post)}
    temporary.map { |x| x.prepend(pre)}
    temporary.reduce(:+)
  end

  def risk_analysis
    risks = []

    @description.each_line do | line|
      if (line.strip.start_with? "|")
        risks << line.delete_prefix(' *')
      end
    end

    puts risks.class
    puts "This is #{risks[0]}"
    if (risks[0] != "||Risk||Mitigation||Severity||Reference||")
      puts risks[0].class
      puts "issue"
      return "Error:  Risk Analysis Table Does Not Contain The Following Columns:  Risk, Mitigation, Severity, Refence"
    else
      puts risks[0].class
      puts "Test"
      risks.shift

      risk_analysis = []
      risks.each do | risk |
        unless risk.nil?
          array = risk.split('|')
          array.reject! { |s| s.nil? || s.strip.empty? }
          risk_analysis << {
              "risk":array[0],
              "mitigation":array[1],
              "severity":array[2],
              "reference":array[3]
          }
        end
      end
      return risk_analysis
    end
  end

end