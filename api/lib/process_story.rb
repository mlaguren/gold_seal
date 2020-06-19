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
      end
    end
    return narrative
  end

  def acceptance_criteria
    criteria=[]
    @description.each_line do | line|
      if (line.strip.start_with? "* I should")
        criteria << line.delete_prefix(' *')
        puts criteria
      end
    end
    return criteria
  end

  def table_row_processor(row, pre,post,delimiter)
    temporary = row.split(delimiter)
    temporary.shift
    temporary.pop
    temporary.map { |x| x.concat(post)}
    temporary.map { |x| x.prepend(pre)}
    temporary.reduce(:+)
  end

  def risk_analysis
    risk = []
    @description.each_line do | line|
      if (line.strip.start_with? "|")
        risk << line.delete_prefix(' *')
      end
    end
    rows = []
    risk.each do | row |
      if (row.strip.start_with? "||")
        rows << table_row_processor(row, "<th>","</th>","||")
      else
        rows << table_row_processor(row, "<td>","</td>","|")
      end
    end
    table = "<table>"
    rows.each do | row |
      table.concat("<tr>#{row}</tr>")
    end
    table.concat("</table>")
    return table
  end

end