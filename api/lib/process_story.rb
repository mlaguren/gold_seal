class ProcessStory
  include HTTParty

  def initialize(story, credentials)
    auth_creds = {:username => credentials['email'], :password => credentials['password']}

    response = HTTParty.get("#{ENV['JIRA']}/rest/api/latest/search?jql=key%20%3D%20#{story}",
                            :basic_auth => auth_creds)
    json = JSON.parse response.body
    descr = json['issues'][0]['fields']['description']
    puts @description
    @key = story
    @summary = json['issues'][0]['fields']['summary']
    @description = json['issues'][0]['fields']['description']
  end

  def to_golden_story
    {
        :key => @key,
        :summary => @summary,
        :narrative => self.narrative,
        :acceptance_criteria => self.acceptance_criteria
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
        criteria << line.delete_prefix('*').strip
      end
    end
    return criteria
  end


end